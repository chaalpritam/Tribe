import SwiftUI

struct CreateTaskComposer: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.dismiss) private var dismiss

    var onCreated: () -> Void

    @State private var title = ""
    @State private var description = ""
    @State private var rewardText = ""
    @State private var channelId = ""
    @State private var publishing = false
    @State private var error: String?

    private var canPublish: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !publishing && app.appKey != nil && app.myTID != nil
    }

    var body: some View {
        Form {
            Section("Task") {
                TextField("Title", text: $title)
                TextField("Description", text: $description, axis: .vertical)
                    .lineLimit(2 ... 6)
            }
            Section {
                TextField("e.g. 0.1 SOL, lunch, …", text: $rewardText)
            } header: {
                Text("Reward")
            } footer: {
                Text("Descriptive only — rewards are not escrowed on-chain in this build.")
            }
            Section {
                ChannelPickerField(channelId: $channelId)
            }
            if let error {
                Section { Text(error).foregroundStyle(Theme.error).font(.footnote) }
            }
            Section {
                Button(publishing ? "Publishing…" : "Create task") {
                    Task { await publish() }
                }
                .disabled(!canPublish)
            }
        }
        .navigationTitle("New task")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if channelId.isEmpty { channelId = app.currentCity?.id ?? "general" }
        }
    }

    private func publish() async {
        guard let key = app.appKey, let tid = app.myTID else { return }
        publishing = true
        defer { publishing = false }
        do {
            _ = try await app.api.createTask(
                taskId: Slug.make(title),
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                rewardText: rewardText.trimmingCharacters(in: .whitespacesAndNewlines),
                channelId: channelId,
                as: key,
                tid: tid
            )
            dismiss()
            onCreated()
        } catch let err {
            error = err.localizedDescription
        }
    }
}
