import SwiftUI

struct ContentView: View {
    var auth: AuthViewModel

    @State private var showProfile = false
    @State private var showProductListView = false
    @State private var selectedCategory = "drink"
    @State private var searchText: String = ""

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                MainHeaderView(showProfile: $showProfile)
                FooterView()

                VStack(spacing: 0) {
                    Spacer().frame(height: 50)

                    ScrollView(showsIndicators: false) {
                        VStack {
                            RewardView()

                            ProductView(
                                title: selectedCategory,
                                showAllBinding: $showProductListView,
                                searchText: $searchText,
                                category: $selectedCategory
                            ).padding()
                                .frame(maxWidth: .infinity)

                            Spacer().frame(height: 80)
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $showProductListView) {
                ProductListView(
                    isActive: $showProductListView,
                    category: selectedCategory
                )
                .environmentObject(auth)
            }
            .navigationDestination(isPresented: $showProfile) {
                ProfileView(isActive: $showProfile)
                    .environmentObject(auth)
            }
        }
    }
}

#Preview {
    let auth = AuthViewModel()
    return ContentView(auth: auth)
        .environmentObject(auth)
}
