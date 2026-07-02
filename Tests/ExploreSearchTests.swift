import XCTest
@testable import Tribe

final class ExploreSearchTests: XCTestCase {
    func testScopedContentFiltersToActiveChannel() {
        let city = Channel(id: "brooklyn", name: "Brooklyn", kind: 2)
        let results = ExploreSearchResults(
            tweets: [
                makeTweet(channelId: "brooklyn"),
                makeTweet(channelId: "runners"),
            ]
        )

        let scoped = ExploreSearch.scoped(results, activeChannel: city)

        XCTAssertEqual(scoped.tweets.count, 1)
        XCTAssertEqual(scoped.tweets.first?.channelId, "brooklyn")
    }

    func testScopedTribesVisibleFromCityContext() {
        let city = Channel(id: "brooklyn", name: "Brooklyn", kind: 2)
        let tribe = Channel(id: "runners", name: "Runners", kind: 1)
        let results = ExploreSearchResults(channels: [city, tribe])

        let scoped = ExploreSearch.scoped(results, activeChannel: city)

        XCTAssertEqual(scoped.channels.map(\.id), ["brooklyn", "runners"])
    }

    func testScopedTribeContextHidesOtherChannels() {
        let tribe = Channel(id: "runners", name: "Runners", kind: 1)
        let other = Channel(id: "brooklyn", name: "Brooklyn", kind: 2)
        let results = ExploreSearchResults(channels: [tribe, other])

        let scoped = ExploreSearch.scoped(results, activeChannel: tribe)

        XCTAssertEqual(scoped.channels.map(\.id), ["runners"])
    }

    private func makeTweet(channelId: String) -> Tweet {
        Tweet(
            hash: UUID().uuidString,
            tid: "1",
            text: "hi",
            parentHash: nil,
            channelId: channelId,
            embeds: nil,
            timestamp: Date(),
            username: nil,
            replyCount: nil
        )
    }
}
