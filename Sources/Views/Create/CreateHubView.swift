import SwiftUI

struct CreateHubView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedMode: CreateMode?

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(CreateMode.allCases) { mode in
                        Button {
                            selectedMode = mode
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                Image(systemName: mode.symbol)
                                    .font(.title2.weight(.semibold))
                                    .foregroundStyle(mode.accent)
                                    .frame(width: 44, height: 44)
                                    .background(mode.accent.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                Text(mode.title)
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(Theme.textPrimary)
                                Text(mode.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(Theme.textSecondary)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
            .background(Color(red: 0.99, green: 0.99, blue: 0.99))
            .navigationTitle("Create")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
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
