#if DEBUG
    import Foundation
    import os.log
    import KeychainAccess

    enum KeychainDebug {
        private static let log = Logger(subsystem: "app.coffeeclub", category: "Keychain")

        /// Logs current keychain state (masked, safe). Call from App launch + after save/clear.
        @MainActor
        static func snapshot(_ keychain: Keychain, context: String) {
            let jwt = keychain["jwt"]
            let userB64 = keychain["user"]

            log.info(
                "🔐 snapshot(\(context, privacy: .public)) → jwt.exists=\(jwt != nil ? "yes" : "no"), user.exists=\(userB64 != nil ? "yes" : "no")"
            )

            if let jwt {
                let masked = mask(jwt)
                if let claims = decodeJWTClaims(jwt) {
                    let sub = (claims["sub"] as? CustomStringConvertible)?.description ?? "nil"
                    let role = claims["role"] as? String ?? "nil"
                    let iat = (claims["iat"] as? Double).map { Date(timeIntervalSince1970: $0) }
                    let exp = (claims["exp"] as? Double).map { Date(timeIntervalSince1970: $0) }
                    let aud = claims["aud"] as? String ?? "nil"
                    let ttl = exp.map { Int($0.timeIntervalSinceNow) } ?? nil

                    log.info(
                        """
                        jwt(masked)=\(masked, privacy: .private) \
                        aud=\(aud, privacy: .private) \
                        sub=\(sub, privacy: .private) role=\(role, privacy: .private) \
                        iat=\(fmt(iat), privacy: .public) exp=\(fmt(exp), privacy: .public) \
                        ttl_sec=\(ttl.map(String.init) ?? "nil", privacy: .public)
                        """
                    )
                } else {
                    log.error("jwt: failed to decode claims")
                }
            }

            if let b64 = userB64, let data = Data(base64Encoded: b64) {
                if let user = try? JSONDecoder().decode(User.self, from: data) {
                    log.info(
                        "user → id=\(user.id) name=\(user.name, privacy: .private) role=\(user.role, privacy: .public)"
                    )
                } else {
                    log.error("user: base64 decode failed (bytes=\(data.count))")
                }
            }
        }

        private static func mask(_ token: String) -> String {
            let n = token.count
            guard n > 18 else { return "••• len=\(n)" }
            return "\(token.prefix(12))…\(token.suffix(6)) len=\(n)"
        }

        private static func fmt(_ d: Date?) -> String {
            guard let d else { return "nil" }
            let f = ISO8601DateFormatter()
            f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return f.string(from: d)
        }

        /// Minimal JWT claims decoder (no validation).
        private static func decodeJWTClaims(_ jwt: String) -> [String: Any]? {
            let parts = jwt.split(separator: ".")
            guard parts.count == 3 else { return nil }
            func b64urlToData(_ s: Substring) -> Data? {
                var str = String(s).replacingOccurrences(of: "-", with: "+").replacingOccurrences(
                    of: "_",
                    with: "/"
                )
                while str.count % 4 != 0 { str.append("=") }
                return Data(base64Encoded: str)
            }
            guard let payload = b64urlToData(parts[1]),
                let obj = try? JSONSerialization.jsonObject(with: payload) as? [String: Any]
            else { return nil }
            return obj
        }
    }
#endif
