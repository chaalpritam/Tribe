import SwiftUI

struct CreateHubView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedMode: CreateMode?

    var body: some View {
        NavigationStack {
            List {
                ForEach(CreateMode.allCases) { mode in
                    Button {
                        selectedMode = mode
                    } label: {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(mode.title)
                                    .font(.headline)
                                Text(mode.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                        } icon: {
                            Image(systemName: mode.symbol)
                                .foregroundStyle(mode.accent)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Create")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .navigationDestination(item: $selectedMode) { mode in
                composer(for: mode)
            }
        }
    }

    @ViewBuilder
    private func composer(for mode: CreateMode) -> some View {
        let onDone = { dismiss() }
        Group {
            switch mode {
            case .tweet:
                ComposeTweetView(onPublished: { _ in onDone() })
            case .event:
                CreateEventComposer(onCreated: onDone)
            case .poll:
                CreatePollComposer(onCreated: onDone)
            case .task:
                CreateTaskComposer(onCreated: onDone)
            case .crowdfund:
                CreateCrowdfundComposer(onCreated: onDone)
            case .tribe:
                CreateTribeComposer(onCreated: onDone)
            }
        }
    }
}
