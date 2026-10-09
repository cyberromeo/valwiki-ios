import SwiftUI

struct SearchView: View {
    @Environment(Store.self) private var store
    @State private var query = ""
    @State private var selectedSkin: Skin?

    private var q: String { query.trimmingCharacters(in: .whitespaces) }

    private struct Results {
        var agents: [Agent] = []
        var weapons: [Weapon] = []
        var maps: [GameMap] = []
        var skins: [Skin] = []
        var bundles: [StoreBundle] = []
        var isEmpty: Bool { agents.isEmpty && weapons.isEmpty && maps.isEmpty && skins.isEmpty && bundles.isEmpty }
    }

    private var results: Results {
        let text = q
        var out = Results()
        if text.isEmpty { return out }
        out.agents = store.agents.filter { (a: Agent) -> Bool in
            a.displayName.localizedCaseInsensitiveContains(text) || a.roleName.localizedCaseInsensitiveContains(text)
        }
        out.weapons = store.weapons.filter { (w: Weapon) -> Bool in
            w.displayName.localizedCaseInsensitiveContains(text) || w.categoryName.localizedCaseInsensitiveContains(text)
        }
        out.maps = store.maps.filter { (m: GameMap) -> Bool in m.displayName.localizedCaseInsensitiveContains(text) }
        if text.count >= 2 {
            let matched: [Skin] = store.allSkins.filter { (s: Skin) -> Bool in s.displayName.localizedCaseInsensitiveContains(text) }
            out.skins = Array(matched.prefix(60))
            out.bundles = store.bundles.filter { (b: StoreBundle) -> Bool in (b.displayName ?? "").localizedCaseInsensitiveContains(text) }
        }
        return out
    }

    var body: some View {
        let r = results
        let agents: [Agent] = r.agents
        let weapons: [Weapon] = r.weapons
        let maps: [GameMap] = r.maps
        let skins: [Skin] = r.skins
        let bundles: [StoreBundle] = r.bundles
        let nothing: Bool = r.isEmpty

        List {
            if q.isEmpty {
                Section("Try") {
                    ForEach(["Jett", "Vandal", "Reaver", "Ascent", "Prime", "Sentinel"], id: \.self) { s in
                        Button {
                            query = s
                        } label: {
                            Label(s, systemImage: "magnifyingglass")
                        }
                        .foregroundStyle(.primary)
                    }
                }
                Section {
                    Text("Search across \(store.agents.count) agents, \(store.weapons.count) weapons, \(store.skinCount) skins and \(store.maps.count) maps.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            if !agents.isEmpty {
                Section("Agents") {
                    ForEach(agents) { a in
                        NavigationLink(value: Route.agent(a.uuid)) {
                            ResultRow(image: link(a.displayIcon), title: a.displayName, subtitle: a.roleName, round: true)
                        }
                    }
                }
            }
            if !weapons.isEmpty {
                Section("Weapons") {
                    ForEach(weapons) { w in
                        NavigationLink(value: Route.weapon(w.uuid)) {
                            ResultRow(image: link(w.displayIcon), title: w.displayName, subtitle: w.cost > 0 ? "\(w.categoryName) · \(w.cost) credits" : w.categoryName, wide: true)
                        }
                    }
                }
            }
            if !maps.isEmpty {
                Section("Maps") {
                    ForEach(maps) { m in
                        NavigationLink(value: Route.map(m.uuid)) {
                            ResultRow(image: link(m.listViewIcon) ?? link(m.splash), title: m.displayName, subtitle: m.tacticalDescription ?? "Mode map", wide: true, fill: true)
                        }
                    }
                }
            }
            if !skins.isEmpty {
                Section(skins.count == 60 ? "Skins (first 60)" : "Skins") {
                    ForEach(skins) { s in
                        Button {
                            selectedSkin = s
                        } label: {
                            ResultRow(image: s.image, title: s.displayName, subtitle: store.owner(of: s)?.displayName ?? "", wide: true)
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            if !bundles.isEmpty {
                Section("Bundles") {
                    ForEach(bundles) { b in
                        NavigationLink(value: Route.bundles) {
                            ResultRow(image: link(b.displayIcon), title: b.displayName ?? "", subtitle: "Store bundle", wide: true, fill: true)
                        }
                    }
                }
            }
        }
        .overlay {
            if !q.isEmpty && nothing {
                ContentUnavailableView.search(text: q)
            }
        }
        .navigationTitle("Search")
        .searchable(text: $query, prompt: "Agents, weapons, skins, maps")
        .task { await store.loadExtras() }
        .sheet(item: $selectedSkin) { skin in
            SkinDetailSheet(skin: skin, weapon: store.owner(of: skin))
        }
    }
}

struct ResultRow: View {
    let image: URL?
    let title: String
    let subtitle: String
    var round = false
    var wide = false
    var fill = false

    var body: some View {
        HStack(spacing: 12) {
            RemoteImage(image, mode: fill ? .fill : .fit, placeholder: Color(.tertiarySystemFill))
                .frame(width: wide ? 72 : 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: round ? 20 : 8, style: .continuous))
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.body)
                if !subtitle.isEmpty {
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
    }
}
