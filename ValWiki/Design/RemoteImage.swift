import SwiftUI
import UIKit

/// Memory cache shared by every image on screen (NSCache is thread-safe).
let imageMemoryCache: NSCache<NSURL, UIImage> = {
    let c = NSCache<NSURL, UIImage>()
    c.totalCostLimit = 120 * 1024 * 1024
    return c
}()

actor ImagePipeline {
    static let shared = ImagePipeline()

    private let session: URLSession = {
        let cfg = URLSessionConfiguration.default
        cfg.urlCache = URLCache(memoryCapacity: 16 * 1024 * 1024, diskCapacity: 512 * 1024 * 1024)
        cfg.requestCachePolicy = .returnCacheDataElseLoad
        cfg.timeoutIntervalForRequest = 40
        return URLSession(configuration: cfg)
    }()

    private var inFlight: [URL: Task<UIImage?, Never>] = [:]

    func image(for url: URL) async -> UIImage? {
        if let hit = imageMemoryCache.object(forKey: url as NSURL) { return hit }
        if let running = inFlight[url] { return await running.value }
        let session = self.session
        let task = Task<UIImage?, Never> {
            guard let result = try? await session.data(from: url),
                  let image = UIImage(data: result.0) else { return nil }
            return image.preparingForDisplay() ?? image
        }
        inFlight[url] = task
        let image = await task.value
        inFlight[url] = nil
        if let image {
            let pixels: CGFloat = image.size.width * image.size.height * image.scale * image.scale
            let cost: Int = Int(pixels) * 4
            imageMemoryCache.setObject(image, forKey: url as NSURL, cost: cost)
        }
        return image
    }
}

/// A cached remote image that fades in. Use `.fill` and clip at the call site for covers.
struct RemoteImage: View {
    let url: URL?
    var mode: ContentMode
    var placeholder: Color

    @State private var image: UIImage?

    init(_ url: URL?, mode: ContentMode = .fit, placeholder: Color = .clear) {
        self.url = url
        self.mode = mode
        self.placeholder = placeholder
        if let url, let hit = imageMemoryCache.object(forKey: url as NSURL) {
            _image = State(initialValue: hit)
        }
    }

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.high)
                    .aspectRatio(contentMode: mode)
                    .transition(.opacity)
            } else {
                placeholder
            }
        }
        .task(id: url) {
            guard let url else { image = nil; return }
            if let hit = imageMemoryCache.object(forKey: url as NSURL) {
                image = hit
                return
            }
            let loaded = await ImagePipeline.shared.image(for: url)
            if Task.isCancelled { return }
            withAnimation(.easeOut(duration: 0.25)) { image = loaded }
        }
    }
}
