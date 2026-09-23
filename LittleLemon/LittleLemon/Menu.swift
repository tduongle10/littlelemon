import SwiftUI
import CoreData

struct Menu: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: []) private var allDishes: FetchedResults<Dish>
    @State private var searchText: String = ""
    @State private var selectedCategory: String?

    private let categoryOrder = ["starters", "mains", "desserts", "drinks"]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero
                orderSection

                FetchedObjects(predicate: buildPredicate(), sortDescriptors: buildSortDescriptors()) { (dishes: [Dish]) in
                    LazyVStack(spacing: 16) {
                        ForEach(dishes) { dish in
                            dishCard(dish)
                        }
                    }
                    .padding(.top, 16)
                }
                .padding(.horizontal, 24)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            getMenuData()
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: -21) {
                Text("Little Lemon")
                    .font(.displayTitle)
                    .foregroundColor(.primaryYellow)
                Text("Chicago")
                    .font(.subTitle)
                    .foregroundColor(.secondaryLightGray)
            }

            HStack(alignment: .top, spacing: 6) {
                Text("We are a family owned Mediterranean restaurant, focused on traditional recipes served with a modern twist.")
                    .font(.leadText)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                Image("hero-image")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 160)
                    .offset(y: -49)
                    .frame(width: 160, height: 160, alignment: .top)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            HStack(spacing: 8) {
                Image("search-icon")
                    .resizable()
                    .frame(width: 24, height: 24)
                TextField("Search", text: $searchText, prompt: Text("Search").foregroundColor(.primaryGreen))
                    .font(.paragraphText)
                    .submitLabel(.search)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.secondaryLightGray)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.primaryGreen)
    }

    private var orderSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("ORDER FOR DELIVERY!")
                .font(.sectionTitle)
                .foregroundColor(.black)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        categoryPill(category)
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.horizontal, -24)
        }
        .padding(.top, 40)
        .padding(.bottom, 32)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.secondaryDarkGray.opacity(0.25))
                .frame(height: 1)
        }
        .padding(.horizontal, 24)
    }

    private var categories: [String] {
        let present = Set(allDishes.compactMap { $0.category?.lowercased() })
        return categoryOrder.filter { present.contains($0) } + present.subtracting(categoryOrder).sorted()
    }

    private func categoryPill(_ category: String) -> some View {
        let isSelected = selectedCategory == category
        return Button {
            selectedCategory = isSelected ? nil : category
        } label: {
            Text(category.capitalized)
                .font(.categoryText)
                .foregroundColor(isSelected ? .secondaryLightGray : .primaryGreen)
                .padding(10)
                .background(isSelected ? Color.primaryGreen : Color.secondaryLightGray)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func dishCard(_ dish: Dish) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 15) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(dish.title ?? "")
                        .font(.cardTitle)
                        .foregroundColor(.black)
                    Text(dish.dishDescription ?? "")
                        .font(.paragraphText)
                        .foregroundColor(.primaryGreen)
                        .lineLimit(2)
                        .frame(height: 43, alignment: .top)
                    Text(formattedPrice(dish.price))
                        .font(.leadText)
                        .foregroundColor(.primaryGreen)
                        .frame(height: 43, alignment: .top)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                AsyncImage(url: URL(string: dish.image ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 83, height: 83)
                .clipped()
            }

            Rectangle()
                .fill(Color.secondaryLightGray)
                .frame(height: 1)
        }
    }

    private func formattedPrice(_ price: String?) -> String {
        guard let price, let value = Double(price) else { return price ?? "" }
        return String(format: "$%.2f", value)
    }

    func getMenuData() {
        PersistenceController.shared.clear()

        let urlString = "https://raw.githubusercontent.com/Meta-Mobile-Developer-PC/Working-With-Data-API/main/menu.json"
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                let fullMenu = try? decoder.decode(MenuList.self, from: data)

                DispatchQueue.main.async {
                    for menuItem in fullMenu?.menu ?? [] {
                        let dish = Dish(context: viewContext)
                        dish.title = menuItem.title
                        dish.image = menuItem.image
                        dish.price = menuItem.price
                        dish.dishDescription = menuItem.description
                        dish.category = menuItem.category
                    }

                    try? viewContext.save()
                }
            }
        }
        task.resume()
    }

    func buildSortDescriptors() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.localizedStandardCompare))]
    }

    func buildPredicate() -> NSPredicate {
        var predicates: [NSPredicate] = []
        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "title CONTAINS[cd] %@", searchText))
        }
        if let selectedCategory {
            predicates.append(NSPredicate(format: "category ==[c] %@", selectedCategory))
        }
        return predicates.isEmpty ? NSPredicate(value: true) : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}

#Preview {
    Menu()
}
