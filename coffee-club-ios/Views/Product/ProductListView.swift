import SwiftUI

struct ProductListView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var nav: NavigationCoordinator
    @EnvironmentObject var selection: ProductSelection
    @Environment(\.appEnvironment) private var environment

    @Binding var isActive: Bool
    let category: String

    @StateObject private var vm = ProductListViewModel()

    @State private var offsetY: CGFloat = 0
    @State private var currentIndex: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let cardSize = size.width * 1

            ZStack {
                HeaderView(size: size)
                    .zIndex(2)

                VStack(spacing: 0) {
                    ForEach(vm.products) { product in
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
                                    if currentIndex < CGFloat(vm.products.count - 1)
                                        && -translation > 250
                                    {
                                        currentIndex += 1
                                    }
                                }
                                offsetY = .zero
                            }
                        }
                )
            }
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            vm.configure(
                productService: environment.productService,
                nav: nav,
                selection: selection,
                tokenProvider: { auth.token },
                initialCategory: category
            )
            vm.load()
        }
    }

    @ViewBuilder
    private func HeaderView(size: CGSize) -> some View {
        VStack {
            HStack {
                IconButton(
                    systemName: "chevron.left",
                    action: { isActive = false },
                    isFilled: false,
                    iconSize: 28
                )
                Spacer()
                IconButton(
                    systemName: "cart",
                    action: { nav.openCart() },
                    isFilled: false,
                    iconSize: 30
                )
            }

            GeometryReader { geo in
                let width = geo.size.width
                HStack(spacing: 0) {
                    ForEach(vm.products) { product in
                        VStack(spacing: 15) {
                            Text(product.name)
                                .font(.title.bold())
                                .multilineTextAlignment(.center)

                            Text("\(product.price)₺")
                                .font(.title)

                            IconButton(
                                systemName: "info",
                                action: {
                                    vm.onProductTapped(product)
                                },
                            )
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
}

struct ProductCardView: View {
    let product: Product
    var size: CGSize

    var body: some View {
        let cardSize = size.width
        let cardHeight = CGFloat(400)
        let maxCardsDisplaySize = size.width * 4

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
