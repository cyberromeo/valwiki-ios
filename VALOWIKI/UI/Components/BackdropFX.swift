import SwiftUI
import UIKit

enum NoiseTexture {
    static let image: UIImage = {
        let side: CGFloat = 140
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: side, height: side))
        return renderer.image { ctx in
            let cg = ctx.cgContext
            cg.setFillColor(UIColor.black.cgColor)
            cg.fill(CGRect(x: 0, y: 0, width: side, height: side))
            for _ in 0..<5200 {
                let white = CGFloat.random(in: 0...1)
                cg.setFillColor(UIColor(white: white, alpha: CGFloat.random(in: 0.05...0.55)).cgColor)
                let x = CGFloat.random(in: 0...side)
                let y = CGFloat.random(in: 0...side)
                cg.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }
    }()
}

struct GrainOverlay: View {
    var opacity: Double = 0.07

    var body: some View {
        Image(uiImage: NoiseTexture.image)
            .resizable()
            .ignoresSafeArea()
            .blendMode(.overlay)
            .opacity(opacity)
            .allowsHitTesting(false)
    }
}

struct GlowBlob: View {
    var color: Color = .valRed
    var size: CGFloat = 280
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .blur(radius: size * 0.38)
            .offset(x: offsetX, y: offsetY)
            .allowsHitTesting(false)
    }
}

struct DotMatrix: View {
    var color: Color = .white
    var spacing: CGFloat = 13
    var strength: Double = 0.35

    var body: some View {
        Canvas { context, size in
            let spacingValue = spacing
            var row = 0
            var y: CGFloat = spacingValue / 2
            while y < size.height {
                var x: CGFloat = spacingValue / 2
                while x < size.width {
                    let phase: Double = (Double(x) + Double(y) * 1.7) * 0.045 + Double(row) * 0.35
                    let wave: Double = sin(phase)
                    let radius: CGFloat = max(0.6, spacingValue * 0.24 * CGFloat(0.6 + wave * 0.8))
                    let rect = CGRect(x: x - radius / 2, y: y - radius / 2, width: radius, height: radius)
                    let shade: Double = strength * (0.5 + wave * 0.5)
                    context.fill(Path(ellipseIn: rect), with: .color(color.opacity(shade)))
                    x += spacingValue
                }
                y += spacingValue
                row += 1
            }
        }
        .allowsHitTesting(false)
    }
}

struct Backdrop: View {
    var blobColor: Color = .valRed

    var body: some View {
        ZStack {
            Color.ink
            GlowBlob(color: blobColor.opacity(0.5), size: 360, offsetX: -30, offsetY: -230)
            GlowBlob(color: .white.opacity(0.12), size: 300, offsetX: 130, offsetY: -40)
            GrainOverlay()
        }
        .ignoresSafeArea()
    }
}
