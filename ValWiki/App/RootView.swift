import SwiftUI

enum AppTab: Hashable {
    case home, agents, arsenal, maps, search
}

enum Route: Hashable {
    case agent(String)
    case weapon(String)
    case skins(String)
    case map(String)
    case ranks
    case seasons
    case modes
    case bundles
    case trainer
}

struct RootView: View {
    @Environment(Store.self) private var store

    var body: some View {
        ZStack {
            switch store.phase {
            case .loaded:
                MainTabs()
                    .transition(.opacity)
            case .failed(let message):
                SignalLostView(message: message)
                    .transition(.opacity)
            default:
                SplashView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: phaseKey)
        .task { await store.load() }
    }

    private var phaseKey: Int {
        switch store.phase {
        case .idle: return 0
        case .loading: return 1
        case .loaded: return 2
        case .failed: return 3
        }
    }
}

struct MainTabs: View {
    @State private var tab: AppTab = .home

    var body: some View {
        TabView(selection: $tab) {
            Tab("Home", systemImage: "house.fill", value: AppTab.home) {
                NavigationStack { HomeView(tab: $tab).withRoutes() }
            }
            Tab("Agents", systemImage: "person.3.fill", value: AppTab.agents) {
                NavigationStack { AgentsView().withRoutes() }
            }
            Tab("Arsenal", systemImage: "scope", value: AppTab.arsenal) {
                NavigationStack { ArsenalView().withRoutes() }
            }
            Tab("Maps", systemImage: "map.fill", value: AppTab.maps) {
                NavigationStack { MapsView().withRoutes() }
            }
            Tab(value: AppTab.search, role: .search) {
                NavigationStack { SearchView().withRoutes() }
            }
        }
        .minimizingTabBar()
        .onChange(of: tab) { _, _ in Haptics.select() }
    }
}

extension View {
    func withRoutes() -> some View {
        navigationDestination(for: Route.self) { route in
            RouteDestination(route: route)
        }
    }
}

struct RouteDestination: View {
    @Environment(Store.self) private var store
    let route: Route

    var body: some View {
        switch route {
        case .agent(let id):
            if let agent = store.agent(id) { AgentDetailView(agent: agent) } else { missing }
        case .weapon(let id):
            if let weapon = store.weapon(id) { WeaponDetailView(weapon: weapon) } else { missing }
        case .skins(let id):
            if let weapon = store.weapon(id) { SkinsView(weapon: weapon) } else { missing }
        case .map(let id):
            if let map = store.map(id) { MapDetailView(map: map) } else { missing }
        case .ranks:
            RanksView()
        case .seasons:
            SeasonsView()
        case .modes:
            ModesView()
        case .bundles:
            BundlesView()
        case .trainer:
            AimTrainerView()
        }
    }

    private var missing: some View {
        ContentUnavailableView("Not found", systemImage: "questionmark.square.dashed")
    }
}

struct SplashView: View {
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            LogoMark(size: 96)
                .scaleEffect(pulse ? 1.04 : 0.96)
                .opacity(pulse ? 1 : 0.7)
            Text("ValWiki")
                .font(VW.title(44))
            ProgressView()
                .padding(.top, 4)
            Spacer()
            Text("Data from valorant-api.com")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) { pulse = true }
        }
    }
}

struct SignalLostView: View {
    @Environment(Store.self) private var store
    let message: String

    var body: some View {
        ContentUnavailableView {
            Label("Signal Lost", systemImage: "antenna.radiowaves.left.and.right.slash")
        } description: {
            Text("Couldn't reach the Valorant data feed. Check your connection and try again.\n\n\(message)")
        } actions: {
            Button("Try Again") {
                Haptics.tap()
                Task { await store.load() }
            }
            .glassProminentButton()
        }
    }
}
