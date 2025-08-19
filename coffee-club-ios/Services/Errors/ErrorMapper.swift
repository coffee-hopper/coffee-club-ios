import Foundation

struct ErrorMapper {
    static func message(for error: Error) -> String {
        if let app = error as? AppError {
            switch app {
            case .unauthorized: return "Oturum süresi doldu. Lütfen tekrar giriş yapın."
            case .timeout: return "İstek zaman aşımına uğradı. İnternet bağlantınızı kontrol edin."
            case .connectivity: return "Şu anda bağlanılamıyor. Lütfen tekrar deneyin."
            case .http(_, let msg): return msg ?? "Sunucu hatası oluştu."
            case .decoding: return "Beklenmeyen veri formatı."
            case .cancelled: return "İşlem iptal edildi."
            case .network: return "Ağ hatası oluştu."
            case .unknown: return "Bilinmeyen bir hata oluştu."
            }
        }
        return "Bir hata oluştu."
    }
}
