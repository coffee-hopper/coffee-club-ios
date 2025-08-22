import SwiftUI

struct LoginScreen: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        VStack {
            Text("Welcome")
                .font(.title)
                .padding(.bottom, 20)

            Button {
                auth.signInTapped()
            } label: {
                Group {
                    if case .loading = auth.state {
                        ProgressView()
                            .padding(.horizontal, 20)
                    } else {
                        Text("Log in with Google")
                            .padding(.horizontal, 20)
                    }
                }
                .padding()
            }
            .background(Color("AccentBlue"))
            .foregroundColor(Color("AccentLight"))
            .cornerRadius(12)

        }
        .padding(.vertical, 80)
        .alert(
            "Login Failed",
            isPresented: Binding(
                get: { auth.errorMessage != nil },
                set: { if !$0 { auth.errorMessage = nil } }
            ),
            actions: {},
            message: { Text(auth.errorMessage ?? "") }
        )
    }

    private struct Msg: Identifiable {
        let id = UUID()
        let text: String
    }
}
