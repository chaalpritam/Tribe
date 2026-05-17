import Foundation

/// Curated city metadata when the hub has no kind=2 channels yet.
/// Mirrors `tribeapp.wtf/src/lib/cities.ts`.
struct CityCatalogEntry: Identifiable, Hashable {
    let id: String
    let name: String
    let country: String

    var channel: Channel {
        Channel(id: id, name: name, kind: 2)
    }
}

enum CityCatalog {
    static let fallback: [CityCatalogEntry] = [
        CityCatalogEntry(id: "bangalore", name: "Bangalore", country: "India"),
        CityCatalogEntry(id: "bengaluru", name: "Bengaluru", country: "India"),
        CityCatalogEntry(id: "mumbai", name: "Mumbai", country: "India"),
        CityCatalogEntry(id: "delhi", name: "Delhi", country: "India"),
        CityCatalogEntry(id: "chennai", name: "Chennai", country: "India"),
        CityCatalogEntry(id: "hyderabad", name: "Hyderabad", country: "India"),
        CityCatalogEntry(id: "kolkata", name: "Kolkata", country: "India"),
        CityCatalogEntry(id: "pune", name: "Pune", country: "India"),
        CityCatalogEntry(id: "san-francisco", name: "San Francisco", country: "United States"),
        CityCatalogEntry(id: "london", name: "London", country: "United Kingdom"),
        CityCatalogEntry(id: "new-york", name: "New York", country: "United States"),
        CityCatalogEntry(id: "singapore", name: "Singapore", country: "Singapore"),
        CityCatalogEntry(id: "tokyo", name: "Tokyo", country: "Japan"),
    ]
}
