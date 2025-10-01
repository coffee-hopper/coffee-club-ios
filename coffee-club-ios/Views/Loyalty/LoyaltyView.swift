import SwiftUI

struct LoyaltyView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.appEnvironment) private var env

    @StateObject private var vm = LoyaltyViewModel()

    private func currentDrinkStack(_ s: LoyaltyStatus) -> Int {
        let required = max(s.requiredStars, 1)
        return required - s.remainingToNext
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
                        Text("\(vm.status.stars)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Text("\(vm.status.rewards) free Coffee")
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

                    let stack = currentDrinkStack(vm.status)
                    let required = max(vm.status.requiredStars, 1)
                    let progress = min(max(CGFloat(stack) / CGFloat(required), 0), 1)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color("GreenEnergic"), lineWidth: 8)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 0.8), value: vm.status.stars)
                        .frame(height: geo.size.height * 0.75)

                    VStack(alignment: .center, spacing: geo.size.height * 0.15) {
                        ZStack {
                            GIFView(name: "free_coffee")
                                .frame(width: geo.size.height * 2.5, height: geo.size.height * 2.5)
                                .scaleEffect(0.25)
                                .clipped(antialiased: false)
                        }
                        .frame(width: geo.size.height * 0.4, height: geo.size.height * 0.4)

                        Text("\(stack)/\(required)")
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
            .overlay(alignment: .topTrailing) {
                // Lightweight state surface
                switch vm.state {
                case .loading:
                    ProgressView()
                        .scaleEffect(0.8)
                        .padding(10)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding([.top, .trailing], 10)
                case .error(let msg):
                    Text(msg)
                        .font(.caption2)
                        .foregroundColor(.red)
                        .padding(8)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding([.top, .trailing], 10)
                default:
                    EmptyView()
                }
            }
            .onAppear {
                guard let uid = auth.user?.id else { return }
                vm.configure(
                    loyaltyService: env.loyaltyService,
                    userId: uid,
                    tokenProvider: { auth.token }
                )
                vm.refresh()
            }
        }
    }
}
