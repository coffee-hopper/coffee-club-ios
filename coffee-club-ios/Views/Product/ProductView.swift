import SwiftUI

struct ProductView: View {
    @Binding var isSearchFocused: Bool
    @Binding var searchText: String
    @Binding var category: String
    @Binding var searchTapShield: Bool

    let title: String
    let heightUnit: CGFloat

    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var nav: NavigationCoordinator
    @EnvironmentObject var selection: ProductSelection
    @Environment(\.appEnvironment) private var environment

    @StateObject private var vm = ProductViewModel()
    @State private var activeProductId: Int? = nil
    @FocusState private var tfFocused: Bool

    var body: some View {
        ZStack {
            VStack(spacing: 0) {

                // MARK: Header
                HStack(alignment: .center) {
                    Text("Special for you")
                        .font(.system(size: 20).bold())

                    Spacer()

                    Button("See All \(title.capitalized)s") {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            vm.openSeeAll()
                        }
                    }
                    .foregroundColor(Color(.accent))
                    .font(.system(size: 12).bold())
                }
                .frame(height: heightUnit * 0.07)
                .padding(.horizontal, 12)
                .padding(.top, 0)

                // MARK: Categories
                HStack {
                    categoryButton("Coffee", icon: "cup.and.heat.waves.fill", tag: "coffee")
                    Spacer()
                    categoryButton("Food", icon: "fork.knife", tag: "food")
                    Spacer()
                    categoryButton("Tea", icon: "mug", tag: "tea")
                }
                .padding(.horizontal, 12)
                .frame(height: heightUnit * 0.2)

                // MARK: SearchBar
                HStack {
                    let isActive = tfFocused || !searchText.isEmpty

                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(Color("TextSecondary"))
                            .frame(height: 1)
                            .frame(maxWidth: isActive ? 0 : .infinity, alignment: .leading)
                            .opacity(isActive ? 0 : 1)
                            .animation(.easeInOut(duration: 0.2), value: isActive)

                        TextField("Search...", text: $searchText)
                            .padding(.leading, 10)
                            .padding(.trailing, 10) 
                            .frame(height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(Color("TextSecondary"), lineWidth: 1)
                            )
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .focused($tfFocused)
                            .frame(maxWidth: isActive ? .infinity : 0, alignment: .leading)
                            .opacity(isActive ? 1 : 0)
                            .clipped()
                            .animation(.easeInOut(duration: 0.2), value: isActive)

                        IconButton(
                            systemName: (tfFocused || !searchText.isEmpty)
                                ? "xmark" : "magnifyingglass",
                            action: {
                                searchTapShield = true
                                withAnimation(.spring(response: 0.8, dampingFraction: 0.85)) {
                                    if tfFocused || !searchText.isEmpty {
                                        searchText = ""
                                        tfFocused = false
                                        isSearchFocused = false
                                    } else {
                                        isSearchFocused = true
                                        tfFocused = true
                                        DispatchQueue.main.async { tfFocused = true }
                                    }
                                }
                            },
                            isFilled: true,
                            bgFill: (tfFocused || !searchText.isEmpty)
                                ? Color("AccentRed")
                                : Color("GreenEnergic").opacity(0.6)
                        )
                    }
                    .frame(height: 70)
                    .padding(.horizontal, 12)
                    .contentShape(Rectangle())
                    /// Tell parent the tap originated inside search UI (so it doesn't auto-dismiss)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0).onChanged { _ in
                            if !searchTapShield { searchTapShield = true }
                        }
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isSearchFocused = true
                            tfFocused = true
                        }
                        DispatchQueue.main.async { tfFocused = true }
                    }
                }
                .frame(height: heightUnit * 0.15)

                // MARK: Horizontal products
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(vm.filteredProducts) { product in
                            ProductCard(
                                product: product,
                                heightUnit: heightUnit * 0.55,
                                activeProductId: $activeProductId
                            )
                        }
                    }
                    .padding(.horizontal, 12)
                }
                .frame(height: heightUnit * 0.55)
            }

            // MARK: State surface
            switch vm.state {
            case .loading:
                ProgressView().padding(.top, 8)
            case .error(let message):
                Text(message)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(.top, 6)
            default:
                EmptyView()
            }
        }
        .padding(.horizontal)
        .onAppear {
            vm.configure(
                productService: environment.productService,
                nav: nav,
                selection: selection,
                tokenProvider: { auth.token }
            )
            vm.searchText = searchText
            vm.selectedCategory = category
            tfFocused = isSearchFocused
            vm.load()
        }
        .onChange(of: searchText) { _, newValue in
            vm.searchText = newValue
            vm.filtersDidChange()
        }
        .onChange(of: category) { _, newValue in
            vm.selectedCategory = newValue
            vm.filtersDidChange()
        }
        /// two-way sync parent with TextField focus
        .onChange(of: isSearchFocused) { _, new in
            if new != tfFocused { tfFocused = new }
        }
        .onChange(of: tfFocused) { _, new in
            if new != isSearchFocused { isSearchFocused = new }
        }
    }

    private func categoryButton(_ label: String, icon: String, tag: String) -> some View {
        VStack(spacing: 6) {
            IconButton(systemName: icon) { category = tag }
            Text(label)
                .foregroundColor(
                    category == tag
                        ? Color("TextPrimary")
                        : Color("TextPrimary").opacity(0.45)
                )
                .font(.footnote)
        }
    }
}
