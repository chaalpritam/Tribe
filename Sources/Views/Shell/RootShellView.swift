import SwiftUI

struct RootShellView: View {
    @EnvironmentObject private var app: AppState

    @State private var selectedTab: ShellTab = .home
    @State private var tribesPath: [TribesDestination] = []
    @State private var showCreate = false
    @State private var showCitySwitcher = false
    @State private var showNotifications = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                AppHeader(
                    title: headerTitle,
                    showBackButton: showTribesBack,
                    onBack: { tribesPath.removeLast() },
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
            CreatePlaceholderSheet()
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
        default:
            return selectedTab.title
        }
    }

    private var showTribesBack: Bool {
        selectedTab == .tribes && !tribesPath.isEmpty
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .home:
            HomeFeedView()
                .environmentObject(app.interactions)
        case .explore:
            ExploreTabPlaceholder()
        case .map:
            MapTabPlaceholder()
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
            ChatTabPlaceholder()
        case .profile:
            NavigationStack {
                ProfileView()
                    .environmentObject(app.interactions)
            }
            .navigationBarHidden(true)
        }
    }
}
