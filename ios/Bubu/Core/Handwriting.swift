import SwiftUI
import PencilKit
struct StrokeData:Decodable {let strokes:[String];let medians:[[[Double]]]}
enum StrokeCatalog {
    static let all:[String:StrokeData] = {
        guard let u=Bundle.main.url(forResource:"writing-strokes",withExtension:"json"),let d=try? Data(contentsOf:u) else{return [:]}
        return (try? JSONDecoder().decode([String:StrokeData].self,from:d)) ?? [:]
    }()
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
    var body:some View {
        Canvas {context,size in
            let scale=min(size.width,size.height)/1024
            let transform=CGAffineTransform(a:scale,b:0,c:0,d:-scale,tx:(size.width-1024*scale)/2,ty:(size.height-1024*scale)/2+900*scale)
            for (i,svg) in (StrokeCatalog.all[hanzi]?.strokes ?? []).enumerated() {
                let color=faint ? Palette.ink.opacity(0.09) : (i<count ? Palette.ink : Palette.ink.opacity(0.08))
                context.fill(StrokeCatalog.path(svg).applying(transform),with:.color(color))
            }
        }.accessibilityLabel("Ordine dei tratti: \(count) visibili")
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
