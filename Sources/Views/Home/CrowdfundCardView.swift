import SwiftUI

struct CrowdfundCardView: View {
    let crowdfund: Crowdfund

    var body: some View {
        FeedCardChrome {
            VStack(alignment: .leading, spacing: 12) {
                FeedTypeBadge(icon: "heart.circle.fill", label: "Crowdfund", tint: Theme.accentRose)
                Text(crowdfund.title)
                    .font(.headline.weight(.bold))
                if let description = crowdfund.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(3)
                }
                ProgressView(value: crowdfund.progress)
                    .tint(Theme.brand)
                HStack {
                    Text("\(Int(crowdfund.progress * 100))% funded")
                        .font(.caption.weight(.bold))
                    Spacer()
                    Text("\(crowdfund.currency) \(formatAmount(crowdfund.pledgedAmount ?? crowdfund.raisedAmount))")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.textSecondary)
                }
                if let count = crowdfund.pledgerCount {
                    Text("\(count) pledger\(count == 1 ? "" : "s")")
                        .font(.caption2)
                        .foregroundStyle(Theme.textSecondary)
                }
                HubSettlementBadge()
            }
        }
    }

    private func formatAmount(_ value: Decimal) -> String {
        NSDecimalNumber(decimal: value).stringValue
    }
}
