import SwiftUI

struct PollCardView: View {
    @EnvironmentObject private var app: AppState

    let poll: Poll
    @State private var votedIndex: Int?
    @State private var working = false

    var body: some View {
        FeedCardChrome {
            VStack(alignment: .leading, spacing: 14) {
                FeedTypeBadge(icon: "chart.bar.fill", label: "Community Poll", tint: Color(red: 0.34, green: 0.4, blue: 0.96))
                Text(poll.question)
                    .font(.title3.weight(.bold))
                VStack(spacing: 8) {
                    ForEach(Array(poll.options.enumerated()), id: \.offset) { index, option in
                        Button {
                            Task { await vote(index: index) }
                        } label: {
                            HStack {
                                Text(option)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Theme.textPrimary)
                                Spacer()
                                if votedIndex == index {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Theme.primary)
                                }
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(votedIndex == index ? Theme.primary.opacity(0.1) : Color(.tertiarySystemFill))
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(working || votedIndex != nil || app.appKey == nil)
                    }
                }
                if let total = poll.totalVotes {
                    Text("\(total) vote\(total == 1 ? "" : "s")")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.textSecondary)
                }
                HubSettlementBadge()
            }
        }
    }

    private func vote(index: Int) async {
        guard let key = app.appKey, let tid = app.myTID else { return }
        working = true
        defer { working = false }
        do {
            try await app.api.voteOnPoll(pollId: poll.id, optionIndex: index, as: key, tid: tid)
            votedIndex = index
        } catch {}
    }
}
