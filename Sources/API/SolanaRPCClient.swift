import Foundation

/// Minimal JSON-RPC client for Solana balance reads (`getBalance`).
enum SolanaRPCClient {
    static var endpoint: URL {
        switch Config.solanaCluster {
        case "mainnet-beta":
            return URL(string: "https://api.mainnet-beta.solana.com")!
        case "testnet":
            return URL(string: "https://api.testnet.solana.com")!
        default:
            return URL(string: "https://api.devnet.solana.com")!
        }
    }

    static func fetchBalance(lamportsFor address: String) async throws -> UInt64 {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "jsonrpc": "2.0",
            "id": 1,
            "method": "getBalance",
            "params": [address],
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200 ..< 300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let decoded = try JSONDecoder().decode(RPCResponse.self, from: data)
        if let err = decoded.error {
            throw RPCError(message: err.message)
        }
        return decoded.result?.value ?? 0
    }

    private struct RPCResponse: Decodable {
        let result: BalanceResult?
        let error: RPCErrorBody?
    }

    private struct BalanceResult: Decodable {
        let value: UInt64
    }

    private struct RPCErrorBody: Decodable {
        let message: String
    }

    struct RPCError: LocalizedError {
        let message: String
        var errorDescription: String? { message }
    }
}
