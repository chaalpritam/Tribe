import XCTest
@testable import Tribe

final class HubDecodeTests: XCTestCase {
    private struct BigIntRow: Decodable {
        let tid: String
        enum CodingKeys: String, CodingKey { case tid }
        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            tid = try HubDecode.bigInt(c, forKey: .tid)
        }
    }

    private struct DateRow: Decodable {
        let at: Date
        enum CodingKeys: String, CodingKey { case at }
        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            at = try HubDecode.date(c, forKey: .at)
        }
    }

    private struct CountRow: Decodable {
        let n: Int
        enum CodingKeys: String, CodingKey { case n }
        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            n = HubDecode.intCount(c, forKey: .n)
        }
    }

    func testBigIntFromStringAndNumber() throws {
        let stringJSON = #"{"tid":"9007199254740993"}"#.data(using: .utf8)!
        let numberJSON = #"{"tid":42001}"#.data(using: .utf8)!
        XCTAssertEqual(try JSONDecoder().decode(BigIntRow.self, from: stringJSON).tid, "9007199254740993")
        XCTAssertEqual(try JSONDecoder().decode(BigIntRow.self, from: numberJSON).tid, "42001")
    }

    func testDateFromISOAndEpoch() throws {
        let isoJSON = #"{"at":"2025-05-01T12:00:00.000Z"}"#.data(using: .utf8)!
        let epochJSON = #"{"at":1714564800}"#.data(using: .utf8)!
        let iso = try JSONDecoder().decode(DateRow.self, from: isoJSON).at
        let epoch = try JSONDecoder().decode(DateRow.self, from: epochJSON).at
        XCTAssertEqual(iso.timeIntervalSince1970, epoch.timeIntervalSince1970, accuracy: 1)
    }

    func testIntCountFromStringAndNumber() throws {
        let stringJSON = #"{"n":"12"}"#.data(using: .utf8)!
        let numberJSON = #"{"n":34}"#.data(using: .utf8)!
        XCTAssertEqual(try JSONDecoder().decode(CountRow.self, from: stringJSON).n, 12)
        XCTAssertEqual(try JSONDecoder().decode(CountRow.self, from: numberJSON).n, 34)
    }
}
