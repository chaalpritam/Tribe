import SwiftUI

/// In-app city switcher (header "Change" affordance).
struct CitySwitcherSheet: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var cities: [Channel] = []
    @State private var search = ""
    @State private var loading = true
    @State private var workingId: String?

    var body: some View {
        NavigationStack {
            Group {
                if loading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredCities) { city in
                        Button {
                            Task { await pick(city) }
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(city.displayName)
                                        .font(.headline)
                                        .foregroundStyle(Theme.textPrimary)
                                    Text(city.id)
                                        .font(.caption)
                                        .foregroundStyle(Theme.textSecondary)
                                }
                                Spacer()
                                if app.currentCity?.id == city.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Theme.primary)
                                }
                                if workingId == city.id {
                                    ProgressView()
                                }
                            }
                        }
                        .disabled(workingId != nil)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .searchable(text: $search, prompt: "Search cities")
            .navigationTitle("Choose your city")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .task { await load() }
        }
        .presentationDetents([.large])
    }

    private var filteredCities: [Channel] {
        let q = search.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return cities }
        return cities.filter {
            $0.displayName.lowercased().contains(q) || $0.id.lowercased().contains(q)
        }
    }

    private func load() async {
        loading = true
        defer { loading = false }
        let result = await app.loadCityOptions()
        cities = result.cities
    }

    private func pick(_ city: Channel) async {
        workingId = city.id
        defer { workingId = nil }
        await app.switchCity(to: city)
        dismiss()
    }
}
