import SwiftUI

struct SkinDetailView: View {
    let skin: WeaponSkin

    @State private var renderURL: URL?
    @State private var chromaIndex = 0

    var body: some View {
        ZStack {
            Backdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    hero
                    metaCard
                    if let chromas = skin.chromas, chromas.count > 1 {
                        chromaPicker(chromas)
                    }
                    if let levels = skin.levels, !levels.isEmpty {
                        levelsList(levels)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 50)
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            renderURL = skin.heroRender
        }
    }

    private var hero: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.panel)
            GlowBlob(color: ContentTierMapper.color(for: skin.contentTierUuid).opacity(0.4), size: 240, offsetX: 40, offsetY: -20)
            DotMatrix(color: .white, spacing: 12, strength: 0.07)
            RemoteImage(url: renderURL, contentMode: .fit)
                .frame(height: 210)
                .frame(maxWidth: .infinity)
                .id(renderURL)
                .transition(.opacity)
            Chip(text: ContentTierMapper.name(for: skin.contentTierUuid) ?? "STANDARD", filled: true, color: ContentTierMapper.color(for: skin.contentTierUuid))
                .padding(14)
        }
        .frame(height: 270)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).strokeBorder(Color.line))
    }

    private var metaCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("EDITION")
                .font(.mono(9, .bold))
                .tracking(2.4)
                .foregroundStyle(.dim)
            Text(skin.displayName.uppercased())
                .font(.display(32))
                .foregroundStyle(.cream)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 8) {
                Chip(text: "CHROMAS \(skin.chromas?.count ?? 0)", color: .mint)
                Chip(text: "LEVELS \(skin.levels?.count ?? 0)", color: .gold)
            }
        }
        .panelCard()
    }

    private func chromaPicker(_ chromas: [SkinChroma]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("COLORWAYS")
                .font(.mono(9, .bold))
                .tracking(2.4)
                .foregroundStyle(.dim)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(chromas.enumerated()), id: \.element.id) { index, chroma in
                        let active = index == chromaIndex
                        Button {
                            Haptics.tap()
                            withAnimation(.easeInOut(duration: 0.25)) {
                                chromaIndex = index
                                renderURL = chroma.fullRender ?? chroma.displayIcon ?? renderURL
                            }
                        } label: {
                            VStack(spacing: 4) {
                                RemoteImage(url: chroma.preview, contentMode: .fit)
                                    .frame(width: 44, height: 44)
                            }
                            .padding(6)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.panelHi))
                            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(active ? Color.valRed : Color.line, lineWidth: active ? 2 : 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private func levelsList(_ levels: [SkinLevel]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("UPGRADE LADDER")
                .font(.mono(9, .bold))
                .tracking(2.4)
                .foregroundStyle(.dim)
            ForEach(Array(levels.enumerated()), id: \.element.id) { index, level in
                HStack(spacing: 12) {
                    Text("LV\(index + 1)")
                        .font(.mono(10, .bold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color.valRed))
                    RemoteImage(url: level.displayIcon, contentMode: .fit)
                        .frame(width: 64, height: 30)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(level.displayName.uppercased())
                            .font(.mono(9.5, .bold))
                            .tracking(0.8)
                            .foregroundStyle(.cream)
                            .lineLimit(1)
                        Text(level.levelItemName)
                            .font(.mono(7.5, .semibold))
                            .tracking(1.4)
                            .foregroundStyle(.valRed)
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
