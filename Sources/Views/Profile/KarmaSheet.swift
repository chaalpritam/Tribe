import SwiftUI

struct KarmaSheet: View {
    let karma: KarmaSummary

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.15))
                            .frame(width: 96, height: 96)
                        Text("L\(karma.level)")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(.orange)
                    }
                    Text("\(karma.total)")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                    Text("Total karma")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                breakdownCard
            }
            .padding(16)
        }
        .background(Theme.pageBackground)
    }

    private var breakdownCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            row("Tweets", count: karma.breakdown.tweets, weight: karma.weights.tweet, icon: "text.bubble.fill", tint: Theme.primary)
            divider
            row("Reactions", count: karma.breakdown.reactionsReceived, weight: karma.weights.reactionReceived, icon: "heart.fill", tint: Theme.error)
            divider
            row("Followers", count: karma.breakdown.followers, weight: karma.weights.follower, icon: "person.2.fill", tint: .teal)
            divider
            row("Tips received", count: karma.breakdown.tipsReceived, weight: karma.weights.tipReceived, icon: "dollarsign.circle.fill", tint: .orange)
            divider
            row("Tasks done", count: karma.breakdown.tasksCompleted, weight: karma.weights.taskCompleted, icon: "checkmark.seal.fill", tint: Theme.success)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func row(_ label: String, count: Int, weight: Int, icon: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(tint)
                .frame(width: 32, height: 32)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.subheadline.weight(.semibold))
                Text("\(count) × \(weight) pts")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            Text("\(count * weight)")
                .font(.subheadline.weight(.bold))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.black.opacity(0.06))
            .frame(height: 0.5)
            .padding(.leading, 58)
    }
}
