import SwiftUI

struct GearList: View {
    @Environment(LibraryStore.self) private var store

    var body: some View {
        VStack(spacing: 10) {
            ForEach(store.gear) { item in
                HStack(spacing: 12) {
                    RemoteImage(url: item.displayIcon, contentMode: .fit)
                        .frame(width: 48, height: 48)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(item.displayName.uppercased())
                                .font(.display(21))
                                .foregroundStyle(.cream)
                                .lineLimit(1)
                            if let cost = item.shopData?.cost {
                                Chip(text: "◉ \(cost)", color: .mint)
                            }
                        }
                        Text(item.description ?? item.descriptions?.first ?? "STANDARD ISSUE")
                            .font(.mono(8.5))
                            .tracking(0.3)
                            .foregroundStyle(.dim)
                            .lineLimit(2)
                    }
                    Spacer()
                }
                .panelCard()
            }
        }
    }
}

struct VersionCard: View {
    @Environment(LibraryStore.self) private var store

    var body: some View {
        if let version = store.version {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 6) {
                    Circle().fill(Color.valRed).frame(width: 8, height: 8)
                    Circle().fill(Color.gold).frame(width: 8, height: 8)
                    Circle().fill(Color.mint).frame(width: 8, height: 8)
                    Spacer()
                    Text("LIVE BUILD")
                        .font(.mono(8, .bold))
                        .tracking(2)
                        .foregroundStyle(.dim)
                }
                Text(version.buildVersion ?? "?")
                    .font(.display(56))
                    .foregroundStyle(.cream)
                terminalRow("VERSION", version.version)
                terminalRow("BRANCH", version.branch)
                terminalRow("MANIFEST", version.manifestId)
                terminalRow("ENGINE", version.engineVersion)
                terminalRow("RIOT CLIENT", version.riotClientVersion)
                terminalRow("BUILT", version.buildDate)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color(hex: 0x050508)))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(Color.line))
        } else {
            EmptyState(title: "No Build Data", subtitle: "UPLINK MISSED /V1/VERSION")
        }
    }

    private func terminalRow(_ label: String, _ value: String?) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.mono(8.5, .semibold))
                .tracking(1.6)
                .foregroundStyle(.faint)
                .frame(width: 90, alignment: .leading)
            Text(value ?? "—")
                .font(.mono(9.5, .bold))
                .foregroundStyle(.mint)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Spacer()
        }
    }
}

struct RawFeed: View {
    @State private var selected = "agents"
    @State private var payload = ""
    @State private var loading = false

    static let feedPaths = [
        "agents", "maps", "weapons", "weapons/skins", "weapons/skinchromas",
        "weapons/skinlevels", "buddies", "buddies/levels", "playercards",
        "sprays", "sprays/levels", "playertitles", "currencies", "gamemodes",
        "gamemodes/equippables", "gear", "seasons", "competitivetiers",
        "contracts", "contenttiers", "bundles", "ceremonies", "themes",
        "events", "version"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(RawFeed.feedPaths, id: \.self) { path in
                        let active = selected == path
                        Button {
                            Haptics.tap()
                            selected = path
                        } label: {
                            Text("/" + path)
                                .font(.mono(8.5, .bold))
                                .tracking(0.8)
                                .foregroundStyle(active ? Color.black : Color.mint)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(Capsule().fill(active ? Color.mint : Color.panel))
                                .overlay(Capsule().strokeBorder(active ? Color.clear : Color.line))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollIndicators(.hidden)

            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(hex: 0x050508))
                if loading {
                    ProgressView()
                        .tint(.valRed)
                } else if payload.isEmpty {
                    Text("PICK A FEED")
                        .font(.mono(10, .bold))
                        .tracking(2)
                        .foregroundStyle(.faint)
                } else {
                    ScrollView {
                        Text(payload)
                            .font(.mono(9))
                            .foregroundStyle(Color(hex: 0x7CFF9B))
                            .lineSpacing(3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .textSelection(.enabled)
                    }
                }
            }
            .frame(minHeight: 380)
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Color.line))
        }
        .task(id: selected) {
            await load()
        }
    }

    private func load() async {
        loading = true
        defer { loading = false }
        do {
            let data = try await ValorantAPI.fetchRaw(selected)
            let object = try JSONSerialization.jsonObject(with: data)
            let pretty = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
            payload = String(data: pretty, encoding: .utf8) ?? "{}"
        } catch {
            payload = "// UPLINK ERROR: \(error.localizedDescription)"
        }
    }
}
