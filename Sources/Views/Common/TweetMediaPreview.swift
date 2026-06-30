import SwiftUI

/// Tweet image embeds, decoded through `ImageCache`.
struct TweetMediaPreview: View {
    @EnvironmentObject private var app: AppState

    let tweet: Tweet

    private var imageURLs: [URL] {
        (tweet.embeds ?? []).compactMap { app.api.resolveMediaURL($0) }
    }

    var body: some View {
        if !imageURLs.isEmpty {
            embedGrid(imageURLs)
                .padding(.top, 4)
        }
    }

    @ViewBuilder
    private func embedGrid(_ urls: [URL]) -> some View {
        let columns: [GridItem] = urls.count == 1
            ? [GridItem(.flexible())]
            : [GridItem(.flexible()), GridItem(.flexible())]
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(urls, id: \.self) { url in
                CachedAsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color(.tertiarySystemFill)
                }
                .frame(maxWidth: .infinity)
                .frame(height: urls.count == 1 ? 220 : 140)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }
}
