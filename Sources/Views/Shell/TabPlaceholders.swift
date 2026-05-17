import SwiftUI

struct ExploreTabPlaceholder: View {
    var body: some View {
        ShellPlaceholderScreen(
            icon: "safari",
            title: "Explore",
            subtitle: "Search and discovery land in Phase 8."
        )
    }
}

struct MapTabPlaceholder: View {
    var body: some View {
        ShellPlaceholderScreen(
            icon: "map",
            title: "Map",
            subtitle: "MapKit pins and filters land in Phase 8."
        )
    }
}

struct ChatTabPlaceholder: View {
    var body: some View {
        ShellPlaceholderScreen(
            icon: "message",
            title: "Chat",
            subtitle: "Encrypted DMs land in Phase 8."
        )
    }
}

struct CreatePlaceholderSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ShellPlaceholderScreen(
                icon: "plus.circle",
                title: "Create",
                subtitle: "Six composers (tweet, event, poll, task, fund, tribe) land in Phase 9."
            )
            .navigationTitle("Create")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationCornerRadius(Theme.sheetCornerRadius)
    }
}
