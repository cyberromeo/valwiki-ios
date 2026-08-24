import SwiftUI
import UIKit

final class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSURL, UIImage>()

    private init() {
        cache.countLimit = 900
    }

    func image(for url: URL) async -> UIImage? {
        if let hit = cache.object(forKey: url as NSURL) { return hit }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            cache.setObject(image, forKey: url as NSURL)
            return image
        } catch {
            return nil
        }
    }
}

struct RemoteImage: View {
    let url: URL?
    var contentMode: ContentMode = .fill

    @State private var image: UIImage?

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                placeholder
            }
        }
        .task(id: url) {
            guard let url else { return }
            image = await ImageLoader.shared.image(for: url)
        }
    }

    private var placeholder: some View {
        ZStack {
            Rectangle().fill(Color.panelHi)
            DotMatrix(color: .white, spacing: 11, strength: 0.14)
            Circle()
                .fill(Color.valRed.opacity(0.85))
                .frame(width: 6, height: 6)
                .modifier(PulseEffect())
        }
    }
}

struct PulseEffect: ViewModifier {
    @State private var on = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(on ? 2.1 : 0.8)
            .opacity(on ? 0.15 : 0.9)
            .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: on)
            .onAppear { on = true }
    }
}
