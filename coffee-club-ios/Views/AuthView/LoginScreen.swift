//TODO :  Handle Sign in logic use new rafactored logic
import GoogleSignIn
import SwiftUI

struct LoginScreen: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        VStack {
            Text("Welcome")
                .font(.title)
                .padding(.bottom, 40)

            Button(action: handleSignupButton) {
                Text("Log in with Google")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("AccentBlue"))
                    .foregroundColor(Color("TextPrimary"))
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            

        }
        .padding(.vertical, 80)
    }

    func handleSignupButton() {
        print("🚀 Sign in with Google clicked")

        guard let rootViewController = getRootViewController() else {
            print("❌ Failed to get root view controller")
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            guard let result else {
                print("❌ Google Sign-In failed: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            guard let idToken = result.user.idToken?.tokenString else {
                print("❌ No ID Token received from Google")
                return
            }

            print("✅ Google login success for: \(result.user.profile?.email ?? "unknown")")
            sendTokenToBackend(idToken: idToken)
        }
    }

    func sendTokenToBackend(idToken: String) {
        guard let url = URL(string: "http://localhost:3000/auth/google/mobile") else {
            print("❌ Invalid backend URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("ios", forHTTPHeaderField: "mobile-auth")

        let body: [String: String] = ["token": idToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Request failed: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No response data")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let token = json["token"] as? String,
                    let userDict = json["user"] as? [String: Any],
                    let id = userDict["id"] as? Int,
                    let username = userDict["username"] as? String,
                    let role = userDict["role"] as? String
                {
                    let picture = userDict["googlePicture"] as? String
                    print("✅ Logged in. Token: \(token)")
                    print("👤 User: \(userDict)")

                    let user = User(id: String(id), name: username, role: role, picture: picture)
                    DispatchQueue.main.async {
                        auth.storeSession(token: token, user: user)
                    }
                } else {
                    print("⚠️ Unexpected response format")
                }
            } catch {
                print("❌ JSON decode error: \(error.localizedDescription)")
            }
        }.resume()
    }
}

#Preview {
    LoginScreen()
}

func getRootViewController() -> UIViewController? {
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
        let rootViewController = scene.windows.first?.rootViewController
    else {
        return nil
    }
    return getVisibleViewController(from: rootViewController)
}

private func getVisibleViewController(from vc: UIViewController) -> UIViewController {
    if let nav = vc as? UINavigationController {
        return getVisibleViewController(from: nav.visibleViewController!)
    }
    if let tab = vc as? UITabBarController {
        return getVisibleViewController(from: tab.selectedViewController!)
    }
    if let presented = vc.presentedViewController {
        return getVisibleViewController(from: presented)
    }
    return vc
}
