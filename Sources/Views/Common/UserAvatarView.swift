import SwiftUI

/// Avatar with optional hub profile image from `UserAvatarCache`.
struct UserAvatarView: View {
    @EnvironmentObject private var app: AppState

    let tid: String
    let initial: String
    var size: CGFloat = 48
    var seed: String?

    var body: some View {
        Group {
            if let url = app.userAvatars.pfpUrl(for: tid) {
                CachedAsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    AvatarInitial(seed: seed ?? initial, size: size)
                }
            } else {
                AvatarInitial(seed: seed ?? initial, size: size)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().strokeBorder(Color.white.opacity(0.18), lineWidth: 0.5))
        .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 1)
        .task(id: tid) {
            app.userAvatars.ensureLoaded(tid: tid)
        }
    }
}
