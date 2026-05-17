import SwiftUI

struct EventCardView: View {
    @EnvironmentObject private var app: AppState

    let event: Event
    @State private var rsvped = false
    @State private var working = false

    var body: some View {
        FeedCardChrome {
            VStack(alignment: .leading, spacing: 14) {
                FeedTypeBadge(icon: "calendar", label: "Local Event", tint: Theme.primary)
                Text(event.title)
                    .font(.title3.weight(.bold))
                if let description = event.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(3)
                }
                HStack(spacing: 10) {
                    metaChip(icon: "mappin.and.ellipse", text: event.locationText ?? "TBD")
                    metaChip(icon: "person.2", text: "\(event.yesCount) going")
                }
                Button {
                    Task { await rsvp() }
                } label: {
                    HStack {
                        if working { ProgressView().controlSize(.small) }
                        Text(rsvped ? "RSVP'd" : "RSVP")
                            .font(.subheadline.weight(.bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(.primary)
                .disabled(working || rsvped || app.appKey == nil)
            }
        }
    }

    private func metaChip(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.tertiarySystemFill))
        )
    }

    private func rsvp() async {
        guard let key = app.appKey, let tid = app.myTID else { return }
        working = true
        defer { working = false }
        do {
            try await app.api.rsvp(eventId: event.id, status: "yes", as: key, tid: tid)
            rsvped = true
        } catch {}
    }
}
