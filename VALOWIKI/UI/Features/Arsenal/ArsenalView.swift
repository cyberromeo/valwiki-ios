import SwiftUI

struct ArsenalView: View {
    @State private var segment = 0

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Backdrop()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        SectionHeader(title: segment == 0 ? "Feel the Firepower" : "Skin Economy", corner: "ARMORY // LOCKED AND LOADED")
                        segmentSwitch
                        if segment == 0 {
                            WeaponList()
                        } else {
                            SkinsGallery()
                        }
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

    private var segmentSwitch: some View {
        HStack(spacing: 4) {
            segmentButton("GUNS", 0)
            segmentButton("SKINS", 1)
        }
        .padding(4)
        .background(Capsule().fill(Color.panel))
        .overlay(Capsule().strokeBorder(Color.line))
    }

    private func segmentButton(_ title: String, _ index: Int) -> some View {
        let active = segment == index
        return Button {
            Haptics.tap()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                segment = index
            }
        } label: {
            Text(title)
                .font(.mono(10, .bold))
                .tracking(2)
                .foregroundStyle(active ? Color.black : Color.cream)
                .padding(.horizontal, 22)
                .padding(.vertical, 9)
                .background(Capsule().fill(active ? Color.cream : Color.clear))
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

struct WeaponList: View {
    @Environment(LibraryStore.self) private var store

    private var groups: [(String, [Weapon])] {
        let order = ["Sidearm", "SMG", "Shotgun", "Rifle", "Sniper", "Heavy", "Melee"]
        let grouped = Dictionary(grouping: store.weapons) { $0.categoryName }
        var result: [(String, [Weapon])] = []
        for key in order {
            if let items = grouped[key] {
                result.append((key.uppercased(), items))
            }
        }
        for key in grouped.keys.sorted() where !order.contains(key) {
            if let items = grouped[key] {
                result.append((key.uppercased(), items))
            }
        }
        return result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(groups, id: \.0) { group in
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Text(group.0)
                            .font(.mono(10, .bold))
                            .tracking(2.4)
                            .foregroundStyle(.dim)
                        Rectangle().fill(Color.line).frame(height: 1)
                        Text("\(group.1.count)")
                            .font(.mono(9, .bold))
                            .foregroundStyle(.valRed)
                    }
                    VStack(spacing: 8) {
                        ForEach(group.1) { weapon in
                            NavigationLink(value: weapon) {
                                WeaponRow(weapon: weapon)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

struct WeaponRow: View {
    let weapon: Weapon

    var body: some View {
        HStack(spacing: 12) {
            RemoteImage(url: weapon.displayIcon, contentMode: .fit)
                .frame(width: 76, height: 34)
            VStack(alignment: .leading, spacing: 2) {
                Text(weapon.displayName.uppercased())
                    .font(.display(19))
                    .foregroundStyle(.cream)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(weapon.shopData?.categoryText?.uppercased() ?? weapon.categoryName.uppercased())
                    .font(.mono(8))
                    .tracking(1.4)
                    .foregroundStyle(.dim)
            }
            Spacer()
            if let cost = weapon.shopData?.cost {
                Text("\(cost)")
                    .font(.mono(11, .bold))
                    .foregroundStyle(.valRed)
            } else {
                Text("FREE")
                    .font(.mono(9, .bold))
                    .foregroundStyle(.faint)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.faint)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.panel))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color.line))
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
