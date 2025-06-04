import SwiftUI

struct ProductCard: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(product.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 80)
                .cornerRadius(8)

            HStack {
                Text(product.name)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(.primary)

                Spacer()

                Text("\(product.price)₺")
                    .font(.subheadline.bold())
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.4), lineWidth: 1)
        )
        .frame(width: 140, height: 180)
    }
}
