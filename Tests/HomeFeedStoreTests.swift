import XCTest
@testable import Tribe

@MainActor
final class HomeFeedStoreTests: XCTestCase {
    func testPrependTweetDedupesAndOrdersNewestFirst() {
        let store = HomeFeedStore()
        let older = Tweet(
            hash: "older",
            tid: "1",
            text: "a",
            parentHash: nil,
            channelId: "sf",
            embeds: nil,
            timestamp: Date(timeIntervalSince1970: 1),
            username: nil,
            replyCount: nil
        )
        let newer = Tweet(
            hash: "newer",
            tid: "1",
            text: "b",
            parentHash: nil,
            channelId: "sf",
            embeds: nil,
            timestamp: Date(timeIntervalSince1970: 2),
            username: nil,
            replyCount: nil
        )
        store.prependTweet(older)
        store.prependTweet(newer)
        XCTAssertEqual(store.items.map(\.id), ["tweet-newer", "tweet-older"])
        store.prependTweet(newer)
        XCTAssertEqual(store.items.count, 2)
    }

    func testRefreshWithoutCitySetsError() async {
        let store = HomeFeedStore()
        let app = AppState()
        app.currentCity = nil
        store.attach(app: app)
        await store.refresh()
        XCTAssertEqual(store.errorMessage, "No city selected.")
        XCTAssertTrue(store.items.isEmpty)
    }
}
