import SwiftUI
import AVKit

struct SkinsView: View {
    @Environment(Store.self) private var store
    let weapon: Weapon
    @State private var edition = "All"
    @State private var query = ""
    @State private var selected: Skin?

    private var editions: [ContentTier] {
        let used = Set(weapon.realSkins.compactMap { $0.contentTierUuid })
        return store.tiers.filter { used.contains($0.uuid) }
    }

    private var filtered: [Skin] {
        weapon.realSkins.filter { (s: Skin) -> Bool in
            let editionOK: Bool = edition == "All" || s.contentTierUuid == edition
            let queryOK: Bool = query.isEmpty || s.displayName.localizedCaseInsensitiveContains(query)
            return editionOK && queryOK
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ScrollView(.horizontal, showsIndicators: false) {
                    GlassGroup(spacing: 8) {
                        HStack(spacing: 8) {
                            FilterChip(title: "All", systemImage: "square.grid.2x2", selected: edition == "All") {
                                withAnimation(.snappy) { edition = "All" }
                            }
                            ForEach(editions) { tier in
                                FilterChip(title: tier.name, imageURL: link(tier.displayIcon), selected: edition == tier.uuid) {
                                    withAnimation(.snappy) { edition = tier.uuid }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 2)
                    }
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 12)], spacing: 12) {
                    ForEach(filtered) { skin in
                        Button {
                            Haptics.tap()
                            selected = skin
                        } label: {
                            SkinTile(skin: skin, tier: store.tier(skin.contentTierUuid))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)

                if filtered.isEmpty {
                    ContentUnavailableView.search(text: query)
                }
            }
            .padding(.vertical, 8)
        }
        .navigationTitle("\(weapon.displayName) Skins")
        .navigationSubtitleIfAvailable("\(filtered.count) skins")
        .searchable(text: $query, prompt: "Find a skin")
        .sheet(item: $selected) { skin in
            SkinDetailSheet(skin: skin, weapon: weapon)
        }
        .task {
            // Screenshot runs: open a skin with variants straight away.
            guard DebugLaunch.screen == "skin", selected == nil else { return }
            try? await Task.sleep(for: .seconds(1.5))
            let rich: Skin? = filtered.first(where: { (s: Skin) -> Bool in s.chromaList.count > 2 && s.levelList.count > 2 })
            selected = rich ?? filtered.first
        }
    }
}

struct SkinTile: View {
    let skin: Skin
    let tier: ContentTier?
    var compact = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                LinearGradient(
                    colors: [tierColor.opacity(0.35), tierColor.opacity(0.08)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                RemoteImage(skin.image)
                    .padding(12)
            }
            .frame(height: compact ? 80 : 100)
            .cardShape(16)
            HStack(spacing: 6) {
                if let icon = link(tier?.displayIcon) {
                    RemoteImage(icon).frame(width: 14, height: 14)
                }
                Text(skin.displayName)
                    .font(.footnote.weight(.semibold))
                    .lineLimit(1)
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 4)
        }
        .padding(8)
        .glassCard(cornerRadius: 22)
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var tierColor: Color {
        guard let hex = tier?.highlightColor else { return .gray }
        return hexColor(hex)
    }
}

struct SkinDetailSheet: View {
    @Environment(Store.self) private var store
    @Environment(\.dismiss) private var dismiss
    let skin: Skin
    let weapon: Weapon?

    @State private var chromaIndex = 0
    @State private var videoURL: URL?

    private var tier: ContentTier? { store.tier(skin.contentTierUuid) }

    var body: some View {
        let chromas = skin.chromaList
        let levels = skin.levelList
        let chroma = chromas.isEmpty ? nil : chromas[min(chromaIndex, chromas.count - 1)]
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 16) {
                        RemoteImage(chroma?.image ?? skin.image)
                            .frame(height: 150)
                            .frame(maxWidth: .infinity)
                            .id(chroma?.uuid ?? skin.uuid)
                            .transition(.opacity)
                        if let tier {
                            HStack(spacing: 6) {
                                RemoteImage(link(tier.displayIcon)).frame(width: 16, height: 16)
                                Text(tier.displayName ?? tier.name).font(.subheadline.weight(.semibold))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .glassCapsule(tint: hexColor(tier.highlightColor).opacity(0.5))
                        }
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }

                if chromas.count > 1 {
                    Section("Variants") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(Array(chromas.enumerated()), id: \.offset) { index, c in
                                    Button {
                                        Haptics.select()
                                        withAnimation(.smooth) { chromaIndex = index }
                                    } label: {
                                        Group {
                                            if let sw = link(c.swatch) {
                                                RemoteImage(sw, mode: .fill)
                                            } else {
                                                RemoteImage(c.image).padding(6)
                                            }
                                        }
                                        .frame(width: 54, height: 54)
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        .overlay(
                                            ChromaRing(selected: index == chromaIndex)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel(c.displayName ?? "Variant \(index + 1)")
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        if let name = chroma?.displayName {
                            Text(name.replacingOccurrences(of: "\n", with: " "))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        if let v = link(chroma?.streamedVideo) {
                            Button {
                                videoURL = v
                            } label: {
                                Label("Watch variant", systemImage: "play.circle.fill")
                            }
                        }
                    }
                }

                if levels.count > 1 || levels.contains(where: { $0.streamedVideo != nil }) {
                    Section("Upgrade levels") {
                        ForEach(Array(levels.enumerated()), id: \.offset) { index, level in
                            HStack {
                                Text("\(index + 1)")
                                    .font(.caption.monospaced().weight(.bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 24, height: 24)
                                    .background(VW.red.gradient, in: Circle())
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(level.itemName).font(.body)
                                    if let n = level.displayName, n != skin.displayName {
                                        Text(n).font(.caption).foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                if let v = link(level.streamedVideo) {
                                    Button {
                                        videoURL = v
                                    } label: {
                                        Image(systemName: "play.circle.fill")
                                            .font(.title2)
                                            .foregroundStyle(VW.red)
                                    }
                                    .buttonStyle(.borderless)
                                    .accessibilityLabel("Play level \(index + 1) video")
                                }
                            }
                        }
                    }
                }

                if let weapon {
                    Section {
                        LabeledContent("Weapon", value: weapon.displayName)
                        LabeledContent("Variants", value: "\(max(chromas.count, 1))")
                        LabeledContent("Levels", value: "\(max(levels.count, 1))")
                    }
                }
            }
            .navigationTitle(skin.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Close")
                }
            }
            .sheet(item: Binding(get: { videoURL.map(VideoItem.init) }, set: { videoURL = $0?.url })) { item in
                VideoSheet(url: item.url)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

struct ChromaRing: View {
    let selected: Bool

    var body: some View {
        let color: Color = selected ? VW.red : Color.secondary.opacity(0.3)
        let width: CGFloat = selected ? 3 : 1
        RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(color, lineWidth: width)
    }
}

struct VideoItem: Identifiable {
    let url: URL
    var id: String { url.absoluteString }
}

struct VideoSheet: View {
    let url: URL
    @State private var player: AVPlayer?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if let player {
                VideoPlayer(player: player)
                    .aspectRatio(16 / 9, contentMode: .fit)
            } else {
                ProgressView().tint(.white)
            }
        }
        .onAppear {
            let p = AVPlayer(url: url)
            player = p
            p.play()
        }
        .onDisappear { player?.pause() }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
