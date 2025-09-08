//TODO: look for typed overload and keeping the old convenince (this logic added for generic t error fix)

import Foundation

final class APIClient {
    enum Method: String { case GET, POST, PUT, PATCH, DELETE }

    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(
        baseURL: URL,
        session: URLSession = .shared,
        decoder: JSONDecoder = NetworkCoders.decoder,
        encoder: JSONEncoder = NetworkCoders.encoder
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
    }

    func request<T: Decodable>(
        _ type: T.Type,
        _ path: String,
        method: Method = .GET,
        token: String? = nil,
        headers: [String: String] = [:],
        body: (any Encodable)? = nil
    ) async throws -> T {
        var url = baseURL
        url.append(path: path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))

        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue

        if let token { req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        headers.forEach { req.setValue($1, forHTTPHeaderField: $0) }

        if let body {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try encoder.encode(AnyEncodable(body))
        }

        do {
            let (data, resp) = try await session.data(for: req)

            guard let http = resp as? HTTPURLResponse else {
                throw AppError.network(underlying: nil)
            }

            guard (200..<300).contains(http.statusCode) else {
                let message = String(data: data, encoding: .utf8)
                if http.statusCode == 401 { throw AppError.unauthorized }
                throw AppError.http(status: http.statusCode, message: message)
            }

            do { return try decoder.decode(T.self, from: data) } catch {
                throw AppError.decoding(underlying: error)
            }

        } catch let err as URLError {
            switch err.code {
            case .timedOut: throw AppError.timeout
            case .notConnectedToInternet, .networkConnectionLost: throw AppError.connectivity
            case .cancelled: throw AppError.cancelled
            default: throw AppError.network(underlying: err)
            }
        } catch { throw AppError.unknown(underlying: error) }
    }

    // Keep old convenience; forward to typed overload
    func request<T: Decodable>(
        _ path: String,
        method: Method = .GET,
        token: String? = nil,
        headers: [String: String] = [:],
        body: (any Encodable)? = nil
    ) async throws -> T {
        try await request(T.self, path, method: method, token: token, headers: headers, body: body)
    }
}

private struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    init(_ wrapped: any Encodable) { _encode = wrapped.encode }
    func encode(to encoder: Encoder) throws { try _encode(encoder) }
}
