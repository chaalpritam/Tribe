import SwiftUI

/// Tappable Explore preview row that pushes the full interactive card.
struct ExplorePreviewLink<Label: View>: View {
    let route: ExploreItemRoute
    @ViewBuilder let label: () -> Label

    var body: some View {
        NavigationLink(value: route) {
            label()
                .overlay(alignment: .trailing) {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                        .padding(.trailing, 18)
                }
        }
        .buttonStyle(.plain)
    }
}
