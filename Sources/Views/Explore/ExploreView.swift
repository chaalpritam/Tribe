import MapKit
import SwiftUI

/// Hyperlocal discovery hub: map pins, people, tribes, and city-scoped
/// events, polls, tasks, and crowdfunds from the hub.
struct ExploreView: View {
    @EnvironmentObject private var app: AppState

    enum Filter: String, CaseIterable, Identifiable {
        case all, events, polls, tasks, crowdfunds, people, tribes
        var id: String { rawValue }
        var label: String {
            switch self {
            case .all: return "All"
            case .events: return "Events"
            case .polls: return "Polls"
            case .tasks: return "Tasks"
            case .crowdfunds: return "Funds"
            case .people: return "People"
            case .tribes: return "Tribes"
            }
        }
        var symbol: String {
            switch self {
            case .all: return "sparkles"
            case .events: return "calendar"
            case .polls: return "chart.bar.fill"
            case .tasks: return "checklist"
            case .crowdfunds: return "heart.circle.fill"
            case .people: return "person.2.fill"
            case .tribes: return "number"
            }
        }
    }

    @State private var filter: Filter = .all
    @State private var searchText = ""
    @State private var users: [User] = []
    @State private var events: [Event] = []
    @State private var polls: [Poll] = []
    @State private var tasks: [TaskItem] = []
    @State private var crowdfunds: [Crowdfund] = []
    @State private var channels: [Channel] = []
    @State private var loading = true
    @State private var error: String?
    @State private var selectedTribe: Channel?
    @State private var mapSelection: ExploreMapPin?
    @State private var cameraPosition: MapCameraPosition = .automatic

    private var cityId: String? { app.currentCity?.id }
    private var cityName: String { app.currentCity?.displayName ?? "Your city" }
    private var query: String { searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }

    private var tribeChannels: [Channel] {
        channels.filter { !$0.isCity }
    }

    private var mapPins: [ExploreMapPin] {
        var pins: [ExploreMapPin] = []
        for event in scopedEvents where event.latitude != nil && event.longitude != nil {
            pins.append(ExploreMapPin(
                id: "event:\(event.id)",
                kind: .event,
                title: event.title,
                subtitle: event.locationText ?? "Event",
                coordinate: CLLocationCoordinate2D(latitude: event.latitude!, longitude: event.longitude!)
            ))
        }
        for channel in channels where channel.isCity {
            guard let lat = channel.latitude, let lng = channel.longitude else { continue }
            pins.append(ExploreMapPin(
                id: "city:\(channel.id)",
                kind: .city,
                title: channel.displayName,
                subtitle: "City channel",
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng)
            ))
        }
        return pins
    }

    private var scopedEvents: [Event] { scoped(events) { $0.channelId } }
    private var scopedPolls: [Poll] { scoped(polls) { $0.channelId } }
    private var scopedTasks: [TaskItem] { scoped(tasks) { $0.channelId } }
    private var scopedCrowdfunds: [Crowdfund] { scoped(crowdfunds) { $0.channelId } }

    private var filteredEvents: [Event] {
        scopedEvents.filter { matchesSearch($0.title) }
    }
    private var filteredPolls: [Poll] {
        scopedPolls.filter { matchesSearch($0.question) }
    }
    private var filteredTasks: [TaskItem] {
        scopedTasks.filter { matchesSearch($0.title) || matchesSearch($0.description) }
    }
    private var filteredCrowdfunds: [Crowdfund] {
        scopedCrowdfunds.filter { matchesSearch($0.title) }
    }
    private var filteredUsers: [User] {
        users.filter {
            query.isEmpty
            || matchesSearch($0.displayName)
            || matchesSearch($0.username)
        }
    }
    private var filteredTribes: [Channel] {
        tribeChannels.filter {
            query.isEmpty
            || matchesSearch($0.displayName)
            || matchesSearch($0.id)
        }
    }

    private var everythingEmpty: Bool {
        filteredEvents.isEmpty && filteredPolls.isEmpty && filteredTasks.isEmpty
            && filteredCrowdfunds.isEmpty && filteredUsers.isEmpty && filteredTribes.isEmpty
    }

    var body: some View {
        Group {
            if loading, everythingEmpty, users.isEmpty, events.isEmpty {
                loadingState
            } else if let error, everythingEmpty {
                EmptyStateView(
                    symbol: "wifi.exclamationmark",
                    title: "Couldn't load Explore",
                    message: error,
                    retryTitle: "Retry",
                    onRetry: { Task { await refresh() } }
                )
            } else if everythingEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 20, pinnedViews: []) {
                        cityHeader
                        mapSection
                        filterBar
                        contentSections
                    }
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
            }
        }
        .background(Color(.systemGroupedBackground))
        .searchable(text: $searchText, prompt: "Search \(cityName)")
        .refreshable { await refresh() }
        .task(id: cityId) { await refresh() }
        .navigationDestination(item: $selectedTribe) { tribe in
            HomeFeedView(channelId: tribe.id)
                .environmentObject(app.interactions)
                .navigationTitle(tribe.displayName)
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Header

    private var cityHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(cityName)
                    .font(.title2.weight(.bold))
                Text("Discover people, tribes, and local activity")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 8) {
                headerStat(value: filteredEvents.count, label: "Events", tint: Theme.accentEmerald)
                headerStat(value: filteredTribes.count, label: "Tribes", tint: Theme.brand)
                headerStat(value: filteredUsers.count, label: "People", tint: Theme.accentIndigo)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Theme.cardStroke.opacity(0.35), lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func headerStat(value: Int, label: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(value)")
                .font(.headline.weight(.bold))
                .foregroundStyle(tint)
                .monospacedDigit()
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(tint.opacity(0.1))
        )
    }

    // MARK: - Map

    @ViewBuilder
    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Nearby on the map", systemImage: "map.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.brand)
                .padding(.horizontal, 16)

            Group {
                if mapPins.isEmpty {
                    ZStack {
                        Theme.avatarGradient(seed: "map-\(cityName)")
                            .opacity(0.35)
                        VStack(spacing: 6) {
                            Image(systemName: "mappin.slash")
                                .font(.title2)
                            Text("No map pins in \(cityName) yet")
                                .font(.footnote.weight(.medium))
                        }
                        .foregroundStyle(.secondary)
                    }
                } else {
                    Map(position: $cameraPosition, selection: Binding(
                        get: { mapSelection?.id },
                        set: { id in mapSelection = mapPins.first { $0.id == id } }
                    )) {
                        ForEach(mapPins) { pin in
                            Marker(pin.title, systemImage: pin.kind.symbol, coordinate: pin.coordinate)
                                .tint(pin.kind.tint)
                                .tag(pin.id)
                        }
                    }
                    .mapStyle(.standard(elevation: .flat))
                    .overlay(alignment: .bottom) {
                        if let pin = mapSelection {
                            mapPinCard(pin)
                                .padding(12)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 16)
        }
    }

    private func mapPinCard(_ pin: ExploreMapPin) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: pin.kind.symbol)
                    .foregroundStyle(pin.kind.tint)
                Text(pin.kind.label)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                Spacer()
                Button { mapSelection = nil } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.tertiary)
                }
            }
            Text(pin.title)
                .font(.headline.weight(.bold))
            Text(pin.subtitle)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Filters

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Filter.allCases) { item in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) { filter = item }
                    } label: {
                        Label(item.label, systemImage: item.symbol)
                            .font(.subheadline.weight(filter == item ? .semibold : .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().fill(filter == item ? Theme.brand : Theme.chipBackground)
                            )
                            .foregroundStyle(filter == item ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private var contentSections: some View {
        if filter == .all || filter == .events, !filteredEvents.isEmpty {
            exploreSection(
                title: "Upcoming events",
                symbol: "calendar",
                tint: Theme.accentEmerald,
                destination: ExploreEventsList(events: filteredEvents)
            ) {
                VStack(spacing: 8) {
                    ForEach(filteredEvents.prefix(3)) { event in
                        ExploreEventPreview(event: event)
                            .padding(.horizontal, 16)
                    }
                }
            }
        }

        if filter == .all || filter == .polls, !filteredPolls.isEmpty {
            exploreSection(
                title: "Live polls",
                symbol: "chart.bar.fill",
                tint: Theme.accentIndigo,
                destination: ExplorePollsList(polls: filteredPolls)
            ) {
                VStack(spacing: 8) {
                    ForEach(filteredPolls.prefix(3)) { poll in
                        ExplorePollPreview(poll: poll)
                            .padding(.horizontal, 16)
                    }
                }
            }
        }

        if filter == .all || filter == .tasks, !filteredTasks.isEmpty {
            exploreSection(
                title: "Open tasks",
                symbol: "checklist",
                tint: Theme.warning,
                destination: ExploreTasksList(tasks: filteredTasks)
            ) {
                VStack(spacing: 8) {
                    ForEach(filteredTasks.prefix(3)) { task in
                        ExploreTaskPreview(task: task)
                            .padding(.horizontal, 16)
                    }
                }
            }
        }

        if filter == .all || filter == .crowdfunds, !filteredCrowdfunds.isEmpty {
            exploreSection(
                title: "Active crowdfunds",
                symbol: "heart.circle.fill",
                tint: Theme.accentRose,
                destination: ExploreCrowdfundsList(crowdfunds: filteredCrowdfunds)
            ) {
                VStack(spacing: 8) {
                    ForEach(filteredCrowdfunds.prefix(3)) { fund in
                        ExploreCrowdfundPreview(crowdfund: fund)
                            .padding(.horizontal, 16)
                    }
                }
            }
        }

        if filter == .all || filter == .people, !filteredUsers.isEmpty {
            exploreSection(
                title: "People nearby",
                symbol: "person.2.fill",
                tint: Theme.brand,
                destination: ExplorePeopleList(users: filteredUsers)
            ) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(filteredUsers.prefix(8)) { user in
                            ExplorePersonCard(user: user)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }

        if filter == .all || filter == .tribes, !filteredTribes.isEmpty {
            exploreSection(
                title: "Tribes in \(cityName)",
                symbol: "number",
                tint: Theme.accentTeal,
                destination: ExploreTribesList(
                    tribes: filteredTribes,
                    onSelect: { selectedTribe = $0 }
                )
            ) {
                VStack(spacing: 8) {
                    ForEach(filteredTribes.prefix(4)) { tribe in
                        Button { selectedTribe = tribe } label: {
                            ExploreTribeRow(channel: tribe, joined: app.isJoined(channelId: tribe.id))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
    }

    private var loadingState: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.tertiarySystemFill))
                    .frame(height: 100)
                    .padding(.horizontal, 16)
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.tertiarySystemFill))
                    .frame(height: 200)
                    .padding(.horizontal, 16)
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.tertiarySystemFill))
                        .frame(height: 84)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 12)
        }
        .redacted(reason: .placeholder)
    }

    private var emptyState: some View {
        EmptyStateView(
            symbol: "sparkles",
            title: "Nothing to explore yet",
            message: "As neighbors post events, polls, tasks, and tribes in \(cityName), they'll show up here."
        )
    }

    // MARK: - Data

    private func scoped<T>(_ items: [T], channel: (T) -> String?) -> [T] {
        guard let cityId else { return items }
        return items.filter { ChannelScope.matches(cityId: cityId, channelId: channel($0)) }
    }

    private func matchesSearch(_ text: String?) -> Bool {
        guard !query.isEmpty else { return true }
        return text?.lowercased().contains(query) == true
    }

    @MainActor
    private func refresh() async {
        loading = users.isEmpty && events.isEmpty
        error = nil
        defer { loading = false }

        async let usersTask = (try? await app.api.fetchUsers(limit: 24)) ?? []
        async let eventsTask = (try? await app.api.fetchEvents(upcomingOnly: true)) ?? []
        async let pollsTask = (try? await app.api.fetchPolls()) ?? []
        async let tasksTask = (try? await app.api.fetchTasks()) ?? []
        async let fundsTask = (try? await app.api.fetchCrowdfunds()) ?? []
        async let channelsTask = (try? await app.api.fetchChannels()) ?? []

        users = await usersTask
        events = await eventsTask
        polls = await pollsTask
        tasks = await tasksTask
        crowdfunds = await fundsTask
        channels = await channelsTask

        for user in users {
            if let raw = user.profile?.pfpUrl, let url = app.api.resolveMediaURL(raw) {
                app.userAvatars.record(tid: user.tid, pfpUrl: url)
            }
        }
        recenterMapIfNeeded()
    }

    private func recenterMapIfNeeded() {
        guard !mapPins.isEmpty else { return }
        let lats = mapPins.map(\.coordinate.latitude)
        let lngs = mapPins.map(\.coordinate.longitude)
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

// MARK: - Section chrome

private func exploreSection<Content: View, Destination: View>(
    title: String,
    symbol: String,
    tint: Color,
    destination: Destination,
    @ViewBuilder content: () -> Content
) -> some View {
    VStack(alignment: .leading, spacing: 12) {
        HStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(tint.opacity(0.15))
                Image(systemName: symbol)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(tint)
            }
            .frame(width: 26, height: 26)

            Text(title)
                .font(.title3.weight(.bold))

            Spacer()

            NavigationLink {
                destination
            } label: {
                HStack(spacing: 2) {
                    Text("See all")
                        .font(.subheadline.weight(.medium))
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(Theme.brand)
            }
        }
        .padding(.horizontal, 16)

        content()
    }
}

// MARK: - Map pin model

private struct ExploreMapPin: Identifiable, Hashable {
    enum Kind: Hashable {
        case event, city
        var symbol: String {
            switch self {
            case .event: return "calendar"
            case .city: return "building.2.fill"
            }
        }
        var tint: Color {
            switch self {
            case .event: return Theme.accentEmerald
            case .city: return Theme.brand
            }
        }
        var label: String {
            switch self {
            case .event: return "Event"
            case .city: return "City"
            }
        }
    }

    let id: String
    let kind: Kind
    let title: String
    let subtitle: String
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: ExploreMapPin, rhs: ExploreMapPin) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
