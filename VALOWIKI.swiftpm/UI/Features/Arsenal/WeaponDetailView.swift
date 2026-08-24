import SwiftUI

struct WeaponDetailView: View {
    let weapon: Weapon

    var body: some View {
        ZStack {
            Backdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    hero
                    if let stats = weapon.weaponStats {
                        statsCard(stats)
                    }
                    if let ranges = weapon.weaponStats?.damageRanges, !ranges.isEmpty {
                        damageCard(ranges)
                    }
                    if !weapon.shopSkins.isEmpty {
                        skinsRail(weapon.shopSkins)
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
            GlowBlob(color: .valRed.opacity(0.4), size: 220, offsetX: 60, offsetY: -40)
            GlowBlob(color: .mint.opacity(0.2), size: 180, offsetX: -80, offsetY: -80)
            DotMatrix(color: .white, spacing: 12, strength: 0.08)
            RemoteImage(url: weapon.displayIcon, contentMode: .fit)
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Chip(text: weapon.categoryName, filled: true)
                    if let cost = weapon.shopData?.cost {
                        Chip(text: "◉ \(cost)", color: .mint)
                    }
                }
                Text(weapon.displayName.uppercased())
                    .font(.display(40))
                    .foregroundStyle(.cream)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).strokeBorder(Color.line))
    }

    private func statsCard(_ stats: WeaponStats) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("BALLISTICS")
                .font(.mono(9, .bold))
                .tracking(2.4)
                .foregroundStyle(.dim)
            StatBar(label: "Fire Rate", value: String(format: "%.2f", stats.fireRateValue), fraction: stats.fireRateValue / 15)
            StatBar(label: "Magazine", value: "\(stats.magazineSize ?? 0) RND", fraction: Double(stats.magazineSize ?? 0) / 50)
            StatBar(label: "Equip Time", value: String(format: "%.1fs", stats.equipTimeValue), fraction: stats.equipTimeValue / 2.5)
            StatBar(label: "Reload", value: String(format: "%.1fs", stats.reloadTimeValue), fraction: stats.reloadTimeValue / 4, tint: .mint)
            HStack(spacing: 8) {
                Chip(text: "WALL PEN // \(stats.wallPenetrationName)")
                if let mode = stats.fireMode?.cleanedEnum {
                    Chip(text: "MODE // \(mode.uppercased())")
                }
                if let alt = stats.altFireType?.cleanedEnum {
                    Chip(text: "ALT // \(alt.uppercased())", color: .mint)
                }
            }
        }
        .panelCard()
    }

    private func damageCard(_ ranges: [DamageRange]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DAMAGE MATRIX")
                .font(.mono(9, .bold))
                .tracking(2.4)
                .foregroundStyle(.dim)
            HStack {
                Text("RANGE")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("HEAD")
                    .frame(maxWidth: .infinity)
                Text("BODY")
                    .frame(maxWidth: .infinity)
                Text("LEG")
                    .frame(maxWidth: .infinity)
            }
            .font(.mono(8, .bold))
            .tracking(1.4)
            .foregroundStyle(.faint)
            ForEach(Array(ranges.enumerated()), id: \.offset) { _, range in
                HStack {
                    Text(range.label)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(range.head > 0 ? String(format: "%.0f", range.head) : "—")
                        .foregroundStyle(.valRed)
                        .frame(maxWidth: .infinity)
                    Text(range.body > 0 ? String(format: "%.0f", range.body) : "—")
                        .foregroundStyle(.cream)
                        .frame(maxWidth: .infinity)
                    Text(range.leg > 0 ? String(format: "%.0f", range.leg) : "—")
                        .foregroundStyle(.dim)
                        .frame(maxWidth: .infinity)
                }
                .font(.mono(11, .bold))
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.04)))
            }
        }
        .panelCard()
    }

    private func skinsRail(_ skins: [WeaponSkin]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text("SKIN VAULT")
                    .font(.mono(9, .bold))
                    .tracking(2.4)
                    .foregroundStyle(.dim)
                Rectangle().fill(Color.line).frame(height: 1)
                Text("\(skins.count)")
                    .font(.mono(9, .bold))
                    .foregroundStyle(.valRed)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(skins) { skin in
                        NavigationLink(value: skin) {
                            SkinMiniCard(skin: skin)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

struct SkinMiniCard: View {
    let skin: WeaponSkin

    var body: some View {
        VStack(spacing: 8) {
            RemoteImage(url: skin.displayIcon ?? skin.chromas?.first?.fullRender, contentMode: .fit)
                .frame(width: 130, height: 62)
            Text(skin.displayName.uppercased())
                .font(.mono(8, .semibold))
                .tracking(0.8)
                .foregroundStyle(.cream)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(height: 22)
            HStack(spacing: 4) {
                Circle()
                    .fill(ContentTierMapper.color(for: skin.contentTierUuid))
                    .frame(width: 6, height: 6)
                Text(ContentTierMapper.name(for: skin.contentTierUuid) ?? "STANDARD")
                    .font(.mono(7, .bold))
                    .tracking(1)
                    .foregroundStyle(.dim)
            }
        }
        .padding(10)
        .frame(width: 150)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.panel))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color.line))
    }
}
