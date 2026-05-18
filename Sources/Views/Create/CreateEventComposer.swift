import SwiftUI

struct CreateEventComposer: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.dismiss) private var dismiss

    var onCreated: () -> Void

    @State private var title = ""
    @State private var description = ""
    @State private var startsAt = Date().addingTimeInterval(86400)
    @State private var hasEndDate = false
    @State private var endsAt = Date().addingTimeInterval(90000)
    @State private var locationText = ""
    @State private var attachLocation = false
    @State private var channelId = ""
    @State private var imageURL = ""
    @State private var publishing = false
    @State private var error: String?
    @StateObject private var location = LocationProvider()

    private var canPublish: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !publishing && app.appKey != nil && app.myTID != nil
    }

    var body: some View {
        Form {
            Section("Event") {
                TextField("Title", text: $title)
                TextField("Description", text: $description, axis: .vertical)
                    .lineLimit(2 ... 6)
            }
            Section("When") {
                DatePicker("Starts", selection: $startsAt)
                Toggle("End time", isOn: $hasEndDate)
                if hasEndDate {
                    DatePicker("Ends", selection: $endsAt, in: startsAt...)
                }
            }
            Section("Where") {
                TextField("Location label", text: $locationText)
                Toggle("Attach GPS coordinates", isOn: $attachLocation)
                    .onChange(of: attachLocation) { _, on in if on { location.request() } }
                if attachLocation, let coord = location.coordinate {
                    Text("Lat \(coord.latitude, specifier: "%.5f"), Lng \(coord.longitude, specifier: "%.5f")")
                        .font(.footnote)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            Section("Optional") {
                ChannelPickerField(channelId: $channelId)
                TextField("Image URL", text: $imageURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            if let error {
                Section { Text(error).foregroundStyle(Theme.error).font(.footnote) }
            }
            Section {
                Button(publishing ? "Publishing…" : "Create event") {
                    Task { await publish() }
                }
                .disabled(!canPublish)
            }
        }
        .navigationTitle("New event")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if channelId.isEmpty { channelId = app.currentCity?.id ?? "general" }
        }
    }

    private func publish() async {
        guard let key = app.appKey, let tid = app.myTID else { return }
        publishing = true
        defer { publishing = false }
        let lat = attachLocation ? location.coordinate?.latitude : nil
        let lng = attachLocation ? location.coordinate?.longitude : nil
        do {
            _ = try await app.api.createEvent(
                eventId: Slug.make(title),
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                startsAt: startsAt,
                endsAt: hasEndDate ? endsAt : nil,
                locationText: locationText.trimmingCharacters(in: .whitespacesAndNewlines),
                latitude: lat,
                longitude: lng,
                channelId: channelId,
                imageURL: imageURL.trimmingCharacters(in: .whitespacesAndNewlines),
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
