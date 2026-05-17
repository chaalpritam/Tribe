import MapKit
import SwiftUI

struct MapView: View {
    @EnvironmentObject private var app: AppState

    enum MapFilter: String, CaseIterable, Identifiable {
        case all, people, places, events, reviews
        var id: String { rawValue }
        var label: String {
            switch self {
            case .all: return "All"
            case .people: return "People"
            case .places: return "Places"
            case .events: return "Events"
            case .reviews: return "Reviews"
            }
        }
        var symbol: String {
            switch self {
            case .all: return "map"
            case .people: return "person.2"
            case .places: return "storefront"
            case .events: return "calendar"
            case .reviews: return "star"
            }
        }
    }

    @State private var filter: MapFilter = .all
    @State private var searchText = ""
    @State private var channels: [Channel] = []
    @State private var events: [Event] = []
    @State private var loading = true
    @State private var selection: MapPin?
    @State private var cameraPosition: MapCameraPosition = .automatic

    private var pins: [MapPin] {
        var result: [MapPin] = []
        for ch in channels {
            guard let lat = ch.latitude, let lng = ch.longitude else { continue }
            result.append(MapPin(
                id: "channel:\(ch.id)",
                kind: .channel,
                title: ch.displayName,
                subtitle: ch.description ?? "City channel",
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng)
            ))
        }
        for ev in events {
            guard let lat = ev.latitude, let lng = ev.longitude else { continue }
            result.append(MapPin(
                id: "event:\(ev.id)",
                kind: .event,
                title: ev.title,
                subtitle: ev.locationText ?? "Event",
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng)
            ))
        }
        return result
    }

    private var cityName: String { app.currentCity?.displayName ?? "Local" }
    private var query: String { searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }

    private var places: [MapDummyData.Place] {
        MapDummyData.places(cityName: cityName).filter {
            query.isEmpty || $0.name.lowercased().contains(query) || $0.category.lowercased().contains(query)
        }
    }

    private var people: [MapDummyData.Person] {
        MapDummyData.people(cityName: cityName).filter {
            query.isEmpty || $0.displayName.lowercased().contains(query) || $0.username.lowercased().contains(query)
        }
    }

    private var reviews: [MapDummyData.Review] {
        MapDummyData.reviews(cityName: cityName).filter {
            query.isEmpty || $0.placeName.lowercased().contains(query) || $0.text.lowercased().contains(query)
        }
    }

    private var filteredEvents: [Event] {
        events.filter { query.isEmpty || $0.title.lowercased().contains(query) }
    }

    var body: some View {
        VStack(spacing: 0) {
            mapSection
            filterPills
            searchField
            listSection
        }
        .background(Color(red: 0.99, green: 0.99, blue: 0.99))
        .task { await refresh() }
        .refreshable { await refresh() }
    }

    private var mapSection: some View {
        Group {
            if loading, pins.isEmpty {
                ZStack {
                    Color.teal.opacity(0.08)
                    ProgressView()
                }
            } else if pins.isEmpty {
                ZStack {
                    LinearGradient(colors: [.teal.opacity(0.15), .blue.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    VStack(spacing: 6) {
                        Image(systemName: "map")
                            .font(.title)
                        Text("No pinned coordinates yet")
                            .font(.footnote.weight(.semibold))
                    }
                    .foregroundStyle(Theme.textSecondary)
                }
            } else {
                Map(position: $cameraPosition, selection: Binding(
                    get: { selection?.id },
                    set: { newId in selection = pins.first { $0.id == newId } }
                )) {
                    ForEach(pins) { pin in
                        Marker(pin.title, systemImage: pin.kind.symbol, coordinate: pin.coordinate)
                            .tint(pin.kind.tint)
                            .tag(pin.id)
                    }
                }
                .mapStyle(.standard(elevation: .flat))
                .overlay(alignment: .bottom) {
                    if let selection {
                        pinCard(selection)
                            .padding(16)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
        .frame(height: 240)
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }

    private var filterPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MapFilter.allCases) { f in
                    Button {
                        filter = f
                    } label: {
                        Label(f.label, systemImage: f.symbol)
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(filter == f ? Color.black : Color.white)
                            .foregroundStyle(filter == f ? .white : Theme.textPrimary)
                            .clipShape(Capsule())
                            .overlay(Capsule().strokeBorder(Color.black.opacity(0.08), lineWidth: filter == f ? 0 : 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Theme.textSecondary)
            TextField("Search map…", text: $searchText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private var listSection: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                if filter == .all || filter == .events {
                    if !filteredEvents.isEmpty {
                        listHeader("Events")
                        ForEach(filteredEvents) { event in
                            EventCardView(event: event)
                                .environmentObject(app)
                        }
                    }
                }
                if filter == .all || filter == .people {
                    if !people.isEmpty {
                        listHeader("People")
                        ForEach(people) { person in
                            dummyRow(title: person.displayName, subtitle: "@\(person.username)", symbol: "person.fill", tint: .indigo)
                        }
                    }
                }
                if filter == .all || filter == .places {
                    if !places.isEmpty {
                        listHeader("Places")
                        ForEach(places) { place in
                            dummyRow(title: place.name, subtitle: place.category, symbol: "storefront.fill", tint: .teal, trailing: place.emoji)
                        }
                    }
                }
                if filter == .all || filter == .reviews {
                    if !reviews.isEmpty {
                        listHeader("Reviews")
                        ForEach(reviews) { review in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(review.placeName)
                                    .font(.subheadline.weight(.bold))
                                Text(review.text)
                                    .font(.footnote)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
    }

    private func listHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline.weight(.bold))
            .padding(.top, 8)
    }

    private func dummyRow(title: String, subtitle: String, symbol: String, tint: Color, trailing: String? = nil) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.title3)
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func pinCard(_ pin: MapPin) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: pin.kind.symbol)
                    .foregroundStyle(pin.kind.tint)
                Text(pin.kind.label)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Button { selection = nil } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.tertiary)
                }
            }
            Text(pin.title)
                .font(.headline.weight(.bold))
            Text(pin.subtitle)
                .font(.footnote)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func refresh() async {
        loading = true
        defer { loading = false }
        async let ch = try? app.api.fetchChannels()
        async let ev = try? app.api.fetchEvents(upcomingOnly: true)
        channels = (await ch ?? []).filter(\.isCity)
        events = await ev ?? []
        if let cityId = app.currentCity?.id {
            events = events.filter { ChannelScope.matches(cityId: cityId, channelId: $0.channelId) }
        }
        recenterIfNeeded()
    }

    private func recenterIfNeeded() {
        guard !pins.isEmpty else { return }
        let lats = pins.map(\.coordinate.latitude)
        let lngs = pins.map(\.coordinate.longitude)
        let center = CLLocationCoordinate2D(
            latitude: (lats.min()! + lats.max()!) / 2,
            longitude: (lngs.min()! + lngs.max()!) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max(0.08, (lats.max()! - lats.min()!) * 1.5),
            longitudeDelta: max(0.08, (lngs.max()! - lngs.min()!) * 1.5)
        )
        cameraPosition = .region(MKCoordinateRegion(center: center, span: span))
    }
}

private struct MapPin: Identifiable, Hashable {
    enum Kind: Hashable {
        case channel, event
        var symbol: String {
            switch self {
            case .channel: return "number"
            case .event: return "calendar"
            }
        }
        var tint: Color {
            switch self {
            case .channel: return .green
            case .event: return .indigo
            }
        }
        var label: String {
            switch self {
            case .channel: return "City channel"
            case .event: return "Event"
            }
        }
    }

    let id: String
    let kind: Kind
    let title: String
    let subtitle: String
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: MapPin, rhs: MapPin) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
