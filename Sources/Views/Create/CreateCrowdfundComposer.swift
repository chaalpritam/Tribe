import SwiftUI

struct CreateCrowdfundComposer: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.dismiss) private var dismiss

    var onCreated: () -> Void

    @State private var title = ""
    @State private var description = ""
    @State private var goalAmount = ""
    @State private var currency = "USD"
    @State private var hasDeadline = false
    @State private var deadline = Date().addingTimeInterval(86400 * 30)
    @State private var channelId = ""
    @State private var imageURL = ""
    @State private var publishing = false
    @State private var error: String?

    private var goal: Double? {
        Double(goalAmount.trimmingCharacters(in: .whitespaces))
    }

    private var canPublish: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && (goal ?? 0) > 0
            && !publishing && app.appKey != nil && app.myTID != nil
    }

    var body: some View {
        Form {
            Section("Pitch") {
                TextField("Title", text: $title)
                TextField("Description", text: $description, axis: .vertical)
                    .lineLimit(3 ... 8)
            }
            Section("Goal") {
                HStack {
                    TextField("Amount", text: $goalAmount)
                        .keyboardType(.decimalPad)
                    TextField("Currency", text: $currency)
                        .frame(width: 72)
                        .textInputAutocapitalization(.characters)
                }
            }
            Section {
                Toggle("Deadline", isOn: $hasDeadline)
                if hasDeadline {
                    DatePicker("Closes", selection: $deadline, in: Date()...)
                }
                ChannelPickerField(channelId: $channelId)
                TextField("Image URL", text: $imageURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            if let error {
                Section { Text(error).foregroundStyle(Theme.error).font(.footnote) }
            }
            Section {
                Button(publishing ? "Publishing…" : "Create fund") {
                    Task { await publish() }
                }
                .disabled(!canPublish)
            }
        }
        .navigationTitle("New fund")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if channelId.isEmpty { channelId = app.currentCity?.id ?? "general" }
        }
    }

    private func publish() async {
        guard let key = app.appKey, let tid = app.myTID, let goal else { return }
        publishing = true
        defer { publishing = false }
        do {
            _ = try await app.api.createCrowdfund(
                crowdfundId: Slug.make(title),
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                goalAmount: goal,
                currency: currency.trimmingCharacters(in: .whitespacesAndNewlines).uppercased(),
                deadline: hasDeadline ? deadline : nil,
                imageURL: imageURL.trimmingCharacters(in: .whitespacesAndNewlines),
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
