//
//  ProductListView.swift
//  coffee-club-ios
//
//  Created by Bahadır Pekcan on 8.05.2025.
//

import SwiftUI

struct ProductListView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var products: [Product] = []

    var body: some View {
        NavigationView {
            List(products) { product in
                VStack(alignment: .leading) {
                    Text(product.name)
                        .font(.headline)
                    Text("\(product.price)₺")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Products")
        }
        .onAppear {
            fetchProducts()
        }
    }

    func fetchProducts() {
        guard let token = auth.token else {
            print("❌ No token available in ProductListView")
            return
        }

        guard let url = URL(string: "http://localhost:3000/products") else {
            print("❌ Invalid /products endpoint")
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
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
                    self.products = decoded
                }
                print("✅ Products loaded: \(decoded.count)")
            } catch {
                print("❌ JSON decode error: \(error.localizedDescription)")
            }
        }.resume()
    }
}

#Preview {
    ProductListView()
}
