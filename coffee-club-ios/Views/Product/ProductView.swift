import SwiftUI

struct ProductView: View {
    let title: String
    @Binding var showAllBinding: Bool
    @Binding var searchText : String
    @Binding var category : String


    @EnvironmentObject var auth: AuthViewModel
    @State private var allProducts: [Product] = []

    var filteredProducts: [Product] {
        allProducts
            .filter { product in
                product.category.localizedCaseInsensitiveContains(category)
                    && (searchText.isEmpty
                        || product.name.localizedCaseInsensitiveContains(searchText))
            }
    }

    var body: some View {
        VStack(alignment: .leading) {
            // MARK: Categories View
            VStack(spacing: 10) {
                HStack(spacing: 20) {
                    Text("Drinks").onTapGesture { category = "drink" }
                    Text("Foods").onTapGesture { category = "food" }
                    Text("Teas").onTapGesture { category = "tea" }
                }
                .padding()

                Button {
                    // Optionally bring focus or trigger search logic
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)

                        TextField("Search...", text: $searchText)
                            .foregroundColor(.primary)
                            .disableAutocorrection(true)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.gray, lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())

            }
            .padding()
            .border(Color.green)
            
            
            HStack {
                Text(title.capitalized)
                    .font(.title2.bold())
                Spacer()
                Button("See All \(title.capitalized)") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        showAllBinding = true
                    }
                }
                .foregroundColor(.blue)
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
