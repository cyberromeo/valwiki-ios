import SwiftUI

struct AgentsView: View {
    @Environment(Store.self) private var store
    @State private var role = "All"
    @State private var query = ""

    private var roles: [String] {
        let present = Set(store.agents.map { $0.roleName })
        return ["All"] + Store.roleOrder.filter { present.contains($0) } + present.subtracting(Store.roleOrder).sorted()
    }

    private var filtered: [Agent] {
        store.agents.filter { a in
            (role == "All" || a.roleName == role) &&
            (query.isEmpty || a.displayName.localizedCaseInsensitiveContains(query) || a.roleName.localizedCaseInsensitiveContains(query))
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ScrollView(.horizontal, showsIndicators: false) {
                    GlassGroup(spacing: 8) {
                        HStack(spacing: 8) {
                            ForEach(roles, id: \.self) { r in
                                FilterChip(title: r, systemImage: icon(for: r), selected: role == r) {
                                    withAnimation(.snappy) { role = r }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 2)
                    }
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                    ForEach(filtered) { agent in
                        NavigationLink(value: Route.agent(agent.uuid)) {
                            AgentCard(agent: agent)
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
        .navigationTitle("Agents")
        .navigationSubtitleIfAvailable("\(filtered.count) of \(store.agents.count) · \(role == "All" ? "every role" : role + "s")")
        .searchable(text: $query, prompt: "Find an agent")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Role", selection: $role.animation(.snappy)) {
                        ForEach(roles, id: \.self) { r in
                            Label(r, systemImage: icon(for: r)).tag(r)
                        }
                    }
                } label: {
                    Image(systemName: role == "All" ? "line.3.horizontal.decrease" : "line.3.horizontal.decrease.circle.fill")
                }
            }
        }
    }

    private func icon(for role: String) -> String {
        switch role {
        case "Duelist": return "flame.fill"
        case "Initiator": return "dot.radiowaves.left.and.right"
        case "Controller": return "cloud.fill"
        case "Sentinel": return "shield.fill"
        default: return "square.grid.2x2"
        }
    }
}

struct FilterChip: View {
    let title: String
    var systemImage: String? = nil
    var imageURL: URL? = nil
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.select()
            action()
        } label: {
            HStack(spacing: 6) {
                if let imageURL {
                    RemoteImage(imageURL).frame(width: 16, height: 16)
                } else if let systemImage {
                    Image(systemName: systemImage).font(.caption)
                }
                Text(title).font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(selected ? Color.white : Color.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .contentShape(Capsule())
            .glassCapsule(tint: selected ? VW.red : nil, interactive: true)
        }
        .buttonStyle(.plain)
    }
}

extension View {
    @ViewBuilder
    func navigationSubtitleIfAvailable(_ text: String) -> some View {
        if #available(iOS 26.0, *) {
            self.navigationSubtitle(text)
        } else {
            self
        }
    }
}

struct AgentCard: View {
    let agent: Agent
    var height: CGFloat = 230

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            agentGradient(agent)
            RemoteImage(link(agent.background), mode: .fill)
                .opacity(0.2)
            RemoteImage(agent.portrait, mode: .fill)
                .frame(height: height * 1.35)
                .offset(y: height * 0.12)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            HStack(spacing: 8) {
                RemoteImage(link(agent.role?.displayIcon))
                    .frame(width: 14, height: 14)
                VStack(alignment: .leading, spacing: 0) {
                    Text(agent.displayName)
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(agent.roleName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .glassCard(cornerRadius: 16)
            .padding(8)
        }
        .frame(height: height)
        .cardShape(24)
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
