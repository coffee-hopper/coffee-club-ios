//TODO: currently Search bar isint activating probably isSearchFocussed state not triggering.

import SwiftUI

struct ProductView: View {
    @Binding var searchText: String
    @Binding var category: String

    let title: String
    let heightUnit: CGFloat

    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var coordinator: ViewCoordinator
    @Environment(\.appEnvironment) private var environment

    @StateObject private var vm = ProductViewModel()
    @State private var activeProductId: Int? = nil
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        ZStack {
            if searchText.isEmpty {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            searchText = ""
                            isSearchFocused = false
                        }
                    }
                    .ignoresSafeArea()
            }

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
                    ZStack {
                        // MARK: Invisible tap area to trigger search
                        Color.clear
                            .frame(height: 75)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    isSearchFocused = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isSearchFocused = true
                                }
                            }

                        HStack {
                            if isSearchFocused || !searchText.isEmpty {
                                TextField("Search...", text: $searchText)
                                    .padding(.horizontal, 10)
                                    .frame(height: 40)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color("TextSecondary"), lineWidth: 1)
                                    )
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)
                                    .focused($isSearchFocused)
                                    .transition(.opacity)
                            } else {
                                Color("TextSecondary").frame(height: 1)
                            }

                            IconButton(
                                systemName: "magnifyingglass",
                                action: {
                                    withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                                        // if there is text, treat tap as "clear"; otherwise focus and open the field
                                        if !searchText.isEmpty {
                                            searchText = ""
                                            isSearchFocused = false
                                        } else {
                                            isSearchFocused = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                isSearchFocused = true
                                            }
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

            //MARK: State (simple surface; no style change)
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
                coordinator: coordinator,
                tokenProvider: { auth.token }
            )
            vm.searchText = searchText
            vm.selectedCategory = category
            vm.load()
        }
        .onChange(of: searchText) { _, newValue in
            vm.searchText = newValue
        }
        .onChange(of: category) { _, newValue in
            vm.selectedCategory = newValue
        }
    }

    private func categoryButton(_ label: String, icon: String, tag: String) -> some View {
        VStack(spacing: 6) {
            IconButton(
                systemName: icon,
                action: { category = tag }
            )

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
