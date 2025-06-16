import SwiftUI

struct RewardView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var loyaltyStats: LoyaltyStats? = LoyaltyStats(
        stars: 1,
        rewards: 2,
        remainingToNext: 3
    )

    var body: some View {
        HStack(spacing: 20) {
            Spacer()

            VStack(alignment: .leading, spacing: 8) {
                Text("Stars")
                    .foregroundColor(Color("GreenEnergic").opacity(0.8))

                HStack(alignment: .center, spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(loyaltyStats?.stars ?? 0)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }

                Text("\(loyaltyStats?.rewards ?? 0) free Coffee")
                    .foregroundColor(Color("GreenEnergic").opacity(0.7))
                    .font(.footnote)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                Circle()
                    .stroke(lineWidth: 8)
                    .opacity(0.1)
                    .foregroundColor(Color("TextPrimary"))

                Circle()
                    .trim(
                        from: 0,
                        to: CGFloat(min(CGFloat(loyaltyStats?.remainingToNext ?? 0) / 15.0, 1.0))
                    )
                    .stroke(Color("GreenEnergic"), lineWidth: 8)
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.easeOut(duration: 0.8), value: loyaltyStats?.stars)

                VStack {
                    Image("default_coffee")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .padding(.top, -10)

                    Text("\(loyaltyStats?.remainingToNext ?? 0)/15")
                        .font(.footnote)
                        .foregroundColor(Color("TextSecondary"))
                }
            }
            .frame(width: 110, height: 110)

            Spacer()

        }
        .frame(height: 160)
        .background(Color("AccentDark").opacity(0.85))
        .cornerRadius(16)
        .padding(.horizontal)

        .onAppear {
            fetchLoyaltyData()
        }
    }

    private func fetchLoyaltyData() {
        guard let userId = auth.user?.id else {
            print("❌ User ID missing")
            return
        }

        guard let token = auth.token else {
            print("❌ Missing token, cannot set Authorization header")
            return
        }

        guard let url = URL(string: "\(API.baseURL)/loyalty/user/\(userId)/stars") else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Response Code:", httpResponse.statusCode)
            }

            guard let data = data else {
                print("❌ No data received")
                return
            }

            if let rawString = String(data: data, encoding: .utf8) {
                print("📦 Raw Response:\n\(rawString)")
            }

            do {
                let decoded = try JSONDecoder().decode(LoyaltyStats.self, from: data)
                DispatchQueue.main.async {
                    self.loyaltyStats = decoded
                }
            } catch {
                print("❌ Failed to decode loyalty stats:", error)
            }
        }
        .resume()
    }
}

#Preview {
    let auth = AuthViewModel()
    return ContentView(auth: auth)
        .environmentObject(auth)
}
