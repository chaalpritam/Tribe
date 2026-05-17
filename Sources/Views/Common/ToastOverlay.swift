import SwiftUI

struct ToastOverlay: View {
    @EnvironmentObject private var toasts: ToastCenter

    var body: some View {
        VStack {
            if let message = toasts.message {
                Text(message)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.88))
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            Spacer()
        }
        .animation(.easeInOut(duration: 0.2), value: toasts.message)
        .allowsHitTesting(false)
    }
}
