import SwiftUI

struct AgentDetailView: View {
    @Environment(Store.self) private var store
    let agent: Agent
    @State private var abilityIndex = 0

    var body: some View {
        let abilities = agent.abilityList
        let neighbours = store.neighbours(of: agent)
        let mates = store.teammates(of: agent)
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                hero

                if let bio = agent.description, !bio.isEmpty {
                    Text(bio)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }

                if let role = agent.role {
                    HStack(alignment: .top, spacing: 14) {
                        RemoteImage(link(role.displayIcon))
                            .frame(width: 28, height: 28)
                            .padding(8)
                            .background(VW.red.gradient, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(role.displayName).font(.headline)
                            if let d = role.description {
                                Text(d).font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .glassCard()
                    .padding(.horizontal)
                }

                if !abilities.isEmpty {
                    VStack(alignment: .leading, spacing: 14) {
                        SectionHeader("Abilities", detail: "\(abilities.count)")
                        GlassGroup(spacing: 8) {
                            HStack(spacing: 8) {
                                ForEach(Array(abilities.enumerated()), id: \.offset) { index, ability in
                                    let selected = index == abilityIndex
                                    Button {
                                        Haptics.select()
                                        withAnimation(.snappy) { abilityIndex = index }
                                    } label: {
                                        VStack(spacing: 6) {
                                            RemoteImage(link(ability.displayIcon))
                                                .frame(width: 28, height: 28)
                                                .colorMultiply(selected ? .white : .primary)
                                                .opacity(selected ? 1 : 0.6)
                                            Text(ability.key)
                                                .font(.caption.monospaced().weight(.bold))
                                                .foregroundStyle(selected ? .white : .secondary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .contentShape(Rectangle())
                                        .glassCard(cornerRadius: 16, tint: selected ? VW.red : nil, interactive: true)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel(ability.displayName ?? ability.key)
                                }
                            }
                        }
                        let ability = abilities[min(abilityIndex, abilities.count - 1)]
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Text(ability.key)
                                    .font(.caption.monospaced().weight(.bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 24, height: 24)
                                    .background(VW.red, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                                Text(ability.slotName.uppercased())
                                    .font(.caption.weight(.bold))
                                    .tracking(1)
                                    .foregroundStyle(.secondary)
                            }
                            Text(ability.displayName ?? "")
                                .font(VW.title(28))
                            Text(ability.description ?? "")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .glassCard()
                        .id(ability.id)
                        .transition(.blurReplace)
                    }
                    .padding(.horizontal)
                }

                if !mates.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader("More \(agent.roleName)s")
                            .padding(.horizontal)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(mates) { mate in
                                    NavigationLink(value: Route.agent(mate.uuid)) {
                                        AgentCard(agent: mate, height: 180)
                                            .frame(width: 130)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                GlassGroup(spacing: 10) {
                    HStack(spacing: 10) {
                        if let prev = neighbours.prev {
                            NeighbourButton(label: "Previous", name: prev.displayName, route: .agent(prev.uuid), leading: true)
                        }
                        if let next = neighbours.next {
                            NeighbourButton(label: "Next", name: next.displayName, route: .agent(next.uuid), leading: false)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .top)
        .navigationTitle(agent.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            agentGradient(agent)
            RemoteImage(link(agent.background), mode: .fit)
                .opacity(0.25)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            RemoteImage(agent.portrait, mode: .fill)
                .frame(height: 580)
                .offset(y: 70)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: UnitPoint(x: 0.5, y: 0.5), endPoint: .bottom)
            VStack(alignment: .leading, spacing: 4) {
                Text(agent.roleName.uppercased())
                    .font(.caption.weight(.bold))
                    .tracking(1.4)
                    .foregroundStyle(.white.opacity(0.85))
                Text(agent.displayName.uppercased())
                    .font(VW.title(72))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                if let dev = agent.developerName {
                    Text("Codename \(dev)")
                        .font(.caption.monospaced())
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding()
        }
        .frame(height: 540)
        .clipped()
    }
}

struct NeighbourButton: View {
    let label: String
    let name: String
    let route: Route
    let leading: Bool

    var body: some View {
        NavigationLink(value: route) {
            HStack {
                if leading { Image(systemName: "chevron.left").foregroundStyle(VW.red) }
                VStack(alignment: leading ? .leading : .trailing, spacing: 1) {
                    Text(label).font(.caption).foregroundStyle(.secondary)
                    Text(name).font(.headline)
                }
                .frame(maxWidth: .infinity, alignment: leading ? .leading : .trailing)
                if !leading { Image(systemName: "chevron.right").foregroundStyle(VW.red) }
            }
            .padding(14)
            .contentShape(Rectangle())
            .glassCard(interactive: true)
        }
        .buttonStyle(.plain)
    }
}
