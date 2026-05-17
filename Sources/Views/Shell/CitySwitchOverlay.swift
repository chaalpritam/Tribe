import SwiftUI

/// Full-screen overlay while `AppState.isSwitchingCity` is true.
struct CitySwitchOverlay: View {
    @EnvironmentObject private var app: AppState

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .stroke(Color.black.opacity(0.06), lineWidth: 4)
                        .frame(width: 120, height: 120)
                    ProgressView()
                        .controlSize(.large)
                        .tint(.primary)
                }
                VStack(spacing: 8) {
                    Text("Traveling…")
                        .font(.largeTitle.weight(.black))
                    Text("Syncing local pulse")
                        .font(.caption.weight(.bold))
                        .tracking(1.5)
                        .foregroundStyle(Theme.textSecondary)
                        .textCase(.uppercase)
                }
            }
        }
        .opacity(app.isSwitchingCity ? 1 : 0)
        .animation(.easeInOut(duration: 0.35), value: app.isSwitchingCity)
        .allowsHitTesting(app.isSwitchingCity)
        .zIndex(100)
    }
}
