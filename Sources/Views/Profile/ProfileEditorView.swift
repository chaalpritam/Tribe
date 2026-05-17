import SwiftUI

struct ProfileEditorView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var displayName = ""
    @State private var bio = ""
    @State private var pfpURL = ""
    @State private var location = ""
    @State private var publishing = false
    @State private var error: String?

    private let maxLength = 500

    var body: some View {
        Form {
            Section("Public profile") {
                TextField("Display name", text: $displayName)
                TextField("Bio", text: $bio, axis: .vertical)
                    .lineLimit(3 ... 6)
            }
            Section("Photos") {
                TextField("Profile picture URL", text: $pfpURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            Section("About") {
                TextField("Location", text: $location)
            }
            if let error {
                Section {
                    Text(error)
                        .foregroundStyle(Theme.error)
                        .font(.footnote)
                }
            }
            Section {
                Button(publishing ? "Publishing…" : "Save changes") {
                    Task { await publish() }
                }
                .disabled(publishing || app.appKey == nil)
            }
        }
        .navigationTitle("Edit profile")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        guard let tid = app.myTID,
              let user = try? await app.api.fetchUser(tid) else { return }
        displayName = user.profile?.displayName ?? ""
        bio = user.profile?.bio ?? ""
        pfpURL = user.profile?.pfpUrl ?? ""
        location = user.profile?.location ?? ""
    }

    private func publish() async {
        guard let key = app.appKey, let tid = app.myTID, !publishing else { return }
        publishing = true
        defer { publishing = false }
        error = nil
        let updates: [(String, String)] = [
            ("displayName", displayName.trimmingCharacters(in: .whitespacesAndNewlines)),
            ("bio", bio.trimmingCharacters(in: .whitespacesAndNewlines)),
            ("pfpUrl", pfpURL.trimmingCharacters(in: .whitespacesAndNewlines)),
            ("location", location.trimmingCharacters(in: .whitespacesAndNewlines)),
        ].filter { !$0.1.isEmpty }

        for (field, value) in updates {
            if value.count > maxLength {
                error = "\(field) exceeds 500 characters."
                return
            }
            do {
                _ = try await app.api.updateProfile(field: field, value: value, as: key, tid: tid)
            } catch {
                self.error = error.localizedDescription
                return
            }
        }
        await app.refreshIdentityMetadata()
        dismiss()
    }
}
