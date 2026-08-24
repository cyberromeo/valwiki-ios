import SwiftUI

struct BuddiesGrid: View {
    @Environment(LibraryStore.self) private var store

    var body: some View {
        if store.buddies.isEmpty {
            EmptyState(title: "No Buddies", subtitle: "UPLINK MISSED /V1/BUDDIES")
        } else {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(store.buddies) { buddy in
                    IconTile(title: buddy.displayName, imageURL: buddy.displayIcon, tag: "CHARM")
                }
            }
        }
    }
}

struct BuddyLevelsGrid: View {
    @Environment(LibraryStore.self) private var store

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            ForEach(store.buddyLevels) { level in
                IconTile(title: level.displayName, imageURL: level.displayIcon, tag: "LV\(level.charmLevel ?? 1)")
            }
        }
    }
}

struct PlayerCardsGrid: View {
    @Environment(LibraryStore.self) private var store

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            ForEach(store.playerCards) { card in
                VStack(alignment: .leading, spacing: 8) {
                    RemoteImage(url: card.wideArt ?? card.largeArt ?? card.smallArt, contentMode: .fill)
                        .frame(height: 96)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    Text(card.displayName.uppercased())
                        .font(.mono(8, .semibold))
                        .tracking(0.8)
                        .foregroundStyle(.cream)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.panel))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color.line))
            }
        }
    }
}

struct SpraysGrid: View {
    @Environment(LibraryStore.self) private var store

    private var sprays: [Spray] {
        store.sprays.filter { !($0.isNullSpray ?? false) }
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            ForEach(sprays) { spray in
                IconTile(title: spray.displayName, imageURL: spray.displayIcon, tag: "SPRAY")
            }
        }
    }
}

struct SprayLevelsGrid: View {
    @Environment(LibraryStore.self) private var store

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            ForEach(store.sprayLevels) { level in
                IconTile(title: level.displayName, imageURL: level.displayIcon, tag: "LV\(level.sprayLevel ?? 1)")
            }
        }
    }
}

struct TitlesList: View {
    @Environment(LibraryStore.self) private var store

    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(store.titles.enumerated()), id: \.element.id) { index, title in
                HStack(spacing: 12) {
                    Text(String(format: "%03d", index + 1))
                        .font(.mono(10, .bold))
                        .foregroundStyle(.faint)
                    Rectangle()
                        .fill(Color.valRed)
                        .frame(width: 3, height: 30)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title.titleText?.uppercased() ?? title.displayName.uppercased())
                            .font(.mono(10, .bold))
                            .tracking(1.2)
                            .foregroundStyle(.cream)
                            .lineLimit(1)
                        Text(title.displayName)
                            .font(.mono(8))
                            .foregroundStyle(.dim)
                            .lineLimit(1)
                    }
                    Spacer()
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.panel))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Color.line))
            }
        }
    }
}

struct CurrenciesList: View {
    @Environment(LibraryStore.self) private var store

    var body: some View {
        VStack(spacing: 8) {
            ForEach(store.currencies) { currency in
                HStack(spacing: 12) {
                    RemoteImage(url: currency.largeIcon ?? currency.displayIcon, contentMode: .fit)
                        .frame(width: 44, height: 44)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(currency.displayName.uppercased())
                            .font(.display(19))
                            .foregroundStyle(.cream)
                            .lineLimit(1)
                        Text(currency.displayNameSingular?.uppercased() ?? "CURRENCY")
                            .font(.mono(8))
                            .tracking(1.4)
                            .foregroundStyle(.dim)
                    }
                    Spacer()
                    Image(systemName: "banknote.fill")
                        .foregroundStyle(.valRed.opacity(0.6))
                }
                .panelCard()
            }
        }
    }
}

struct ChromasGrid: View {
    @Environment(LibraryStore.self) private var store

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            ForEach(store.skinChromas) { chroma in
                IconTile(title: chroma.displayName, imageURL: chroma.displayIcon ?? chroma.fullRender, tag: "CHROMA")
            }
        }
    }
}

struct SkinLevelsGrid: View {
    @Environment(LibraryStore.self) private var store

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            ForEach(store.skinLevels) { level in
                IconTile(title: level.displayName, imageURL: level.displayIcon, tag: level.levelItemName)
            }
        }
    }
}

struct ThemesList: View {
    @Environment(LibraryStore.self) private var store

    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(store.themes.enumerated()), id: \.element.id) { index, theme in
                HStack(spacing: 12) {
                    Text(String(format: "%02d", index + 1))
                        .font(.display(22))
                        .foregroundStyle(.valRed)
                        .frame(width: 40, alignment: .leading)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(theme.displayName.uppercased())
                            .font(.mono(10, .bold))
                            .tracking(1.2)
                            .foregroundStyle(.cream)
                            .lineLimit(1)
                        Text("SKIN FAMILY")
                            .font(.mono(7.5, .semibold))
                            .tracking(1.6)
                            .foregroundStyle(.dim)
                    }
                    Spacer()
                    if theme.storeFeaturedImage != nil {
                        Image(systemName: "photo")
                            .font(.system(size: 11))
                            .foregroundStyle(.faint)
                    }
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.panel))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Color.line))
            }
        }
    }
}

struct BundlesGrid: View {
    @Environment(LibraryStore.self) private var store

    var body: some View {
        if store.bundles.isEmpty {
            EmptyState(title: "No Bundles", subtitle: "UPLINK MISSED /V1/BUNDLES")
        } else {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(store.bundles.reversed()) { bundle in
                    VStack(alignment: .leading, spacing: 8) {
                        RemoteImage(url: bundle.verticalPromoImage ?? bundle.displayIcon2 ?? bundle.displayIcon, contentMode: .fill)
                            .frame(height: 150)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        VStack(alignment: .leading, spacing: 3) {
                            Text(bundle.displayName.uppercased())
                                .font(.display(16))
                                .foregroundStyle(.cream)
                                .lineLimit(2)
                                .minimumScaleFactor(0.7)
                            if let sub = bundle.displayNameSubText {
                                Text(sub.uppercased())
                                    .font(.mono(7.5, .semibold))
                                    .tracking(1.2)
                                    .foregroundStyle(.valRed)
                                    .lineLimit(1)
                            }
                            if let promo = bundle.promoDescription {
                                Text(promo)
                                    .font(.mono(7.5))
                                    .tracking(0.4)
                                    .foregroundStyle(.dim)
                                    .lineLimit(2)
                            }
                        }
                    }
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.panel))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color.line))
                }
            }
        }
    }
}

struct CeremoniesList: View {
    @Environment(LibraryStore.self) private var store

    var body: some View {
        if store.ceremonies.isEmpty {
            EmptyState(title: "No Ceremonies", subtitle: "UPLINK MISSED /V1/CEREMONIES")
        } else {
            VStack(spacing: 8) {
                ForEach(Array(store.ceremonies.enumerated()), id: \.element.id) { index, ceremony in
                    HStack(spacing: 12) {
                        Text(String(format: "%02d", index + 1))
                            .font(.display(20))
                            .foregroundStyle(.valRed)
                            .frame(width: 40, alignment: .leading)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(ceremony.displayName.uppercased())
                                .font(.mono(10, .bold))
                                .tracking(1.4)
                                .foregroundStyle(.cream)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            Text("MATCH END CEREMONY // \(ceremony.uuid.prefix(8)).DAT")
                                .font(.mono(7.5))
                                .tracking(1)
                                .foregroundStyle(.dim)
                                .lineLimit(1)
                        }
                        Spacer()
                        Image(systemName: "hands.clap.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(.faint)
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.panel))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Color.line))
                }
            }
        }
    }
}

struct EquippablesGrid: View {
    @Environment(LibraryStore.self) private var store

    var body: some View {
        if store.equippables.isEmpty {
            EmptyState(title: "No Mode Items", subtitle: "UPLINK MISSED /V1/GAMEMODES/EQUIPPABLES")
        } else {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(store.equippables) { item in
                    IconTile(title: item.displayName, imageURL: item.displayIcon, tag: item.categoryName)
                }
            }
        }
    }
}

struct ContentTiersList: View {
    @Environment(LibraryStore.self) private var store

    var body: some View {
        let tiers = store.contentTiers.sorted { ($0.rank ?? 0) < ($1.rank ?? 0) }
        if tiers.isEmpty {
            EmptyState(title: "No Tiers", subtitle: "UPLINK MISSED /V1/CONTENTTIERS")
        } else {
            VStack(spacing: 10) {
                ForEach(tiers) { tier in
                    HStack(spacing: 14) {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(hexString: tier.highlightColor ?? "ECE8E1"))
                            .frame(width: 46, height: 46)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.14))
                            )
                        VStack(alignment: .leading, spacing: 3) {
                            Text(tier.displayName.uppercased())
                                .font(.display(20))
                                .foregroundStyle(.cream)
                                .lineLimit(1)
                            Text("RANK \(tier.rank ?? 0) // JUICE \(tier.juiceValue ?? 0)")
                                .font(.mono(8, .semibold))
                                .tracking(1.2)
                                .foregroundStyle(.dim)
                        }
                        Spacer()
                        if let icon = tier.displayIcon {
                            RemoteImage(url: icon, contentMode: .fit)
                                .frame(width: 26, height: 26)
                        }
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.panel))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color(hexString: tier.highlightColor ?? "FFFFFF").opacity(0.45)))
                }
            }
        }
    }
}

struct IconTile: View {
    let title: String
    let imageURL: URL?
    var tag: String = ""

    var body: some View {
        VStack(spacing: 7) {
            RemoteImage(url: imageURL, contentMode: .fit)
                .frame(height: 56)
                .frame(maxWidth: .infinity)
            Text(title.uppercased())
                .font(.mono(7.5, .semibold))
                .tracking(0.6)
                .foregroundStyle(.cream)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(minHeight: 20)
            if !tag.isEmpty {
                Text(tag)
                    .font(.mono(6.5, .bold))
                    .tracking(1.2)
                    .foregroundStyle(.valRed)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.panel))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Color.line))
    }
}
