import SwiftUI

struct ProductCard: View {
    let product: Product

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(product.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 80)
                .cornerRadius(8)

            HStack {
                Text(product.name)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(Color.accentLight)

                Text("\(product.price)₺")
                    .font(.subheadline.bold())
                    .foregroundColor(Color.greenEnergic)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.accentDark).opacity(0.85)
        )
        .frame(width: 140, height: 180)
    }
}
