import SwiftUI

struct ArsenalView: View {
    @Environment(Store.self) private var store
    @State private var query = ""

    private var groups: [Grouped<Weapon>] {
        let list: [Weapon] = store.weapons.filter { (w: Weapon) -> Bool in
            if query.isEmpty { return true }
            return w.displayName.localizedCaseInsensitiveContains(query) || w.categoryName.localizedCaseInsensitiveContains(query)
        }
        let extra: [String] = Set(list.map { $0.categoryName }).subtracting(Store.categoryOrder).sorted()
        let cats: [String] = Store.categoryOrder + extra
        return cats.compactMap { cat in
            let items = list.filter { $0.categoryName == cat }
            return items.isEmpty ? nil : Grouped(title: cat, items: items)
        }
    }

    static func plural(_ category: String) -> String {
        switch category {
        case "SMG": return "SMGs"
        case "Heavy": return "Heavies"
        case "Melee": return "Melee"
        default: return category + "s"
        }
    }

    var body: some View {
        List {
            ForEach(groups) { group in
                Section(Self.plural(group.title)) {
                    ForEach(group.items) { weapon in
                        NavigationLink(value: Route.weapon(weapon.uuid)) {
                            WeaponRow(weapon: weapon)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Arsenal")
        .navigationSubtitleIfAvailable("\(store.weapons.count) weapons · \(store.skinCount) skins")
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Find a weapon")
        .overlay {
            if groups.isEmpty { ContentUnavailableView.search(text: query) }
        }
    }
}

struct WeaponRow: View {
    let weapon: Weapon

    var body: some View {
        HStack(spacing: 14) {
            RemoteImage(link(weapon.displayIcon))
                .frame(width: 110, height: 44)
            VStack(alignment: .leading, spacing: 3) {
                Text(weapon.displayName)
                    .font(.headline)
                HStack(spacing: 10) {
                    if weapon.cost > 0 {
                        Label("\(weapon.cost)", systemImage: "creditcard.fill")
                    }
                    if let rate = weapon.weaponStats?.fireRate?.value, rate > 0 {
                        Label(formatNumber(rate, decimals: 2) + "/s", systemImage: "speedometer")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .labelStyle(CompactLabelStyle())
            }
            Spacer(minLength: 0)
            Text("\(weapon.realSkins.count)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color(.tertiarySystemFill), in: Capsule())
                .accessibilityLabel("\(weapon.realSkins.count) skins")
        }
        .padding(.vertical, 4)
    }
}

struct CompactLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 3) {
            configuration.icon.imageScale(.small)
            configuration.title
        }
    }
}
