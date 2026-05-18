import XCTest
import TribeCore
@testable import Tribe

final class MessageSignerTests: XCTestCase {
    func testSignProducesVerifiableEnvelope() throws {
        let appKey = AppKey.generate()
        let body: [String: Any] = ["text": "hello tribe", "channel_id": "sf"]
        let envelopeData = try MessageSigner.sign(
            type: MessageType.tweetAdd.rawValue,
            tid: "42001",
            body: body,
            appKey: appKey,
            timestamp: 1_700_000_000
        )

        let envelope = try JSONSerialization.jsonObject(with: envelopeData) as? [String: Any]
        XCTAssertEqual(envelope?["protocolVersion"] as? Int, 1)

        guard let dataB64 = envelope?["dataB64"] as? String,
              let hashB64 = envelope?["hash"] as? String,
              let signatureB64 = envelope?["signature"] as? String,
              let signerB64 = envelope?["signer"] as? String,
              let dataBytes = Data(base64Encoded: dataB64),
              let hashBytes = Data(base64Encoded: hashB64),
              let signature = Data(base64Encoded: signatureB64),
              let signerBytes = Data(base64Encoded: signerB64) else {
            XCTFail("Malformed envelope fields")
            return
        }

        XCTAssertEqual(Blake3.hash(dataBytes), hashBytes)
        XCTAssertEqual(signerBytes, appKey.publicKey.rawRepresentation)
        XCTAssertTrue(try appKey.publicKey.isValidSignature(signature, for: hashBytes))

        let roundTrip = try JSONSerialization.jsonObject(with: envelopeData) as? [String: Any]
        let reencoded = try JSONSerialization.data(
            withJSONObject: roundTrip ?? [:],
            options: [.sortedKeys, .withoutEscapingSlashes]
        )
        XCTAssertEqual(envelopeData, reencoded)
    }

    func testNumericTidFitsInDataObject() throws {
        let appKey = AppKey.generate()
        let envelopeData = try MessageSigner.sign(
            type: MessageType.userDataAdd.rawValue,
            tid: "42",
            body: ["username": "alice"],
            appKey: appKey,
            timestamp: 1
        )
        let envelope = try JSONSerialization.jsonObject(with: envelopeData) as? [String: Any]
        let data = envelope?["data"] as? [String: Any]
        XCTAssertEqual(data?["tid"] as? Int, 42)
    }
}
