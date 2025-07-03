import AuthenticationServices
import Foundation

class GoogleAuthService: NSObject {
    private var session: ASWebAuthenticationSession?

    func startLogin(completion: @escaping (String?, User?) -> Void) {
        guard let url = URL(string: "\(API.baseURL)/auth/google") else {
            completion(nil, nil)
            return
        }

        var request = URLRequest(url: url)
        request.setValue("ios", forHTTPHeaderField: "mobile-auth")

        //1: Get Google login URL from backend
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                let response = try? JSONDecoder().decode([String: String].self, from: data),
                let loginURLString = response["url"],
                let loginURL = URL(string: loginURLString)
            else {
                completion(nil, nil)
                return
            }

            //2: Launch Google OAuth session
            DispatchQueue.main.async {
                self.session = ASWebAuthenticationSession(
                    url: loginURL,
                    callbackURLScheme: "coffeeclub"
                ) { callbackURL, error in
                    guard let callbackURL = callbackURL,
                        let components = URLComponents(
                            url: callbackURL,
                            resolvingAgainstBaseURL: false
                        ),
                        let token = components.queryItems?.first(where: { $0.name == "token" })?
                            .value
                    else {
                        completion(nil, nil)
                        return
                    }

                    self.fetchUserProfile(token: token) { user in
                        completion(token, user)
                    }
                }

                self.session?.presentationContextProvider = self
                self.session?.start()
            }
        }.resume()
    }

    private func fetchUserProfile(token: String, completion: @escaping (User?) -> Void) {
        guard let url = URL(string: "\(API.baseURL)/auth/profile") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                let user = try? JSONDecoder().decode(User.self, from: data)
            else {
                completion(nil)
                return
            }
            completion(user)
        }.resume()
    }
}

extension GoogleAuthService: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.windows.first ?? ASPresentationAnchor()
    }
}
