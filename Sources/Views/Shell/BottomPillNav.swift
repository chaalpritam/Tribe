import SwiftUI

struct BottomPillNav: View {
    @Binding var selectedTab: ShellTab
    var onCreate: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            ForEach(ShellTab.leftTabs) { tab in
                navButton(tab)
            }
            createButton
            ForEach(ShellTab.rightTabs) { tab in
                navButton(tab)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Theme.navPillBackground)
                .shadow(color: .black.opacity(0.25), radius: 16, y: 8)
                .overlay(
                    Capsule()
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
    }

    private func navButton(_ tab: ShellTab) -> some View {
        let active = selectedTab == tab
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        } label: {
            Image(systemName: tab.systemImage)
                .font(.system(size: 22, weight: active ? .bold : .medium))
                .foregroundStyle(active ? Color.black : Theme.navPillInactive)
                .frame(width: 48, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(active ? Theme.navPillActiveBackground : Color.clear)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
    }

    private var createButton: some View {
        Button(action: onCreate) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Theme.primary)
                        .shadow(color: Theme.primary.opacity(0.35), radius: 8, y: 4)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Create")
        .padding(.horizontal, 2)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var tab: ShellTab = .home
        var body: some View {
            ZStack {
                Color.gray.opacity(0.2).ignoresSafeArea()
                VStack {
                    Spacer()
                    BottomPillNav(selectedTab: $tab, onCreate: {})
                }
            }
        }
    }
    return PreviewWrapper()
}
