import SwiftUI

struct SkinsGallery: View {
    @Environment(LibraryStore.self) private var store
    @State private var tierFilter = "ALL"

    private let tierFilters = ["ALL", "SELECT", "DELUXE", "PREMIUM", "ULTRA", "EXCLUSIVE"]

    private var defaultSkinIDs: Set<String> {
        Set(store.weapons.compactMap(\.defaultSkinUuid))
    }

    private var filtered: [WeaponSkin] {
        let base = store.skins.filter { !defaultSkinIDs.contains($0.uuid) }
        guard tierFilter != "ALL" else { return base }
        return base.filter { ContentTierMapper.name(for: $0.contentTierUuid) == tierFilter }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(tierFilters, id: \.self) { tier in
                        let active = tierFilter == tier
                        Button {
                            Haptics.tap()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                tierFilter = tier
                            }
                        } label: {
                            Text(tier)
                                .font(.mono(9, .bold))
                                .tracking(1.4)
                                .foregroundStyle(active ? Color.black : Color.cream)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(active ? tierAccent(tier) : Color.panel))
                                .overlay(Capsule().strokeBorder(active ? Color.clear : Color.line))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollIndicators(.hidden)

            if filtered.isEmpty {
                EmptyState(title: "No Skins", subtitle: "UPLINK MISSED /V1/WEAPONS/SKINS")
            } else {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    ForEach(filtered) { skin in
                        NavigationLink(value: skin) {
                            SkinCard(skin: skin)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func tierAccent(_ tier: String) -> Color {
        ContentTierMapper.color(forName: tier)
    }
}

struct SkinCard: View {
    let skin: WeaponSkin

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.panel)
            VStack(alignment: .leading, spacing: 8) {
                RemoteImage(url: skin.displayIcon ?? skin.chromas?.first?.fullRender, contentMode: .fit)
                    .frame(height: 84)
                    .frame(maxWidth: .infinity)
                Text(skin.displayName.uppercased())
                    .font(.display(17))
                    .foregroundStyle(.cream)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                    .frame(minHeight: 38, alignment: .top)
            }
            .padding(12)
            Capsule()
                .fill(ContentTierMapper.color(for: skin.contentTierUuid))
                .frame(width: 36, height: 5)
                .padding(11)
        }
        .frame(height: 168)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(Color.line))
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
