import SwiftUI

struct SearchView: View {
    @Environment(LibraryStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private var hits: [SearchHit] {
        store.searchHits(for: query)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Backdrop()
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.dim)
                            TextField("SEARCH THE RANGE", text: $query)
                                .font(.mono(12))
                                .tracking(1)
                                .foregroundStyle(.cream)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.panel))
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Color.line))
                        Button {
                            Haptics.tap()
                            dismiss()
                        } label: {
                            Text("EXIT")
                                .font(.mono(10, .bold))
                                .tracking(1.5)
                                .foregroundStyle(.valRed)
                        }
                        .buttonStyle(.plain)
                    }

                    if query.trimmingCharacters(in: .whitespaces).count < 2 {
                        Spacer()
                        EmptyState(title: "Search the Range", subtitle: "AGENTS // MAPS // WEAPONS // SKINS // BUDDIES // CARDS // SPRAYS // TITLES")
                        Spacer()
                    } else if hits.isEmpty {
                        Spacer()
                        EmptyState(title: "No Hits", subtitle: "THE SPIKE SITE IS QUIET")
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(hits) { hit in
                                    if let route = hit.route {
                                        NavigationLink(value: route) {
                                            SearchRow(hit: hit)
                                        }
                                        .buttonStyle(.plain)
                                    } else {
                                        SearchRow(hit: hit)
                                    }
                                }
                            }
                            .padding(.bottom, 30)
                        }
                        .scrollIndicators(.hidden)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .toolbar(.hidden, for: .navigationBar)
            .appRoutes()
        }
        .preferredColorScheme(.dark)
    }
}

struct SearchRow: View {
    let hit: SearchHit

    var body: some View {
        HStack(spacing: 12) {
            RemoteImage(url: hit.image, contentMode: .fit)
                .frame(width: 40, height: 40)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.panelHi))
            VStack(alignment: .leading, spacing: 2) {
                Text(hit.title.uppercased())
                    .font(.display(19))
                    .foregroundStyle(.cream)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(hit.subtitle.uppercased())
                    .font(.mono(7.5, .semibold))
                    .tracking(1.2)
                    .foregroundStyle(.dim)
                    .lineLimit(1)
            }
            Spacer()
            Text(hit.kind)
                .font(.mono(8, .bold))
                .tracking(1.2)
                .foregroundStyle(.black)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.valRed))
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.panel))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Color.line))
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
