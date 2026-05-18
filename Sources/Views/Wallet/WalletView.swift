import SwiftUI

struct WalletView: View {
    @EnvironmentObject private var app: AppState

    @State private var solBalance: Double?
    @State private var balanceLoading = false
    @State private var offchainSent: [Tip] = []
    @State private var offchainReceived: [Tip] = []
    @State private var onchainSent: [OnchainTip] = []
    @State private var onchainReceived: [OnchainTip] = []
    @State private var loading = true
    @State private var error: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                balanceCard
                if let error {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(Theme.error)
                }
                ledgerSection
                disconnectButton
            }
            .padding(16)
        }
        .background(Theme.pageBackground)
        .navigationTitle("Wallet")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable { await refresh() }
        .task { await refresh() }
    }

    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SOL Balance")
                .font(.caption.weight(.bold))
                .textCase(.uppercase)
                .foregroundStyle(.white.opacity(0.75))
            if balanceLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Text(balanceText)
                    .font(.system(size: 36, weight: .black))
                    .foregroundStyle(.white)
            }
            if let wallet = app.walletAddress, !wallet.isEmpty {
                Text(wallet)
                    .font(.caption2.monospaced())
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(
            LinearGradient(
                colors: [Color.indigo, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
    }

    private var balanceText: String {
        guard let sol = solBalance else { return "—" }
        return String(format: "%.4f SOL", sol)
    }

    private var ledgerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tip activity")
                .font(.headline.weight(.bold))
            if loading, mergedLedger.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if mergedLedger.isEmpty {
                Text("No tips yet")
                    .foregroundStyle(Theme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else {
                ForEach(mergedLedger) { row in
                    ledgerRow(row)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var disconnectButton: some View {
        Button("Disconnect wallet", role: .destructive) {
            app.signOut()
        }
        .font(.subheadline.weight(.bold))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func ledgerRow(_ row: LedgerRow) -> some View {
        HStack(spacing: 12) {
            Image(systemName: row.isIncoming ? "arrow.down.left" : "arrow.up.right")
                .foregroundStyle(row.isIncoming ? Theme.success : Theme.warning)
                .frame(width: 36, height: 36)
                .background((row.isIncoming ? Theme.success : Theme.warning).opacity(0.12))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(row.title)
                    .font(.subheadline.weight(.semibold))
                Text(RelativeTime.short(row.date))
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            Text(row.amountLabel)
                .font(.subheadline.weight(.bold))
                .monospacedDigit()
        }
        .padding(.vertical, 6)
    }

    private struct LedgerRow: Identifiable {
        let id: String
        let title: String
        let amountLabel: String
        let date: Date
        let isIncoming: Bool
    }

    private var mergedLedger: [LedgerRow] {
        var rows: [LedgerRow] = []
        for tip in offchainReceived {
            rows.append(LedgerRow(
                id: "off-in-\(tip.hash)",
                title: "Tip from #\(tip.senderTid)",
                amountLabel: "\(tip.amount) \(tip.currency)",
                date: tip.sentAt,
                isIncoming: true
            ))
        }
        for tip in offchainSent {
            rows.append(LedgerRow(
                id: "off-out-\(tip.hash)",
                title: "Tip to #\(tip.recipientTid)",
                amountLabel: "\(tip.amount) \(tip.currency)",
                date: tip.sentAt,
                isIncoming: false
            ))
        }
        for tip in onchainReceived {
            rows.append(LedgerRow(
                id: "on-in-\(tip.pda)",
                title: "On-chain from \(tip.counterpartyUsername.map { "@\($0).tribe" } ?? "#\(tip.senderTid)")",
                amountLabel: "\(tip.formattedSol) SOL",
                date: tip.createdAt,
                isIncoming: true
            ))
        }
        for tip in onchainSent {
            rows.append(LedgerRow(
                id: "on-out-\(tip.pda)",
                title: "On-chain to \(tip.counterpartyUsername.map { "@\($0).tribe" } ?? "#\(tip.recipientTid)")",
                amountLabel: "\(tip.formattedSol) SOL",
                date: tip.createdAt,
                isIncoming: false
            ))
        }
        return rows.sorted { $0.date > $1.date }
    }

    private func refresh() async {
        guard let tid = app.myTID else { return }
        loading = true
        error = nil
        defer { loading = false }

        if let address = app.walletAddress, !address.isEmpty {
            balanceLoading = true
            defer { balanceLoading = false }
            do {
                let lamports = try await SolanaRPCClient.fetchBalance(lamportsFor: address)
                solBalance = Double(lamports) / 1_000_000_000
            } catch {
                solBalance = nil
            }
        }

        async let sent = app.api.fetchTipsSent(tid)
        async let received = app.api.fetchTipsReceived(tid)
        async let onSent = app.api.fetchOnchainTipsSent(tid)
        async let onReceived = app.api.fetchOnchainTipsReceived(tid)
        do {
            offchainSent = try await sent
            offchainReceived = try await received
            onchainSent = try await onSent
            onchainReceived = try await onReceived
        } catch {
            self.error = error.localizedDescription
        }
    }
}
