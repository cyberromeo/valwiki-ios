import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case agents
    case maps
    case arsenal
    case more

    var id: String { rawValue }

    var label: String { rawValue.uppercased() }

    var icon: String {
        switch self {
        case .home: return "bolt.fill"
        case .agents: return "person.fill"
        case .maps: return "map.fill"
        case .arsenal: return "target"
        case .more: return "square.grid.2x2.fill"
        }
    }
}

struct FunkyTabBar: View {
    @Binding var tab: AppTab
    @Namespace private var indicator

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases) { item in
                tabButton(item)
            }
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.panel.opacity(0.94))
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(Color.line)
                }
                .shadow(color: .black.opacity(0.55), radius: 18, y: 8)
        }
    }

    private func tabButton(_ item: AppTab) -> some View {
        let active = tab == item
        return Button {
            Haptics.tap()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                tab = item
            }
        } label: {
            VStack(spacing: 3) {
                ZStack {
                    if active {
                        Capsule()
                            .fill(Color.valRed.opacity(0.16))
                            .matchedGeometryEffect(id: "tabGlow", in: indicator)
                    }
                    Image(systemName: item.icon)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(active ? Color.valRed : Color.dim)
                }
                .frame(height: 30)
                Text(item.label)
                    .font(.mono(8, .bold))
                    .tracking(1.4)
                    .foregroundStyle(active ? Color.cream : Color.faint)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
