import SwiftUI

struct MapsView: View {
    @Environment(LibraryStore.self) private var store

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Backdrop(blobColor: .mint)
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        SectionHeader(title: "Know Your Ground", corner: "RECON // \(store.maps.count) SITES")
                        MapsList()
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

struct MapsList: View {
    @Environment(LibraryStore.self) private var store

    var body: some View {
        LazyVStack(spacing: 14) {
            ForEach(store.maps) { map in
                NavigationLink(value: map) {
                    MapCard(map: map)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct MapCard: View {
    let map: GameMap

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RemoteImage(url: map.splash ?? map.listViewIconTall ?? map.listViewIcon, contentMode: .fill)
                .frame(height: 190)
                .frame(maxWidth: .infinity)
            LinearGradient(colors: [.clear, .black.opacity(0.88)], startPoint: .center, endPoint: .bottom)
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(map.displayName.uppercased())
                        .font(.display(30))
                        .foregroundStyle(.cream)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    if let tactical = map.tacticalDescription {
                        CornerTag(text: "TACTIC // \(tactical)", color: .valRed)
                    }
                }
                Spacer()
                if let coordinates = map.coordinates {
                    Text(coordinates)
                        .font(.mono(8))
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(1)
                }
            }
            .padding(14)
        }
        .frame(height: 190)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(Color.line))
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}
