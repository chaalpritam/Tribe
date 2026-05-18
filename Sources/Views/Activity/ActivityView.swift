import SwiftUI

/// Account transparency log (`/v1/users/:tid/activity`) — includes follow
/// settlement rows (`follow_pending` / `follow_settled`).
struct ActivityView: View {
    @EnvironmentObject private var app: AppState

    @State private var rows: [ActivityRow] = []
    @State private var filter: Filter = .all
    @State private var loading = true
    @State private var error: String?

    enum Filter: String, CaseIterable, Identifiable {
        case all, onchain, offchain
        var id: String { rawValue }
        var label: String {
            switch self {
            case .all: return "All"
            case .onchain: return "On-chain"
            case .offchain: return "Signed"
            }
        }
    }

    private var filtered: [ActivityRow] {
        switch filter {
        case .all: return rows
        case .onchain: return rows.filter { $0.type.isOnChain }
        case .offchain: return rows.filter { !$0.type.isOnChain }
        }
    }

    var body: some View {
        Group {
            if app.myTID == nil {
                EmptyStateView(
                    symbol: "person.crop.circle.badge.exclamationmark",
                    title: "Sign in required",
                    message: "Connect your TID to see your activity log."
                )
            } else if loading, rows.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error, rows.isEmpty {
                EmptyStateView(
                    symbol: "wifi.exclamationmark",
                    title: "Couldn't load activity",
                    message: error,
                    retryTitle: "Retry",
                    onRetry: { Task { await refresh() } }
                )
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        filterPicker
                        if filtered.isEmpty {
                            Text("No \(filter.label.lowercased()) activity yet")
                                .font(.subheadline)
                                .foregroundStyle(Theme.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 32)
                        } else {
                            ForEach(filtered) { row in
                                activityRow(row)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
        }
        .background(Theme.pageBackground)
        .navigationTitle("Activity")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable { await refresh() }
        .task { await refresh() }
    }

    private var filterPicker: some View {
        HStack(spacing: 8) {
            ForEach(Filter.allCases) { f in
                Button {
                    filter = f
                } label: {
                    Text(f.label)
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(filter == f ? Color.white : Color.clear)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color(white: 0.94))
        .clipShape(Capsule())
    }

    private func activityRow(_ row: ActivityRow) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon(for: row.type))
                .font(.body.weight(.semibold))
                .foregroundStyle(row.type.isOnChain ? Theme.primary : Theme.textSecondary)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 4) {
                Text(row.type.verb)
                    .font(.subheadline.weight(.bold))
                if let preview = row.preview, !preview.isEmpty {
                    Text(preview)
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(2)
                }
                Text(RelativeTime.short(row.timestamp))
                    .font(.caption2)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer(minLength: 0)
            if row.type.isOnChain, row.txSignature == nil, row.type.rawValue.contains("pending") {
                ProgressView()
                    .controlSize(.small)
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func icon(for type: ActivityType) -> String {
        switch type {
        case .followPending, .followSettled, .followFailed,
             .unfollowPending, .unfollowSettled, .unfollowFailed:
            return "person.2"
        case .tipSent, .tipReceived:
            return "gift"
        case .tweet, .tweetReply:
            return "bubble.left"
        default:
            return "clock.arrow.circlepath"
        }
    }

    private func refresh() async {
        guard let tid = app.myTID else { return }
        loading = rows.isEmpty
        error = nil
        defer { loading = false }
        do {
            rows = try await app.api.fetchActivity(tid)
        } catch {
            self.error = error.localizedDescription
        }
    }
}
