import SwiftUI

struct RootShellView: View {
    @EnvironmentObject private var app: AppState

    @State private var selectedTab: ShellTab = .home
    @State private var showCreate = false
    @State private var showCitySwitcher = false
    @State private var showNotifications = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                AppHeader(
                    title: headerTitle,
                    onChangeCity: { showCitySwitcher = true },
                    onNotifications: { showNotifications = true }
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
        .sheet(isPresented: $showNotifications) {
            NavigationStack {
                ShellPlaceholderScreen(
                    icon: "bell",
                    title: "Notifications",
                    subtitle: "Notification list lands in Phase 7."
                )
                .navigationTitle("Notifications")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { showNotifications = false }
                    }
                }
            }
            .presentationCornerRadius(Theme.sheetCornerRadius)
        }
    }

    private var headerTitle: String {
        switch selectedTab {
        case .home:
            return app.currentCity?.displayName ?? "Home"
        default:
            return selectedTab.title
        }
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
            TribesTabPlaceholder()
        case .chat:
            ChatTabPlaceholder()
        case .profile:
            ProfileTabPlaceholder()
        }
    }
}
