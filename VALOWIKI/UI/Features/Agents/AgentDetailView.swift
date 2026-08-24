import SwiftUI
import AVFoundation

struct AgentDetailView: View {
    let agent: Agent

    @State private var abilityIndex = 0
    @State private var voicePlayer: AVPlayer?
    @State private var playingVoice = false

    private var abilities: [AgentAbility] { agent.abilities ?? [] }

    private var currentAbility: AgentAbility? {
        abilities.indices.contains(abilityIndex) ? abilities[abilityIndex] : nil
    }

    private var gradient: LinearGradient {
        let colors = agent.gradientColors.compactMap { Color(hexString: $0) }
        return LinearGradient(
            colors: colors.isEmpty ? [Color(hex: 0x1A1A24), Color(hex: 0x0B0B10)] : colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            Backdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    hero
                    roleCard
                    bioCard
                    if !abilities.isEmpty {
                        abilityPicker
                        abilityPanel
                    }
                    voiceCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 50)
            }
            .scrollIndicators(.hidden)
        }
        .onDisappear {
            voicePlayer?.pause()
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(gradient)
            RemoteImage(url: agent.background, contentMode: .fill)
                .opacity(0.5)
            GlowBlob(color: .white.opacity(0.3), size: 220, offsetX: -80, offsetY: -110)
            RemoteImage(url: agent.portrait, contentMode: .fill)
                .padding(.top, 30)
                .padding(.horizontal, 24)
            LinearGradient(colors: [.clear, .ink.opacity(0.92)], startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 4) {
                Text("ROLE // \(agent.role?.displayName?.uppercased() ?? "AGENT")")
                    .font(.mono(9, .bold))
                    .tracking(2)
                    .foregroundStyle(.valRed)
                Text(agent.displayName.uppercased())
                    .font(.display(48))
                    .foregroundStyle(.cream)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack {
                HStack(alignment: .top) {
                    CornerTag(text: "VALOWIKI DOSSIER")
                    Spacer()
                    CornerTag(text: "DEV // \(agent.developerName ?? "???")")
                }
                .padding(16)
                Spacer()
            }
        }
        .frame(height: 410)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).strokeBorder(Color.line))
    }

    @ViewBuilder
    private var roleCard: some View {
        if let role = agent.role {
            HStack(spacing: 12) {
                RemoteImage(url: role.displayIcon, contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.valRed.opacity(0.14)))
                VStack(alignment: .leading, spacing: 2) {
                    Text(role.displayName?.uppercased() ?? "AGENT")
                        .font(.mono(11, .bold))
                        .tracking(1.6)
                        .foregroundStyle(.cream)
                    Text(role.description ?? "")
                        .font(.mono(8.5))
                        .tracking(0.4)
                        .foregroundStyle(.dim)
                        .lineLimit(2)
                }
                Spacer()
            }
            .panelCard()
        }
    }

    private var bioCard: some View {
        Text(agent.description ?? "CLASSIFIED.")
            .font(.mono(11))
            .tracking(0.4)
            .foregroundStyle(.white.opacity(0.78))
            .lineSpacing(5)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.panel))
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(Color.valRed)
                    .frame(width: 3)
                    .padding(.vertical, 16)
            }
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Color.line))
    }

    private var abilityPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("LOADOUT")
                .font(.mono(9, .bold))
                .tracking(2.4)
                .foregroundStyle(.dim)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(abilities.enumerated()), id: \.offset) { index, ability in
                        let active = index == abilityIndex
                        Button {
                            Haptics.tap()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                abilityIndex = index
                            }
                        } label: {
                            HStack(spacing: 8) {
                                if let icon = ability.displayIcon {
                                    RemoteImage(url: icon, contentMode: .fit)
                                        .frame(width: 20, height: 20)
                                }
                                Text(ability.displayName?.uppercased() ?? ability.slot?.cleanedEnum.uppercased() ?? "ABILITY")
                                    .font(.mono(9, .bold))
                                    .tracking(1.2)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 9)
                            .background(Capsule().fill(active ? Color.valRed : Color.panel))
                            .foregroundStyle(active ? Color.black : Color.cream)
                            .overlay(Capsule().strokeBorder(active ? Color.clear : Color.line))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    @ViewBuilder
    private var abilityPanel: some View {
        if let ability = currentAbility {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.panel)
                DotMatrix(color: .white, spacing: 12, strength: 0.09)
                HStack(alignment: .top, spacing: 14) {
                    RemoteImage(url: ability.displayIcon, contentMode: .fit)
                        .frame(width: 46, height: 46)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.valRed.opacity(0.14)))
                        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.valRed.opacity(0.5)))
                    VStack(alignment: .leading, spacing: 7) {
                        Text(ability.displayName?.uppercased() ?? "ABILITY")
                            .font(.display(24))
                            .foregroundStyle(.cream)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text(ability.slot?.cleanedEnum.uppercased() ?? "SLOT")
                            .font(.mono(8, .bold))
                            .tracking(2)
                            .foregroundStyle(.valRed)
                        Text(ability.description ?? "")
                            .font(.mono(10.5))
                            .tracking(0.3)
                            .foregroundStyle(.white.opacity(0.72))
                            .lineSpacing(4)
                    }
                    Spacer(minLength: 0)
                }
                .padding(16)
            }
            .frame(minHeight: 175)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(Color.line))
            .id(abilityIndex)
            .transition(.opacity)
        }
    }

    @ViewBuilder
    private var voiceCard: some View {
        if let url = agent.voiceLineURL {
            Button {
                toggleVoice(url)
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(playingVoice ? Color.valRed : Color.cream)
                            .frame(width: 42, height: 42)
                        Image(systemName: playingVoice ? "pause.fill" : "play.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(playingVoice ? "NOW SOUNDING OFF" : "PLAY VOICE LINE")
                            .font(.mono(10, .bold))
                            .tracking(1.6)
                            .foregroundStyle(.cream)
                        Text("AUDIO // \(agent.displayName.uppercased())")
                            .font(.mono(8))
                            .tracking(1.4)
                            .foregroundStyle(.dim)
                    }
                    Spacer()
                    Image(systemName: "waveform")
                        .foregroundStyle(.valRed)
                }
                .panelCard()
            }
            .buttonStyle(.plain)
        }
    }

    private func toggleVoice(_ url: URL) {
        Haptics.tap()
        if playingVoice {
            voicePlayer?.pause()
            playingVoice = false
            return
        }
        let player = AVPlayer(url: url)
        voicePlayer = player
        player.play()
        playingVoice = true
    }
}
