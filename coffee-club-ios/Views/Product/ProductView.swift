import SwiftUI

struct ProductView: View {
    let title: String
    @Binding var showAllBinding: Bool
    @Binding var searchText: String
    @Binding var category: String

    let heightUnit: CGFloat

    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var coordinator: ViewCoordinator
    @EnvironmentObject var nav: NavigationCoordinator
    @Environment(\.appEnvironment) private var environment

    @StateObject private var vm: ProductListViewModel

    init(
        title: String,
        showAllBinding: Binding<Bool>,
        searchText: Binding<String>,
        category: Binding<String>,
        heightUnit: CGFloat,
        environment: AppEnvironment,
        nav: NavigationCoordinator
    ) {
        self.title = title
        self._showAllBinding = showAllBinding
        self._searchText = searchText
        self._category = category
        self.heightUnit = heightUnit
        _vm = StateObject(
            wrappedValue: ProductListViewModel(
                productService: environment.productService,
                tokenProvider: environment.tokenProvider,
                nav: nav,
                selectedCategory: category.wrappedValue,
                searchText: searchText.wrappedValue
            )
        )
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

            // MARK: Categories & SearchBar
            VStack(spacing: 0) {

                // MARK: Product Cards & Header
                HStack(alignment: .center) {
                    Text("Special for you")
                        .font(.system(size: 20).bold())

                    Spacer()

                    Button("See All \(title.capitalized)s") {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            showAllBinding = true
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
                    VStack {
                        IconButton(systemName: "cup.and.heat.waves.fill") {
                            category = "coffee"
                        }
                        Text("Coffee")
                            .foregroundColor(
                                category == "coffee"
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
                .frame(height: heightUnit * 0.2)

                // MARK: SearchBar
                HStack {
                    ZStack {
                        //MARK: Invisible tap area to trigger search
                        Color.clear
                            .frame(height: 75)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if !isSearching {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
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

                        HStack {
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
                                systemName: "magnifyingglass",
                                action: {
                                    withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
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
                        .frame(height: 70)
                        .padding(.horizontal, 12)
                    }
                }
                .frame(height: heightUnit * 0.15)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(vm.filtered) { product in
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

            switch vm.state {
            case .loading:
                ProgressView().scaleEffect(1.2)
            case .error(let msg):
                Text(msg).font(.callout).foregroundColor(.red).padding(.top, 8)
            default:
                EmptyView()
            }
        }
        .padding(.horizontal)
        .onAppear {
            vm.load()
        }
        .onChange(of: category) { vm.selectedCategory = category }
        .onChange(of: searchText) { vm.searchText = searchText }
    }

    // MARK: - Local UI state for search field
    @State private var isSearching = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var activeProductId: Int? = nil
}
