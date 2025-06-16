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

            VStack(alignment: .leading) {
                // MARK: Categories View
                VStack(spacing: 10) {
                    HStack(spacing: 20) {

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

                    HStack(spacing: 10) {
                        ZStack {
                            //MARK: Invisible tap area to trigger search
                            Color.clear
                                .frame(height: 75)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if !isSearching {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6))
                                        {
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

                            //MARK: SearchBar
                            HStack(spacing: 10) {
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
                                    systemName: "magnifyingglass.circle.fill",
                                    action: {
                                        withAnimation(.spring(response: 0.8, dampingFraction: 0.8))
                                        {
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
                            .frame(height: 75)
                            .padding(.horizontal, 12)
                        }
                    }
                    .frame(height: 75)
                    .padding(.horizontal, 12)

                }

                HStack {
                    Text(title.capitalized)
                        .font(.title2.bold())
                    Spacer()
                    Button("See All \(title.capitalized)s") {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            showAllBinding = true
                        }
                    }
                    .foregroundColor(Color("TextPrimary"))
                }
                .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(filteredProducts) { product in
                            ProductCard(product: product)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
            .onAppear {
                fetchProducts()
            }
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
