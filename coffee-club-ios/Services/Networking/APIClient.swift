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

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw AppError.network(underlying: nil) }
        guard (200..<300).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8)
            if http.statusCode == 401 { throw AppError.unauthorized }
            throw AppError.http(status: http.statusCode, message: message)
        }
        do { return try decoder.decode(T.self, from: data) } catch {
            throw AppError.decoding(underlying: error)
        }
    }
}

extension APIClient {
    func request<T: Decodable>(
        _ type: T.Type,
        _ path: String,
        query: [URLQueryItem],
        method: Method = .GET,
        token: String? = nil,
        headers: [String: String] = [:],
        body: (any Encodable)? = nil
    ) async throws -> T {
        var comps = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        let cleanPath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        comps.path = comps.path.appending("/").appending(cleanPath)
        comps.queryItems = query.isEmpty ? nil : query
        guard let url = comps.url else { throw AppError.network(underlying: nil) }

        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue
        if let token { req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        headers.forEach { req.setValue($1, forHTTPHeaderField: $0) }

        if let body {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try encoder.encode(AnyEncodable(body))
        }

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw AppError.network(underlying: nil) }
        guard (200..<300).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8)
            if http.statusCode == 401 { throw AppError.unauthorized }
            throw AppError.http(status: http.statusCode, message: message)
        }
        do { return try decoder.decode(T.self, from: data) } catch {
            throw AppError.decoding(underlying: error)
        }
    }
}

private struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    init(_ wrapped: any Encodable) { _encode = wrapped.encode }
    func encode(to encoder: Encoder) throws { try _encode(encoder) }
}
