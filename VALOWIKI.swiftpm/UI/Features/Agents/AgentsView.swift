import SwiftUI

struct AgentsView: View {
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Backdrop()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        SectionHeader(title: "Pick Your Poison", corner: "ROSTER // OPERATIVES")
                        AgentsGrid()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 44)
                }
                .scrollIndicators(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
            .appRoutes()
        }
    }
}

struct AgentsGrid: View {
    @Environment(LibraryStore.self) private var store
    @State private var roleFilter = "ALL"

    private var roles: [String] {
        var seen = Set<String>()
        var order = ["ALL"]
        for agent in store.agents {
            if let role = agent.role?.displayName?.uppercased(), !seen.contains(role) {
                seen.insert(role)
                order.append(role)
            }
        }
        return order
    }

    private var filtered: [Agent] {
        guard roleFilter != "ALL" else { return store.agents }
        return store.agents.filter { $0.role?.displayName?.uppercased() == roleFilter }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(roles, id: \.self) { role in
                        Button {
                            Haptics.tap()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                roleFilter = role
                            }
                        } label: {
                            Chip(text: role, filled: roleFilter == role, color: roleFilter == role ? .valRed : .white)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollIndicators(.hidden)

            if filtered.isEmpty {
                EmptyState(title: "No Operatives", subtitle: "UPLINK MISSED /V1/AGENTS")
            } else {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    ForEach(filtered) { agent in
                        NavigationLink(value: agent) {
                            AgentCard(agent: agent)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct AgentCard: View {
    let agent: Agent

    private var gradient: LinearGradient {
        let colors = agent.gradientColors.compactMap { Color(hexString: $0) }
        return LinearGradient(
            colors: colors.isEmpty ? [Color(hex: 0x181820), Color(hex: 0x0C0C12)] : colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(gradient)
            DotMatrix(color: .white, spacing: 12, strength: 0.06)
            RemoteImage(url: agent.displayIcon ?? agent.displayIconSmall, contentMode: .fit)
                .padding(.horizontal, 16)
                .padding(.top, 20)
            LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 3) {
                Text(agent.displayName.uppercased())
                    .font(.display(24))
                    .foregroundStyle(.cream)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(agent.role?.displayName?.uppercased() ?? "AGENT")
                    .font(.mono(8, .semibold))
                    .tracking(1.6)
                    .foregroundStyle(.valRed)
            }
            .padding(14)
        }
        .frame(height: 190)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(Color.line))
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}
