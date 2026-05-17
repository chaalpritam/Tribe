import SwiftUI

struct CreateTribeComposer: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.dismiss) private var dismiss

    var onCreated: () -> Void

    enum TribeKind: Int, CaseIterable, Identifiable {
        case interest = 3
        case city = 2
        var id: Int { rawValue }
        var label: String { self == .interest ? "Interest" : "City" }
    }

    @State private var kind: TribeKind = .interest
    @State private var name = ""
    @State private var description = ""
    @State private var attachLocation = false
    @State private var publishing = false
    @State private var error: String?
    @StateObject private var location = LocationProvider()

    private var canPublish: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !publishing && app.appKey != nil && app.myTID != nil
    }

    var body: some View {
        Form {
            Section {
                Picker("Type", selection: $kind) {
                    ForEach(TribeKind.allCases) { k in
                        Text(k.label).tag(k)
                    }
                }
                .pickerStyle(.segmented)
            } footer: {
                Text(kind == .city
                    ? "City tribes can include map coordinates."
                    : "Interest tribes group posts by topic.")
            }
            Section("Tribe") {
                TextField("Display name", text: $name)
                TextField("Description", text: $description, axis: .vertical)
                    .lineLimit(2 ... 4)
            }
            if kind == .city {
                Section {
                    Toggle("Attach my location", isOn: $attachLocation)
                        .onChange(of: attachLocation) { _, on in if on { location.request() } }
                }
            }
            if let error {
                Section { Text(error).foregroundStyle(Theme.error).font(.footnote) }
            }
            Section {
                Button(publishing ? "Publishing…" : "Create tribe") {
                    Task { await publish() }
                }
                .disabled(!canPublish)
            }
        }
        .navigationTitle("New tribe")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func publish() async {
        guard let key = app.appKey, let tid = app.myTID else { return }
        publishing = true
        defer { publishing = false }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let channelId = Slug.make(trimmedName)
        let lat = kind == .city && attachLocation ? location.coordinate?.latitude : nil
        let lng = kind == .city && attachLocation ? location.coordinate?.longitude : nil
        do {
            _ = try await app.api.createChannel(
                channelId: channelId,
                name: trimmedName,
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                kind: kind.rawValue,
                latitude: lat,
                longitude: lng,
                as: key,
                tid: tid
            )
            try? await app.joinChannel(Channel(id: channelId, name: trimmedName, kind: kind.rawValue))
            dismiss()
            onCreated()
        } catch {
            error = error.localizedDescription
        }
    }
}
