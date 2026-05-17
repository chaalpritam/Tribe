import Foundation

/// Hub IDs must match `^[a-z0-9-]{1,64}$`. Slug from title + random suffix.
enum Slug {
    static func make(_ input: String, randomSuffixLength: Int = 6) -> String {
        let lowered = input.lowercased()
        var stripped = ""
        stripped.reserveCapacity(lowered.count)
        for ch in lowered {
            if ch.isLetter || ch.isNumber {
                stripped.append(ch)
            } else if ch == " " || ch == "-" || ch == "_" {
                stripped.append("-")
            }
        }
        while stripped.contains("--") {
            stripped = stripped.replacingOccurrences(of: "--", with: "-")
        }
        stripped = stripped.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        if stripped.isEmpty { stripped = "tribe" }

        let suffix = randomHex(randomSuffixLength)
        let combined = "\(stripped)-\(suffix)"
        if combined.count > 64 {
            let dropAmount = combined.count - 64
            let body = String(stripped.dropFirst(dropAmount))
            return "\(body)-\(suffix)"
        }
        return combined
    }

    private static func randomHex(_ count: Int) -> String {
        let bytes = (0..<count).map { _ in UInt8.random(in: 0..<16) }
        return bytes.map { String($0, radix: 16) }.joined()
    }
}
