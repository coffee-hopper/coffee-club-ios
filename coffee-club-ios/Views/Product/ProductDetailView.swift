import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @EnvironmentObject var cart: CartManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Image(product.processedImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 260)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    Text(product.name)
                        .font(.title)
                        .bold()

                    HStack(spacing: 16) {
                        Text(product.category.capitalized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("Stock: \(product.stockQuantity)")
                            .font(.subheadline)
                            .foregroundColor(product.stockQuantity > 0 ? .green : .red)
                    }

                    Text(PriceFormatting.string(from: Decimal(product.price)))
                        .font(.title2.bold())
                        .foregroundColor(.accentColor)

                    Divider()

                    Text("Description")
                        .font(.headline)
                    Text(product.description ?? "No description available.")
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal)

                Spacer(minLength: 24)

                Button(action: {
                    cart.addToCart(product)
                }) {
                    Text("Add to Cart")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            }
            .padding(.top)
        }
        .navigationTitle("Product Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}
