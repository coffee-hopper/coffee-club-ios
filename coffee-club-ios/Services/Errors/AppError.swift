import Foundation

public enum AppError: Error {
    case network(underlying: Error?)
    case http(status: Int, message: String?)
    case decoding(underlying: Error?)
    case unauthorized
    case timeout
    case connectivity
    case cancelled
    case unknown(underlying: Error?)
}
