import SwiftUI

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
