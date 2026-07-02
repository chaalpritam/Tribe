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
    @State private var members: [ChannelMember] = []
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
    @State private var debouncedSearchText = ""
    @State private var searchDebounceTask: Task<Void, Never>?
    @State private var searchResults = ExploreSearchResults()
    @State private var searchLoading = false
    @State private var profileRoute: ProfileRoute?
    @State private var mapItemRoute: ExploreItemRoute?
    @State private var showFullscreenMap = false
    @StateObject private var mapLocation = LocationProvider()

    private struct ProfileRoute: Identifiable, Hashable {
        let tid: String
        var id: String { tid }
    }

    private var scopeId: String? { app.activeChannel?.id }
    private var channelName: String { app.activeChannel?.displayName ?? "Your channel" }
    private var query: String { searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
    private var isHubSearchActive: Bool {
        debouncedSearchText.trimmingCharacters(in: .whitespacesAndNewlines).count >= ExploreSearch.minQueryLength
    }

    private var tribeChannels: [Channel] {
        if let active = app.activeChannel, !active.isCity {
            return [active]
        }
        return app.joinedChannels.filter { !$0.isCity }
    }

    private var mapPins: [ExploreMapPin] {
        ExploreMapPin.from(events: scopedEvents, channels: channels)
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
    private var filteredMembers: [ChannelMember] {
        members.filter {
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
            && filteredCrowdfunds.isEmpty && filteredMembers.isEmpty && filteredTribes.isEmpty
    }

    var body: some View {
        Group {
            if isHubSearchActive {
                ExploreSearchResultsView(
                    query: debouncedSearchText.trimmingCharacters(in: .whitespacesAndNewlines),
                    results: searchResults,
                    loading: searchLoading,
                    onSelectProfile: { profileRoute = ProfileRoute(tid: $0) },
                    onSelectTribe: { tribe in
                        app.setActiveChannel(tribe)
                        selectedTribe = tribe
                    }
                )
            } else if loading, everythingEmpty, members.isEmpty, events.isEmpty {
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
        .searchable(text: $searchText, prompt: "Search \(channelName)")
        .onChange(of: searchText) { _, newValue in
            searchDebounceTask?.cancel()
            searchDebounceTask = Task {
                try? await Task.sleep(nanoseconds: 300_000_000)
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    debouncedSearchText = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        .onChange(of: debouncedSearchText) { _, _ in
            Task { await runHubSearch() }
        }
        .refreshable {
            if isHubSearchActive {
                await runHubSearch()
            } else {
                await refresh()
            }
        }
        .task(id: app.activeChannel?.id) {
            await refresh()
            if isHubSearchActive { await runHubSearch() }
        }
        .navigationDestination(item: $selectedTribe) { tribe in
            HomeFeedView(channelId: tribe.id)
                .environmentObject(app.interactions)
                .navigationTitle(tribe.displayName)
                .navigationBarTitleDisplayMode(.inline)
        }
        .navigationDestination(item: $profileRoute) { route in
            UserProfileView(tid: route.tid)
                .environmentObject(app)
        }
        .navigationDestination(for: ExploreItemRoute.self) { route in
            ExploreItemDetailView(route: route)
                .environmentObject(app)
        }
        .navigationDestination(item: $mapItemRoute) { route in
            ExploreItemDetailView(route: route)
                .environmentObject(app)
        }
        .fullScreenCover(isPresented: $showFullscreenMap) {
            ExploreMapFullscreenView(
                channelName: channelName,
                emptyMessage: "No map pins in \(channelName) yet",
                pins: mapPins,
                events: scopedEvents,
                channels: channels,
                cameraPosition: $cameraPosition,
                selection: $mapSelection,
                location: mapLocation,
                onOpenEvent: openEventFromMap,
                onOpenCity: openCityFromMap
            )
        }
    }

    // MARK: - Header

    private var cityHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(channelName)
                    .font(.title2.weight(.bold))
                if app.isBrowsingSubChannel, let city = app.currentCity {
                    Text("Browsing within \(city.displayName)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Content tagged to #\(scopeId ?? "…")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 8) {
                headerStat(value: filteredEvents.count, label: "Events", tint: Theme.accentEmerald)
                headerStat(value: filteredTribes.count, label: "Tribes", tint: Theme.brand)
                headerStat(value: filteredMembers.count, label: "Members", tint: Theme.accentIndigo)
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

    @ViewBuilder
    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Nearby on the map", systemImage: "map.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.brand)
                .padding(.horizontal, 16)

            ExploreMapView(
                pins: mapPins,
                events: scopedEvents,
                channels: channels,
                emptyMessage: "No map pins in \(channelName) yet",
                onExpand: { showFullscreenMap = true },
                cameraPosition: $cameraPosition,
                selection: $mapSelection,
                location: mapLocation,
                onOpenEvent: openEventFromMap,
                onOpenCity: openCityFromMap
            )
            .padding(.horizontal, 16)
        }
    }

    private func openEventFromMap(_ event: Event) {
        mapSelection = nil
        mapItemRoute = .event(event)
    }

    private func openCityFromMap(_ channel: Channel) {
        mapSelection = nil
        app.setActiveChannel(channel)
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
                        ExplorePreviewLink(route: .event(event)) {
                            ExploreEventPreview(event: event)
                        }
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
                        ExplorePreviewLink(route: .poll(poll)) {
                            ExplorePollPreview(poll: poll)
                        }
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
                        ExplorePreviewLink(route: .task(task)) {
                            ExploreTaskPreview(task: task)
                        }
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
                        ExplorePreviewLink(route: .crowdfund(fund)) {
                            ExploreCrowdfundPreview(crowdfund: fund)
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
        }

        if filter == .all || filter == .people, !filteredMembers.isEmpty {
            exploreSection(
                title: "Channel members",
                symbol: "person.2.fill",
                tint: Theme.brand,
                destination: ExploreMembersList(members: filteredMembers)
            ) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(filteredMembers.prefix(8)) { member in
                            ExploreMemberCard(member: member) {
                                profileRoute = ProfileRoute(tid: member.tid)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }

        if filter == .all || filter == .tribes, !filteredTribes.isEmpty {
            exploreSection(
                title: app.activeChannel?.isCity == false ? "This tribe" : "Tribes in \(app.currentCity?.displayName ?? "your city")",
                symbol: "number",
                tint: Theme.accentTeal,
                destination: ExploreTribesList(
                    tribes: filteredTribes,
                    onSelect: { selectedTribe = $0 }
                )
            ) {
                VStack(spacing: 8) {
                    ForEach(filteredTribes.prefix(4)) { tribe in
                        Button { 
                            app.setActiveChannel(tribe)
                            selectedTribe = tribe 
                        } label: {
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
            message: "As neighbors post events, polls, and tasks in #\(scopeId ?? "this channel"), they'll show up here."
        )
    }

    // MARK: - Data

    private func scoped<T>(_ items: [T], channel: (T) -> String?) -> [T] {
        guard let scopeId else { return [] }
        return items.filter { ChannelScope.matchesExact(scopeId: scopeId, channelId: channel($0)) }
    }

    private func matchesSearch(_ text: String?) -> Bool {
        guard !query.isEmpty else { return true }
        return text?.lowercased().contains(query) == true
    }

    @MainActor
    private func refresh() async {
        loading = members.isEmpty && events.isEmpty
        error = nil
        defer { loading = false }

        guard let scopeId else {
            members = []
            events = []
            polls = []
            tasks = []
            crowdfunds = []
            channels = []
            return
        }

        async let membersTask = (try? await app.api.fetchChannelMembers(scopeId)) ?? []
        async let eventsTask = (try? await app.api.fetchEvents(upcomingOnly: true)) ?? []
        async let pollsTask = (try? await app.api.fetchPolls()) ?? []
        async let tasksTask = (try? await app.api.fetchTasks()) ?? []
        async let fundsTask = (try? await app.api.fetchCrowdfunds()) ?? []
        async let channelsTask = (try? await app.api.fetchChannels()) ?? []

        members = await membersTask
        events = await eventsTask
        polls = await pollsTask
        tasks = await tasksTask
        crowdfunds = await fundsTask
        channels = await channelsTask

        for member in members {
            app.userAvatars.ensureLoaded(tid: member.tid)
        }
        recenterMapIfNeeded()
        mapLocation.request()
    }

    private func recenterMapIfNeeded() {
        guard !mapPins.isEmpty else { return }
        cameraPosition = ExploreMapPin.regionFitting(
            mapPins,
            userCoordinate: mapLocation.coordinate
        )
    }

    @MainActor
    private func runHubSearch() async {
        let q = debouncedSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard q.count >= ExploreSearch.minQueryLength else {
            searchResults = ExploreSearchResults()
            searchLoading = false
            return
        }

        searchLoading = searchResults.isEmpty
        searchResults = await ExploreSearch.run(
            query: q,
            activeChannel: app.activeChannel,
            api: app.api
        )
        for user in searchResults.users {
            app.userAvatars.ensureLoaded(tid: user.tid)
        }
        searchLoading = false
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
