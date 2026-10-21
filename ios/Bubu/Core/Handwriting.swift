import SwiftUI
import PencilKit
struct StrokeData:Decodable {let strokes:[String];let medians:[[[Double]]]}
enum StrokeCatalog {
    /// Tratti e mediane di tutti i caratteri mostrati (Arphic Public License), senza scomposizioni.
    static let all:[String:StrokeData] = {
        guard let u=Bundle.main.url(forResource:"strokes",withExtension:"json"),let d=try? Data(contentsOf:u) else{return [:]}
        return (try? JSONDecoder().decode([String:StrokeData].self,from:d)) ?? [:]
    }()
    private static let lock=NSLock()
    private static var cache:[String:[Path]]=[:]
    /// Percorsi già convertiti: la griglia dei caratteri ridisegna molte tessere.
    static func paths(_ hanzi:String)->[Path] {
        lock.lock();defer{lock.unlock()}
        if let cached=cache[hanzi] {return cached}
        let parsed=(all[hanzi]?.strokes ?? []).map(path)
        cache[hanzi]=parsed
        return parsed
    }
    static func path(_ svg:String) -> Path {
        let regex=try! NSRegularExpression(pattern:"[MLQCZ]|-?[0-9]+(?:\\.[0-9]+)?")
        let tokens=regex.matches(in:svg,range:NSRange(svg.startIndex...,in:svg)).compactMap{Range($0.range,in:svg).map{String(svg[$0])}}
        var path=Path(),i=0,command="M"
        func point()->CGPoint {defer{i+=2};return CGPoint(x:Double(tokens[i]) ?? 0,y:Double(tokens[i+1]) ?? 0)}
        while i<tokens.count {
            if ["M","L","Q","C","Z"].contains(tokens[i]) {command=tokens[i];i+=1}
            switch command {
            case "M":guard i+1<tokens.count else{return path};path.move(to:point());command="L"
            case "L":guard i+1<tokens.count else{return path};path.addLine(to:point())
            case "Q":guard i+3<tokens.count else{return path};let control=point(),end=point();path.addQuadCurve(to:end,control:control)
            case "C":guard i+5<tokens.count else{return path};let a=point(),b=point(),end=point();path.addCurve(to:end,control1:a,control2:b)
            case "Z":path.closeSubpath();command="M"
            default:return path
            }
        }
        return path
    }
}
struct StrokeDiagram:View {
    let hanzi:String
    let count:Int
    var faint=false
    /// Tratti del radicale, disegnati nel rosso del sigillo.
    var radical:Set<Int>=[]
    var body:some View {
        Canvas {context,size in
            let scale=min(size.width,size.height)/1024
            let transform=CGAffineTransform(a:scale,b:0,c:0,d:-scale,tx:(size.width-1024*scale)/2,ty:(size.height-1024*scale)/2+900*scale)
            for (i,path) in StrokeCatalog.paths(hanzi).enumerated() {
                let base=radical.contains(i) ? Palette.red : Palette.ink
                let color=faint ? base.opacity(radical.contains(i) ? 0.18 : 0.09) : (i<count ? base : base.opacity(0.1))
                context.fill(path.applying(transform),with:.color(color))
            }
        }.accessibilityLabel("Ordine dei tratti: \(min(count,StrokeCatalog.paths(hanzi).count)) visibili")
    }
}
/// Carattere disegnato dai tratti, con il radicale colorato; ricade sul font se mancano i dati.
struct RadicalGlyph:View {
    let hanzi:String
    var body:some View {
        if StrokeCatalog.all[hanzi] != nil {
            StrokeDiagram(hanzi:hanzi,count:.max,radical:RadicalCatalog.shared?.entry(for:hanzi)?.strokes ?? [])
                .accessibilityHidden(true)
        } else {
            GeometryReader {g in Text(hanzi).font(.custom("PingFangSC-Regular",fixedSize:g.size.height*0.8)).frame(maxWidth:.infinity,maxHeight:.infinity)}
                .accessibilityHidden(true)
        }
    }
}
struct PencilCanvas:UIViewRepresentable {
    @Binding var drawing:PKDrawing
    func makeCoordinator()->Coordinator {Coordinator(self)}
    func makeUIView(context:Context)->PKCanvasView {
        let v=PKCanvasView();v.delegate=context.coordinator;v.drawingPolicy = .anyInput
        v.tool=PKInkingTool(.pen,color:.black,width:8);v.backgroundColor = .clear;v.isOpaque=false;v.isScrollEnabled=false
        return v
    }
    func updateUIView(_ view:PKCanvasView,context:Context) {if view.drawing != drawing {view.drawing=drawing}}
    final class Coordinator:NSObject,PKCanvasViewDelegate {
        var parent:PencilCanvas
        init(_ parent:PencilCanvas){self.parent=parent}
        func canvasViewDrawingDidChange(_ canvasView:PKCanvasView){parent.drawing=canvasView.drawing}
    }
}
