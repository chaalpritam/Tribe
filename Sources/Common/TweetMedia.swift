import Foundation

extension Tweet {
    /// First image embed resolved through the hub media proxy.
    func firstMediaURL(resolver: (String) -> URL?) -> URL? {
        guard let embeds else { return nil }
        for embed in embeds {
            if let url = resolver(embed) {
                return url
            }
        }
        return nil
    }
}
