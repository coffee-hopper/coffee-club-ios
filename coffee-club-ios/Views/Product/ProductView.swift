import SwiftUI

struct ProductView: View {
    let title: String
    @Binding var showAllBinding: Bool
    @Binding var searchText: String
    @Binding var category: String

    @EnvironmentObject var auth: AuthViewModel
    @State private var allProducts: [Product] = []

    @State private var isSearching = false
    @FocusState private var isTextFieldFocused: Bool

    let heightUnit: CGFloat

    var filteredProducts: [Product] {
        allProducts
            .filter { product in
                product.category.localizedCaseInsensitiveContains(category)
                    && (searchText.isEmpty
                        || product.name.localizedCaseInsensitiveContains(searchText))
            }
    }

    var body: some View {
        ZStack {
            if isSearching {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            isSearching = false
                            isTextFieldFocused = false
                            searchText = ""
                        }
                    }
                    .ignoresSafeArea()
            }

            // MARK: Categories & SearchBar
            VStack(spacing: 0) {
                // MARK: Categories
                HStack {
                    VStack {
                        IconButton(systemName: "cup.and.heat.waves.fill") {
                            category = "drink"
                        }
                        Text("Drink")
                            .foregroundColor(
                                category == "drink"
                                    ? Color("TextPrimary") : Color("TextPrimary").opacity(0.45)
                            )
                    }

                    Spacer()

                    VStack {
                        IconButton(systemName: "fork.knife") {
                            category = "food"
                        }
                        Text("Food")
                            .foregroundColor(
                                category == "food"
                                    ? Color("TextPrimary") : Color("TextPrimary").opacity(0.45)
                            )
                    }

                    Spacer()

                    VStack {
                        IconButton(systemName: "mug") {
                            category = "tea"
                        }
                        Text("Tea")
                            .foregroundColor(
                                category == "tea"
                                    ? Color("TextPrimary") : Color("TextPrimary").opacity(0.45)
                            )
                    }
                }
                .padding(.horizontal, 12)
                .frame(height: heightUnit * 0.2)

                // MARK: SearchBar
                HStack {
                    ZStack {
                        //MARK: Invisible tap area to trigger search
                        Color.clear
                            .frame(height: 75)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if !isSearching {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        isSearching = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        isTextFieldFocused = true
                                    }
                                } else {
                                    withAnimation {
                                        isSearching = false
                                        isTextFieldFocused = false
                                        searchText = ""
                                    }
                                }
                            }

                        HStack {
                            if isSearching {
                                TextField("Search...", text: $searchText)
                                    .padding(.horizontal, 10)
                                    .frame(height: 40)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color("TextSecondary"), lineWidth: 1)
                                    )
                                    .focused($isTextFieldFocused)
                                    .transition(.opacity)
                            } else {
                                Color("TextSecondary").frame(height: 1)
                            }

                            IconButton(
                                systemName: "magnifyingglass",
                                action: {
                                    withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                                        isSearching.toggle()
                                    }

                                    if !isSearching {
                                        isTextFieldFocused = false
                                        searchText = ""
                                    } else {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            isTextFieldFocused = true
                                        }
                                    }
                                }
                            )
                        }
                        .frame(height: 70)
                        .padding(.horizontal, 12)
                    }
                }
                .frame(height: heightUnit * 0.15)

                // MARK: Product Cards & Header
                HStack(alignment: .center) {
                    Text("Special for you")
                        .font(.system(size: 20).bold())

                    Spacer()

                    Button("See All \(title.capitalized)s") {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            showAllBinding = true
                        }
                    }
                    .foregroundColor(Color(.accent))
                    .font(.system(size: 12).bold())
                }
                .frame(height: heightUnit * 0.1)
                .padding(.horizontal, 12)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(filteredProducts) { product in
                            ProductCard(product: product, heightUnit: heightUnit * 0.55)
                        }
                    }

                }
                .frame(height: heightUnit * 0.55)
            }
        }
        .padding(.horizontal)
        .onAppear {
            fetchProducts()
        }
    }

    private func fetchProducts() {
        guard let token = auth.token else {
            print("❌ No token available in ProductView")
            return
        }

        guard let url = URL(string: "http://localhost:3000/products") else {
            print("❌ Invalid /products endpoint")
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("❌ Product fetch error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("⚠️ No product response")
                return
            }

            do {
                let decoded = try JSONDecoder().decode([Product].self, from: data)
                DispatchQueue.main.async {
                    self.allProducts = decoded
                }
                print("✅ Products loaded: \(decoded.count)")
            } catch {
                print("❌ JSON decode error: \(error.localizedDescription)")
            }
        }.resume()
    }
}

#Preview {
    let auth = AuthViewModel()
    return ContentView(auth: auth)
        .environmentObject(auth)
}
