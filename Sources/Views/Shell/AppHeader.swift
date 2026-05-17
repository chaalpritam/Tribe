import SwiftUI

struct AppHeader: View {
    let title: String
    var showBackButton: Bool = false
    var onBack: (() -> Void)?
    var onChangeCity: (() -> Void)?
    var onNotifications: (() -> Void)?

    @EnvironmentObject private var app: AppState

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            leading
            Spacer(minLength: 8)
            trailing
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(.separator).opacity(0.35))
                .frame(height: 0.5)
        }
    }

    @ViewBuilder
    private var leading: some View {
        HStack(spacing: 10) {
            if showBackButton {
                Button {
                    onBack?()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .frame(width: 40, height: 40)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            } else {
                Text(headerGlyph)
                    .font(.title3.weight(.black))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Text((app.currentCity?.displayName ?? "Local").uppercased())
                        .font(.caption2.weight(.bold))
                        .tracking(1.2)
                        .foregroundStyle(Theme.textSecondary)
                    if onChangeCity != nil {
                        Button("(Change)") {
                            onChangeCity?()
                        }
                        .font(.caption2.weight(.bold))
                        .tracking(1.2)
                        .foregroundStyle(Theme.primary)
                    }
                }
            }
        }
    }

    private var trailing: some View {
        HStack(spacing: 8) {
            if let onNotifications {
                Button(action: onNotifications) {
                    Image(systemName: "bell.fill")
                        .font(.body)
                        .frame(width: 40, height: 40)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var headerGlyph: String {
        let source = title.isEmpty ? (app.currentCity?.displayName ?? "T") : title
        return String(source.prefix(1)).uppercased()
    }
}
