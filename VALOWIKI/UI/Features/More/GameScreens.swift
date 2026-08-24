import SwiftUI

struct RanksList: View {
    @Environment(LibraryStore.self) private var store
    @State private var episodeIndex: Int?

    private var selectedList: CompetitiveTierList? {
        let lists = store.tierLists
        guard !lists.isEmpty else { return nil }
        let index = episodeIndex ?? lists.count - 1
        return lists.indices.contains(index) ? lists[index] : lists.last
    }

    private var divisions: [(String, [Tier])] {
        let visible = (selectedList?.tiers ?? []).filter {
            ($0.largeIcon != nil || $0.smallIcon != nil) && !($0.tierName ?? "").lowercased().contains("unused")
        }
        let grouped = Dictionary(grouping: visible) { $0.divisionName ?? "OTHER" }
        return grouped.sorted { ($0.value.first?.tier ?? 0) < ($1.value.first?.tier ?? 0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if store.tierLists.count > 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(store.tierLists.enumerated()), id: \.element.uuid) { index, list in
                            let active = (episodeIndex ?? store.tierLists.count - 1) == index
                            Button {
                                Haptics.tap()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    episodeIndex = index
                                }
                            } label: {
                                Text(list.episodeLabel)
                                    .font(.mono(9, .bold))
                                    .tracking(1.4)
                                    .foregroundStyle(active ? Color.black : Color.cream)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Capsule().fill(active ? Color.gold : Color.panel))
                                    .overlay(Capsule().strokeBorder(active ? Color.clear : Color.line))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }

            if divisions.isEmpty {
                EmptyState(title: "No Ranks", subtitle: "UPLINK MISSED /V1/COMPETITIVETIERS")
            } else {
                ForEach(divisions, id: \.0) { division in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Text(division.0.uppercased())
                                .font(.mono(10, .bold))
                                .tracking(2.4)
                                .foregroundStyle(.valRed)
                            Rectangle().fill(Color.line).frame(height: 1)
                            Text("\(division.1.count)")
                                .font(.mono(9, .bold))
                                .foregroundStyle(.faint)
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(division.1) { tier in
                                    RankCard(tier: tier)
                                }
                            }
                        }
                        .scrollIndicators(.hidden)
                    }
                }
            }
        }
    }
}

struct RankCard: View {
    let tier: Tier

    var body: some View {
        VStack(spacing: 6) {
            RemoteImage(url: tier.largeIcon ?? tier.smallIcon, contentMode: .fit)
                .frame(width: 62, height: 62)
            Text(tier.tierName?.uppercased() ?? "TIER")
                .font(.mono(8, .bold))
                .tracking(1)
                .foregroundStyle(.cream)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            if let color = tier.color {
                Circle()
                    .fill(Color(hexString: color))
                    .frame(width: 6, height: 6)
            }
        }
        .padding(10)
        .frame(width: 92)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.panel))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Color.line))
    }
}

struct ModesList: View {
    @Environment(LibraryStore.self) private var store

    var body: some View {
        VStack(spacing: 10) {
            ForEach(store.gameModes) { mode in
                HStack(spacing: 12) {
                    RemoteImage(url: mode.displayIcon, contentMode: .fit)
                        .frame(width: 54, height: 54)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(mode.displayName.uppercased())
                            .font(.display(20))
                            .foregroundStyle(.cream)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        if let duration = mode.duration {
                            Chip(text: duration, color: .mint)
                        }
                        if let description = mode.description {
                            Text(description)
                                .font(.mono(8.5))
                                .tracking(0.3)
                                .foregroundStyle(.dim)
                                .lineLimit(2)
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 5) {
                        if let orbs = mode.orbCount {
                            Text("◉ x\(orbs)")
                                .font(.mono(9, .bold))
                                .foregroundStyle(.valRed)
                        }
                        if mode.isTeamVoiceAllowed == true {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.faint)
                        }
                        if mode.isMinimapHidden == true {
                            Image(systemName: "map")
                                .font(.system(size: 10))
                                .foregroundStyle(.faint)
                        }
                    }
                }
                .panelCard()
            }
        }
    }
}

struct SeasonsList: View {
    @Environment(LibraryStore.self) private var store

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            let seasons = store.seasons.reversed()
            ForEach(Array(seasons.enumerated()), id: \.element.id) { index, season in
                HStack(alignment: .top, spacing: 12) {
                    VStack(spacing: 0) {
                        Circle()
                            .fill(Color.valRed)
                            .frame(width: 9, height: 9)
                            .padding(.top, 20)
                        if index < store.seasons.count - 1 {
                            Rectangle()
                                .fill(Color.line)
                                .frame(width: 1.5)
                                .frame(minHeight: 52)
                        }
                    }
                    seasonCard(season)
                        .padding(.bottom, 14)
                }
            }
        }
    }

    private func seasonCard(_ season: Season) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(season.displayName.uppercased())
                    .font(.display(24))
                    .foregroundStyle(.cream)
                    .lineLimit(1)
                Spacer()
                Chip(text: season.typeName, color: .mint)
            }
            if let range = season.rangeText {
                CornerTag(text: range)
            }
        }
        .panelCard()
    }
}

struct ContractsList: View {
    @Environment(LibraryStore.self) private var store

    var body: some View {
        VStack(spacing: 10) {
            ForEach(store.contracts) { contract in
                NavigationLink(value: contract) {
                    HStack(spacing: 12) {
                        RemoteImage(url: contract.displayIcon, contentMode: .fit)
                            .frame(width: 42, height: 42)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.04))
                            )
                        VStack(alignment: .leading, spacing: 2) {
                            Text(contract.title)
                                .font(.display(20))
                                .foregroundStyle(.cream)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            Text("\(contract.chapters.count) CHAPTERS // \(contract.levelCount) REWARDS")
                                .font(.mono(8))
                                .tracking(1.2)
                                .foregroundStyle(.dim)
                        }
                        Spacer()
                        if let vp = contract.premiumVPCost, vp > 0 {
                            Chip(text: "\(vp) VP", color: .gold)
                        }
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.faint)
                    }
                    .panelCard()
                    .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct ContractDetailView: View {
    let contract: Contract

    var body: some View {
        ZStack {
            Backdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    hero
                    ForEach(Array(contract.chapters.enumerated()), id: \.offset) { index, chapter in
                        chapterCard(index, chapter)
                    }
                    if contract.chapters.isEmpty {
                        EmptyState(title: "No Track Data", subtitle: "THIS CONTRACT SHIPS WITHOUT CHAPTERS")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 50)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.panel)
            GlowBlob(color: .gold.opacity(0.3), size: 220, offsetX: 60, offsetY: -30)
            DotMatrix(color: .white, spacing: 12, strength: 0.08)
            RemoteImage(url: contract.displayIcon, contentMode: .fit)
                .frame(height: 110)
                .frame(maxWidth: .infinity)
                .padding(.top, 30)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Chip(text: "CONTRACT", filled: true, color: .gold)
                    if let vp = contract.premiumVPCost, vp > 0 {
                        Chip(text: "PREMIUM \(vp) VP", color: .mint)
                    }
                    if contract.shipIt == true {
                        Chip(text: "ACTIVE", filled: true, color: .mint)
                    }
                }
                Text(contract.title)
                    .font(.display(38))
                    .foregroundStyle(.cream)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .padding(18)
        }
        .frame(height: 250)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).strokeBorder(Color.line))
    }

    private func chapterCard(_ index: Int, _ chapter: ContractChapter) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(chapter.isEpilogue == true ? "EPILOGUE" : "CHAPTER \(index + 1)")
                    .font(.mono(10, .bold))
                    .tracking(2.2)
                    .foregroundStyle(.valRed)
                Rectangle().fill(Color.line).frame(height: 1)
                Text("\(chapter.levels?.count ?? 0) TIERS")
                    .font(.mono(8.5, .semibold))
                    .foregroundStyle(.faint)
            }
            ForEach(Array((chapter.levels ?? []).enumerated()), id: \.offset) { levelIndex, level in
                HStack(spacing: 12) {
                    Text("\(levelIndex + 1)")
                        .font(.mono(9, .bold))
                        .foregroundStyle(.faint)
                        .frame(width: 22)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(level.reward?.typeName ?? "REWARD")
                            .font(.mono(9.5, .bold))
                            .tracking(1)
                            .foregroundStyle(.cream)
                        HStack(spacing: 8) {
                            if let xp = level.xp {
                                Text("\(xp) XP")
                                    .font(.mono(7.5, .bold))
                                    .tracking(1.2)
                                    .foregroundStyle(.valRed)
                            }
                            if let amount = level.reward?.amount, amount > 1 {
                                Text("×\(amount)")
                                    .font(.mono(7.5, .bold))
                                    .foregroundStyle(.gold)
                            }
                            if level.isPurchasableWithVP == true, let vp = level.vpCost {
                                Text("\(vp) VP")
                                    .font(.mono(7.5, .bold))
                                    .foregroundStyle(.mint)
                            }
                            if level.reward?.isHighlighted == true {
                                Text("HIGHLIGHT")
                                    .font(.mono(6.5, .black))
                                    .tracking(1)
                                    .foregroundStyle(.black)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(Color.gold))
                            }
                        }
                    }
                    Spacer()
                    Image(systemName: rewardIcon(level.reward?.type))
                        .font(.system(size: 12))
                        .foregroundStyle(.faint)
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white.opacity(0.03)))
            }
        }
        .panelCard()
    }

    private func rewardIcon(_ type: String?) -> String {
        switch type?.cleanedEnum.lowercased() {
        case "currency": return "banknote.fill"
        case "playercard": return "creditcard.fill"
        case "playercardlevel": return "creditcard.fill"
        case "equippablecharm", "equippablecharmlevel": return "gift.fill"
        case "spray", "spraylevel": return "drop.fill"
        case "player_title", "playertitle": return "textformat"
        case "weapon_buddylevel", "buddylevel": return "gift.fill"
        default: return "seal.fill"
        }
    }
}

struct EventsList: View {
    @Environment(LibraryStore.self) private var store

    var body: some View {
        VStack(spacing: 10) {
            ForEach(store.events) { event in
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(event.displayName.uppercased())
                                .font(.display(22))
                                .foregroundStyle(.cream)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            if event.isLive {
                                HStack(spacing: 4) {
                                    PulseDot(color: .valRed)
                                    Text("LIVE")
                                        .font(.mono(8, .bold))
                                        .tracking(1.5)
                                        .foregroundStyle(.valRed)
                                }
                            }
                        }
                        if let short = event.shortDisplayName {
                            CornerTag(text: short)
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 3) {
                        if let range = event.rangeText {
                            Text(range)
                                .font(.mono(7.5))
                                .tracking(0.6)
                                .foregroundStyle(.dim)
                                .multilineTextAlignment(.trailing)
                        }
                        Chip(text: "EVENT PASS", color: .gold)
                    }
                }
                .panelCard()
            }
        }
    }
}
