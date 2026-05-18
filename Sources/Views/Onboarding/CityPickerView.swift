import SwiftUI

struct CityPickerView: View {
    @EnvironmentObject private var app: AppState

    @State private var cities: [Channel] = []
    @State private var selectedId: String?
    @State private var search = ""
    @State private var loading = true
    @State private var usedFallback = false
    @State private var fetchError: String?

    var body: some View {
        VStack(spacing: 0) {
            header
            if let fetchError {
                banner(
                    title: "Hub unreachable — showing default cities",
                    detail: fetchError,
                    showRetry: true
                )
            } else if usedFallback && !loading {
                banner(
                    title: "No city channels on hub — showing defaults",
                    detail: nil,
                    showRetry: true
                )
            }
            searchField
            cityList
            continueButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.pageBackground)
        .task { await loadCities() }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 48))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Theme.primary)
            .padding(.top, 24)
            Text("Choose your city")
                .font(.title2.bold())
            Text("Your feed and tribes are scoped to this neighborhood.")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .padding(.bottom, 16)
    }

    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Theme.textSecondary)
            TextField("Search cities…", text: $search)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Theme.surface)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    private var cityList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                if loading {
                    ProgressView()
                        .padding(.vertical, 40)
                } else {
                    ForEach(filteredCities) { city in
                        cityRow(city)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private var continueButton: some View {
        Button {
            guard let id = selectedId,
                  let city = cities.first(where: { $0.id == id }) else { return }
            app.selectCity(city)
        } label: {
            Text("Continue")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .buttonStyle(.borderedProminent)
        .tint(.primary)
        .disabled(selectedId == nil || loading)
        .padding(20)
    }

    private var filteredCities: [Channel] {
        let q = search.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return cities }
        return cities.filter {
            $0.displayName.lowercased().contains(q) || $0.id.lowercased().contains(q)
        }
    }

    private func cityRow(_ city: Channel) -> some View {
        let selected = selectedId == city.id
        return Button {
            selectedId = city.id
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
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.primary)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                    .fill(selected ? Theme.primary.opacity(0.08) : Theme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                    .strokeBorder(selected ? Theme.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private func banner(title: String, detail: String?, showRetry: Bool) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Theme.warning)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.footnote.weight(.semibold))
                if let detail {
                    Text(detail)
                        .font(.caption2)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            if showRetry {
                Spacer()
                Button("Retry") {
                    Task { await loadCities() }
                }
                .font(.caption.weight(.semibold))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Theme.warning.opacity(0.12))
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    private func loadCities() async {
        loading = true
        fetchError = nil
        defer { loading = false }
        let result = await app.loadCityOptions()
        cities = result.cities
        usedFallback = result.usedFallback
        fetchError = result.error
        if let saved = app.currentCity?.id, cities.contains(where: { $0.id == saved }) {
            selectedId = saved
        } else if let stored = UserDefaults.standard.string(forKey: "tribe.currentCityId"),
                  cities.contains(where: { $0.id == stored }) {
            selectedId = stored
        } else {
            selectedId = cities.first?.id
        }
    }
}
