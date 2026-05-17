import SwiftUI

struct CreatePollComposer: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.dismiss) private var dismiss

    var onCreated: () -> Void

    @State private var question = ""
    @State private var options = ["", ""]
    @State private var hasDeadline = false
    @State private var expiresAt = Date().addingTimeInterval(86400)
    @State private var channelId = ""
    @State private var publishing = false
    @State private var error: String?

    private var validOptions: [String] {
        options.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
    }

    private var canPublish: Bool {
        !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && validOptions.count >= 2 && validOptions.count <= 10
            && !publishing && app.appKey != nil && app.myTID != nil
    }

    var body: some View {
        Form {
            Section("Question") {
                TextField("What should we do next?", text: $question, axis: .vertical)
                    .lineLimit(2 ... 4)
            }
            Section("Options") {
                ForEach(options.indices, id: \.self) { index in
                    HStack {
                        TextField("Option \(index + 1)", text: $options[index])
                        if options.count > 2 {
                            Button(role: .destructive) { options.remove(at: index) } label: {
                                Image(systemName: "minus.circle")
                            }
                        }
                    }
                }
                if options.count < 10 {
                    Button("Add option") { options.append("") }
                }
            }
            Section("Settings") {
                Toggle("Deadline", isOn: $hasDeadline)
                if hasDeadline {
                    DatePicker("Closes", selection: $expiresAt, in: Date()...)
                }
                ChannelPickerField(channelId: $channelId)
            }
            if let error {
                Section {
                    Text(error).foregroundStyle(Theme.error).font(.footnote)
                }
            }
            Section {
                Button(publishing ? "Publishing…" : "Create poll") {
                    Task { await publish() }
                }
                .disabled(!canPublish)
            }
        }
        .navigationTitle("New poll")
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
            _ = try await app.api.createPoll(
                pollId: Slug.make(question),
                question: question.trimmingCharacters(in: .whitespacesAndNewlines),
                options: validOptions,
                expiresAt: hasDeadline ? expiresAt : nil,
                channelId: channelId,
                as: key,
                tid: tid
            )
            dismiss()
            onCreated()
        } catch {
            error = error.localizedDescription
        }
    }
}
