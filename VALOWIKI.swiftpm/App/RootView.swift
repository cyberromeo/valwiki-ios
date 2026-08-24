import SwiftUI

struct RootView: View {
    @Environment(LibraryStore.self) private var store
    @State private var tab: AppTab = .home

    var body: some View {
        ZStack {
            switch store.state {
            case .idle, .loading:
                SplashView()
            case .failed(let message):
                UplinkFailedView(message: message)
            case .ready:
                readyContent
            }
        }
        .background(Color.ink.ignoresSafeArea())
        .task { await store.loadAll() }
    }

    private var readyContent: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch tab {
                case .home: HomeView()
                case .agents: AgentsView()
                case .maps: MapsView()
                case .arsenal: ArsenalView()
                case .more: MoreView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaPadding(.bottom, 78)

            FunkyTabBar(tab: $tab)
                .padding(.horizontal, 20)
                .padding(.bottom, 4)
        }
    }
}

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.ink
            GlowBlob(color: .valRed.opacity(0.55), size: 320)
            GlowBlob(color: .mint.opacity(0.22), size: 260, offsetX: 90, offsetY: 170)
            GrainOverlay()
            VStack(spacing: 18) {
                HStack(spacing: 0) {
                    Text("VALO")
                        .font(.display(44))
                        .foregroundStyle(.cream)
                    Text("WIKI")
                        .font(.display(44))
                        .foregroundStyle(.valRed)
                }
                Text("THE FUNKY ENCYCLOPEDIA")
                    .font(.mono(9, .semibold))
                    .tracking(3)
                    .foregroundStyle(.dim)
                TimelineView(.periodic(from: .now, by: 0.45)) { context in
                    let step = Int(context.date.timeIntervalSinceReferenceDate * 2) % 4
                    Text("ESTABLISHING UPLINK" + String(repeating: ".", count: step))
                        .font(.mono(10, .bold))
                        .tracking(2)
                        .foregroundStyle(.valRed)
                }
                DotMatrix(color: .white, spacing: 9, strength: 0.22)
                    .frame(width: 180, height: 54)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

struct UplinkFailedView: View {
    let message: String
    @Environment(LibraryStore.self) private var store

    var body: some View {
        ZStack {
            Color.ink
            GrainOverlay()
            VStack(spacing: 16) {
                DotMatrix(color: .valRed, spacing: 9, strength: 0.5)
                    .frame(width: 160, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                Text("SIGNAL LOST")
                    .font(.display(40))
                    .foregroundStyle(.cream)
                Text(message)
                    .font(.mono(10))
                    .tracking(1.2)
                    .foregroundStyle(.dim)
                    .multilineTextAlignment(.center)
                Button {
                    Haptics.thud()
                    Task { await store.loadAll() }
                } label: {
                    Text("RETRY UPLINK")
                        .font(.mono(12, .bold))
                        .tracking(2)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(Color.cream))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 32)
        }
    }
}
