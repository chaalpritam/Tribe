import Foundation

private final class FixtureLoaderToken {}

enum FixtureLoader {
    private static let bundle = Bundle(for: FixtureLoaderToken.self)

    static func data(named name: String) throws -> Data {
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            throw NSError(
                domain: "FixtureLoader",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Missing fixture \(name).json in test bundle"]
            )
        }
        return try Data(contentsOf: url)
    }

    static func decode<T: Decodable>(_ type: T.Type, named name: String) throws -> T {
        let data = try data(named: name)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
