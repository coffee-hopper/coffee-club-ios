import SwiftUI

struct ProductListView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var coordinator: ViewCoordinator

    @Binding var isActive: Bool

    @State private var products: [Product] = []
    @State private var offsetY: CGFloat = 0
    @State private var currentIndex: CGFloat = 0

    let category: String

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let cardSize = size.width * 1

            ZStack {
                // Header View
                HeaderView(size: size)
                    .zIndex(2)

                // Coffee Cards
                VStack(spacing: 0) {
                    ForEach(products) { product in
                        ProductCardView(product: product, size: size)
                    }
                }
                .zIndex(0)
                .frame(width: size.width)
                .padding(.top, size.height - cardSize)
                .offset(y: offsetY)
                .offset(y: -currentIndex * cardSize)
                .coordinateSpace(name: "SCROLL")
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            offsetY = value.translation.height

                        }
                        .onEnded { value in
                            let translation = value.translation.height
                            withAnimation(.easeInOut) {
                                if translation > 0 {
                                    if currentIndex > 0 && translation > 250 {
                                        currentIndex -= 1
                                    }
                                } else {
                                    if currentIndex < CGFloat(products.count - 1)
                                        && -translation > 250
                                    {
                                        currentIndex += 1
                                    }
                                }
                                offsetY = .zero
                            }
                        }
                )
                .onAppear {
                    fetchProducts()
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    @ViewBuilder
    func HeaderView(size: CGSize) -> some View {
        VStack {
            HStack {
                IconButton(
                    systemName: "chevron.left",
                    action: {
                        isActive = false
                    },
                    isFilled: false,
                    iconSize: 28
                )

                Spacer()

                IconButton(
                    systemName: "cart",
                    action: {
                        print("cart_tapped @ProductListView")
                    },
                    isFilled: false,
                    iconSize: 30
                )
            }
            GeometryReader { geo in
                let width = geo.size.width
                HStack(spacing: 0) {
                    ForEach(products) { product in
                        VStack(spacing: 15) {
                            Text(product.name)
                                .font(.title.bold())
                                .multilineTextAlignment(.center)
                            Text("\(product.price)₺")
                                .font(.title)

                            Text("Go to product details")
                                .foregroundColor(Color("TextPrimary"))
                                .onTapGesture {
                                    coordinator.selectedProduct = product
                                    coordinator.showProductDetail = true
                                }
                        }
                        .frame(width: width)
                    }
                }
                .offset(x: currentIndex * -width)
                .animation(
                    .interactiveSpring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.8),
                    value: currentIndex
                )
            }
            .padding(.top, -5)
        }
        .padding(15)
    }

    func fetchProducts() {
        guard let token = auth.token else {
            print("❌ No token available in ProductListView")
            return
        }
        guard let url = URL(string: "http://localhost:3000/products?category=\(category)") else {
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
                    self.products = decoded.sorted { $0.id < $1.id }
                }
                print("✅ Products loaded: \(decoded.count)")
            } catch {
                print("❌ JSON decode error: \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct ProductCardView: View {
    let product: Product
    var size: CGSize

    var body: some View {
        let cardSize = size.width  //cup width
        let cardHeight = CGFloat(400)
        let maxCardsDisplaySize = size.width * 4  // card stack count between the current card

        GeometryReader { proxy in
            let _size = proxy.size
            let offset = proxy.frame(in: .named("SCROLL")).minY - (size.height - cardSize)
            let scale = offset <= 0 ? (offset / maxCardsDisplaySize) : 0
            let reducedScale = 1 + scale
            let currentCardScale = offset / cardSize

            Image(product.processedImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: _size.width, height: _size.height)
                .scaleEffect(
                    reducedScale < 0 ? 0.001 : reducedScale,
                    anchor: .init(x: 0.5, y: 1 - (currentCardScale / 2.4))
                )
                .scaleEffect(offset > 0 ? 1 + currentCardScale : 1, anchor: .top)
                .offset(y: offset > 0 ? currentCardScale * 200 : 0)
                .offset(y: currentCardScale * -130)
        }
        .frame(height: cardHeight)
    }
}
