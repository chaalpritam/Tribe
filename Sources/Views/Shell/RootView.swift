import SwiftUI

struct RootView: View {
    @EnvironmentObject private var app: AppState

    var body: some View {
        Group {
            switch app.phase {
            case .unloaded:
                ProgressView("Loading…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Theme.pageBackground)
            case .connect:
                ConnectFlow()
            case .city:
                CityPickerView()
            case .ready:
                ReadyPlaceholderView()
            }
        }
        .tint(Theme.primary)
        .animation(.easeInOut(duration: 0.2), value: app.phase)
    }
}
