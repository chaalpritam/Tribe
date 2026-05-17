import SwiftUI

/// First tweet image embed, decoded through `ImageCache`.
struct TweetMediaPreview: View {
    @EnvironmentObject private var app: AppState

    let tweet: Tweet
    var maxHeight: CGFloat = 280

    private var mediaURL: URL? {
        tweet.firstMediaURL(resolver: app.api.resolveMediaURL)
    }

    var body: some View {
        if let mediaURL {
            CachedAsyncImage(url: mediaURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(white: 0.94))
                    .overlay { ProgressView() }
            }
            .frame(maxWidth: .infinity)
            .frame(height: maxHeight)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}
