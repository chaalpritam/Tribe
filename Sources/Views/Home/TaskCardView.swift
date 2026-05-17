import SwiftUI

struct TaskCardView: View {
    @EnvironmentObject private var app: AppState

    let task: TaskItem
    @State private var claimed = false
    @State private var working = false

    var body: some View {
        FeedCardChrome {
            VStack(alignment: .leading, spacing: 14) {
                FeedTypeBadge(icon: "checklist", label: "Local Task", tint: Theme.warning)
                Text(task.title)
                    .font(.title3.weight(.bold))
                if let description = task.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(3)
                }
                if let reward = task.rewardText, !reward.isEmpty {
                    Text(reward)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.success)
                }
                Text(task.status.capitalized)
                    .font(.caption2.weight(.bold))
                    .tracking(1)
                    .foregroundStyle(Theme.textSecondary)
                Button {
                    Task { await claim() }
                } label: {
                    HStack {
                        if working { ProgressView().controlSize(.small) }
                        Text(claimed || task.claimedByTid != nil ? "Claimed" : "Claim task")
                            .font(.subheadline.weight(.bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.warning)
                .disabled(working || claimed || task.claimedByTid != nil || app.appKey == nil)
            }
        }
        .onAppear {
            claimed = task.claimedByTid != nil
        }
    }

    private func claim() async {
        guard let key = app.appKey, let tid = app.myTID else { return }
        working = true
        defer { working = false }
        do {
            try await app.api.claimTask(taskId: task.id, as: key, tid: tid)
            claimed = true
        } catch {}
    }
}
