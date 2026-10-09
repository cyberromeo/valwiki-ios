import SwiftUI

struct WeaponDetailView: View {
    @Environment(Store.self) private var store
    let weapon: Weapon
    @State private var selectedSkin: Skin?

    private var stats: WeaponStats? { weapon.weaponStats }

    var body: some View {
        let skins = weapon.realSkins
        List {
            Section {
                VStack(spacing: 14) {
                    RemoteImage(link(weapon.displayIcon))
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(weapon.categoryName.uppercased())
                                .font(.caption.weight(.bold))
                                .tracking(1.2)
                                .foregroundStyle(VW.red)
                            Text(weapon.displayName.uppercased())
                                .font(VW.title(44))
                        }
                        Spacer()
                        if weapon.cost > 0 {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(weapon.cost)")
                                    .font(VW.title(30))
                                Text("credits").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 4, bottom: 8, trailing: 4))
            }

            if let s = stats {
                Section("Handling") {
                    ForEach(handling(s)) { row in
                        StatGaugeRow(title: row.title, value: row.value, max: row.max, display: row.display, icon: row.icon)
                    }
                    if let wall = s.wallPenetration {
                        LabeledContent("Wall penetration") {
                            Text(enumTail(wall))
                        }
                    }
                    if let zoom = s.adsStats?.zoomMultiplier?.value, zoom > 0 {
                        LabeledContent("Zoom") { Text(formatNumber(zoom, decimals: 2) + "×") }
                    }
                    if let pellets = s.shotgunPelletCount?.value, pellets > 1 {
                        LabeledContent("Pellets") { Text(formatNumber(pellets)) }
                    }
                    if let mode = s.fireMode, !mode.isEmpty {
                        LabeledContent("Fire mode") { Text(enumTail(mode)) }
                    }
                    if let alt = s.altFireType, !alt.isEmpty {
                        LabeledContent("Alt fire") { Text(enumTail(alt)) }
                    }
                }

                let ranges = s.damageRanges?.items ?? []
                if !ranges.isEmpty {
                    Section("Damage by range") {
                        Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 10) {
                            GridRow {
                                Text("Range").gridColumnAlignment(.leading)
                                Text("Head").gridColumnAlignment(.trailing)
                                Text("Body").gridColumnAlignment(.trailing)
                                Text("Legs").gridColumnAlignment(.trailing)
                            }
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            Divider()
                            ForEach(ranges) { r in
                                let cells: [String] = damageCells(r)
                                GridRow {
                                    Text(cells[0])
                                    Text(cells[1]).foregroundStyle(VW.red).bold()
                                    Text(cells[2])
                                    Text(cells[3]).foregroundStyle(.secondary)
                                }
                                .monospacedDigit()
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            if !skins.isEmpty {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(skins.prefix(12)) { skin in
                                Button { selectedSkin = skin } label: {
                                    SkinTile(skin: skin, tier: store.tier(skin.contentTierUuid), compact: true)
                                        .frame(width: 170)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                    NavigationLink(value: Route.skins(weapon.uuid)) {
                        Label("All \(skins.count) skins", systemImage: "square.grid.2x2.fill")
                    }
                } header: {
                    Text("Skins")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(weapon.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedSkin) { skin in
            SkinDetailSheet(skin: skin, weapon: weapon)
        }
    }
}

struct HandlingRow: Identifiable {
    let title: String
    let value: Double
    let max: Double
    let display: String
    let icon: String
    var id: String { title }
}

func handling(_ s: WeaponStats) -> [HandlingRow] {
    let fire: Double = s.fireRate?.value ?? 0
    let mag: Double = s.magazineSize?.value ?? 0
    let reload: Double = s.reloadTimeSeconds?.value ?? 0
    let equip: Double = s.equipTimeSeconds?.value ?? 0
    let run: Double = (s.runSpeedMultiplier?.value ?? 0) * 100
    let spread: Double = s.firstBulletAccuracy?.value ?? 0
    var rows: [HandlingRow] = []
    rows.append(HandlingRow(title: "Fire rate", value: fire, max: 16, display: formatNumber(fire, decimals: 2) + " /s", icon: "speedometer"))
    rows.append(HandlingRow(title: "Magazine", value: mag, max: 100, display: formatNumber(mag), icon: "rectangle.stack.fill"))
    rows.append(HandlingRow(title: "Reload", value: reload, max: 5, display: formatNumber(reload, decimals: 2) + " s", icon: "arrow.triangle.2.circlepath"))
    rows.append(HandlingRow(title: "Equip", value: equip, max: 1.5, display: formatNumber(equip, decimals: 2) + " s", icon: "hand.raised.fill"))
    rows.append(HandlingRow(title: "Run speed", value: run, max: 100, display: formatNumber(run) + "%", icon: "figure.run"))
    rows.append(HandlingRow(title: "First-shot spread", value: spread, max: 5, display: formatNumber(spread, decimals: 2) + "°", icon: "scope"))
    return rows
}

struct StatGaugeRow: View {
    let title: String
    let value: Double
    let max: Double
    let display: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(title, systemImage: icon)
                Spacer()
                Text(display)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            let clamped: Double = Swift.min(Swift.max(value, 0), max)
            Gauge(value: clamped, in: 0...max) {
                EmptyView()
            }
            .gaugeStyle(.accessoryLinearCapacity)
            .tint(VW.red)
        }
        .padding(.vertical, 2)
    }
}

func damageCells(_ range: DamageRange) -> [String] {
    let start: String = formatNumber(range.rangeStartMeters?.value ?? 0)
    let end: String = formatNumber(range.rangeEndMeters?.value ?? 0)
    let head: String = formatNumber(range.headDamage?.value ?? 0, decimals: 1)
    let torso: String = formatNumber(range.bodyDamage?.value ?? 0, decimals: 1)
    let legs: String = formatNumber(range.legDamage?.value ?? 0, decimals: 1)
    return ["\(start)–\(end) m", head, torso, legs]
}
