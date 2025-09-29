// TODO: Move fetchLoyaltyData() into LoyaltyService + LoyaltyViewModel.

import SwiftUI

struct RewardView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var loyaltyStatus = LoyaltyStatus(
        stars: 0,
        rewards: 0,
        remainingToNext: 0,
        requiredStars: 15
    )

    private var currentDrinkStack: Int {
        loyaltyStatus.requiredStars - loyaltyStatus.remainingToNext
    }

    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .center, spacing: 20) {

                VStack(alignment: .leading, spacing: 8) {
                    Text("Earned Stars")
                        .foregroundColor(Color("GreenEnergic").opacity(0.8))

                    HStack(alignment: .center, spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(loyaltyStatus.stars )")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Text("\(loyaltyStatus.rewards) free Coffee")
                        .foregroundColor(Color("GreenEnergic").opacity(0.7))
                        .font(.footnote)
                }
                .frame(
                    width: geo.size.width * 0.3,
                    height: geo.size.height * 0.75,
                    alignment: .leading
                )
                .padding(.leading)

                Spacer()

                ZStack {
                    Circle()
                        .stroke(lineWidth: 8)
                        .opacity(0.2)
                        .foregroundColor(Color("TextPrimary"))
                        .frame(height: geo.size.height * 0.75)

                    Circle()
                        .trim(
                            from: 0,
                            to: CGFloat(
                                min(
                                    CGFloat(currentDrinkStack)
                                        / CGFloat(loyaltyStatus.requiredStars),
                                    1.0
                                )
                            )
                        )
                        .stroke(Color("GreenEnergic"), lineWidth: 8)
                        .rotationEffect(Angle(degrees: -90))
                        .animation(.easeOut(duration: 0.8), value: loyaltyStatus.stars)
                        .frame(height: geo.size.height * 0.75)

                    VStack(alignment: .center, spacing: geo.size.height * 0.15) {
                        ZStack {
                            GIFView(name: "free_coffee")
                                .frame(width: geo.size.height * 2.5, height: geo.size.height * 2.5)
                                .scaleEffect(0.25)
                                .clipped(antialiased: false)
                        }
                        .frame(width: geo.size.height * 0.4, height: geo.size.height * 0.4)

                        Text("\(currentDrinkStack)/\(loyaltyStatus.requiredStars)")
                            .font(.footnote)
                            .foregroundColor(Color("TextSecondary"))
                    }
                }
                .padding(.trailing)
            }
            .frame(height: geo.size.height * 0.9)
            .background(Color("AccentDark").opacity(0.85))
            .cornerRadius(16)
            .padding(.horizontal)
            .onAppear {
                fetchLoyaltyData()
            }
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
                let decoded = try JSONDecoder().decode(LoyaltyStatus.self, from: data)
                DispatchQueue.main.async {
                    self.loyaltyStatus = decoded
                }
            } catch {
                print("❌ Failed to decode loyalty stats:", error)
            }
        }
        .resume()
    }
}

