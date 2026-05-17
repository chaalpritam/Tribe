import SwiftUI

struct RootShellView: View {
    @EnvironmentObject private var app: AppState

    @State private var selectedTab: ShellTab = .home
    @State private var tribesPath: [TribesDestination] = []
    @State private var chatPath: [DMTarget] = []
    @State private var showCreate = false
    @State private var showCitySwitcher = false
    @State private var showNotifications = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                AppHeader(
                    title: headerTitle,
                    showBackButton: showShellBack,
                    onBack: {
                        if selectedTab == .tribes { tribesPath.removeLast() }
                        if selectedTab == .chat { chatPath.removeLast() }
                    },
                    onChangeCity: selectedTab == .home ? { showCitySwitcher = true } : nil,
                    onNotifications: { showNotifications = true },
                    notificationUnreadCount: app.notifications.unreadCount
                )
                tabContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .blur(radius: app.isSwitchingCity ? 6 : 0)
            .scaleEffect(app.isSwitchingCity ? 0.96 : 1)
            .opacity(app.isSwitchingCity ? 0.5 : 1)
            .animation(.easeInOut(duration: 0.35), value: app.isSwitchingCity)

            CitySwitchOverlay()
        }
        .background(Color(.systemBackground))
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomPillNav(selectedTab: $selectedTab, onCreate: { showCreate = true })
                .padding(.bottom, 8)
        }
        .sheet(isPresented: $showCreate) {
            CreateHubView()
                .environmentObject(app)
                .presentationCornerRadius(Theme.sheetCornerRadius)
        }
        .sheet(isPresented: $showCitySwitcher) {
            CitySwitcherSheet()
        }
        .sheet(isPresented: $showNotifications, onDismiss: {
            if let tid = app.myTID {
                app.markNotificationsRead(tid: tid)
            }
            Task { await app.notifications.refreshUnread() }
        }) {
            NavigationStack {
                NotificationsListView()
                    .navigationTitle("Notifications")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showNotifications = false }
                        }
                    }
            }
            .environmentObject(app)
            .presentationCornerRadius(Theme.sheetCornerRadius)
        }
        .task {
            await app.notifications.refreshUnread()
        }
        .onChange(of: selectedTab) { _, _ in
            Task { await app.notifications.refreshUnread() }
        }
    }

    private var headerTitle: String {
        switch selectedTab {
        case .home:
            return app.currentCity?.displayName ?? "Home"
        case .tribes:
            if case .tribe(let channel) = tribesPath.last {
                return channel.displayName
            }
            return "Tribes"
        case .chat:
            if let last = chatPath.last {
                return last.displayTitle
            }
            return "Chat"
        default:
            return selectedTab.title
        }
    }

    private var showShellBack: Bool {
        (selectedTab == .tribes && !tribesPath.isEmpty)
            || (selectedTab == .chat && !chatPath.isEmpty)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .home:
            HomeFeedView()
                .environmentObject(app.interactions)
        case .explore:
            ExploreView()
        case .map:
            MapView()
        case .tribes:
            NavigationStack(path: $tribesPath) {
                TribesDirectoryView(
                    path: $tribesPath,
                    onJumpToCity: { selectedTab = .home }
                )
                .navigationDestination(for: TribesDestination.self) { destination in
                    if case .tribe(let channel) = destination {
                        TribeDetailView(channel: channel)
                            .environmentObject(app.interactions)
                    }
                }
            }
            .navigationBarHidden(true)
        case .chat:
            NavigationStack(path: $chatPath) {
                ChatListView(path: $chatPath)
                    .navigationDestination(for: DMTarget.self) { target in
                        DMThreadView(target: target)
                            .environmentObject(app)
                    }
            }
            .navigationBarHidden(true)
        case .profile:
            NavigationStack {
                ProfileView()
                    .environmentObject(app.interactions)
            }
            .navigationBarHidden(true)
        }
    }
}
