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

                //MARK: Fixed Footer
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "house")
                        Spacer()
                        Image(systemName: "heart")
                        Spacer()
                        Image(systemName: "cart")
                        Spacer()
                        Image(systemName: "person.crop.circle")
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue)
                    .border(Color.pink)
                }
                .ignoresSafeArea(edges: .bottom)

                VStack(spacing: 0) {
                    Spacer().frame(height: 50)  // Reserve space for top fixed header

                    ScrollView(showsIndicators: false) {
                        VStack {
                            // MARK: Rewards Section
                            Rectangle()
                                .fill(Color.purple.opacity(0.2))
                                .frame(height: 150)
                                .overlay(Text("Rewards Box").foregroundColor(.purple))
                                .border(Color.blue)

                            // MARK: Navigate to ProductListView
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
