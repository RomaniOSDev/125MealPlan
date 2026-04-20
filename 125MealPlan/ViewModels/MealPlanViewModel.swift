import Foundation
import Combine

final class MealPlanViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var mealPlans: [MealPlanItem] = []
    @Published var shoppingItems: [ShoppingItem] = []
    @Published var groceryLists: [GroceryList] = []
    @Published var searchText: String = ""
    @Published var selectedDate = Date()

    var filteredRecipes: [Recipe] {
        let sorted = recipes.sorted { lhs, rhs in
            if lhs.isFavorite != rhs.isFavorite {
                return lhs.isFavorite && !rhs.isFavorite
            }
            return lhs.name < rhs.name
        }
        guard !searchText.isEmpty else { return sorted }
        return sorted.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.cuisine.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }

    var mealPlanCount: Int { mealPlans.count }

    var favoriteCuisine: CuisineType? {
        let grouped = Dictionary(grouping: recipes, by: { $0.cuisine })
        return grouped.max { $0.value.count < $1.value.count }?.key
    }

    var averageCookTime: Int {
        guard !recipes.isEmpty else { return 0 }
        return recipes.reduce(0) { $0 + $1.totalTime } / recipes.count
    }

    struct MealTypeStat: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
        let count: Int
        let percentage: Double
    }

    var mealTypeStats: [MealTypeStat] {
        let grouped = Dictionary(grouping: mealPlans, by: { $0.mealType })
        let total = Double(mealPlans.count)
        return grouped.map { type, plans in
            MealTypeStat(
                name: type.rawValue,
                icon: type.icon,
                count: plans.count,
                percentage: total > 0 ? (Double(plans.count) / total) * 100 : 0
            )
        }
        .sorted { $0.count > $1.count }
    }

    struct TopRecipe: Identifiable {
        let id = UUID()
        let name: String
        let count: Int
    }

    var topRecipes: [TopRecipe] {
        let grouped = Dictionary(grouping: mealPlans.compactMap { $0.recipeName }, by: { $0 })
        return grouped.map { TopRecipe(name: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
            .prefix(5)
            .map { $0 }
    }

    func mealPlanForDate(_ date: Date) -> [MealPlanItem] {
        mealPlans.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    func addRecipe(_ recipe: Recipe) {
        recipes.append(recipe)
        saveToUserDefaults()
    }

    func updateRecipe(_ recipe: Recipe) {
        guard let index = recipes.firstIndex(where: { $0.id == recipe.id }) else { return }
        recipes[index] = recipe
        saveToUserDefaults()
    }

    func deleteRecipe(_ recipe: Recipe) {
        recipes.removeAll { $0.id == recipe.id }
        saveToUserDefaults()
    }

    func toggleFavorite(_ recipe: Recipe) {
        guard let index = recipes.firstIndex(where: { $0.id == recipe.id }) else { return }
        recipes[index].isFavorite.toggle()
        saveToUserDefaults()
    }

    func addMealPlan(_ plan: MealPlanItem) {
        if let index = mealPlans.firstIndex(where: {
            Calendar.current.isDate($0.date, inSameDayAs: plan.date) && $0.mealType == plan.mealType
        }) {
            mealPlans[index] = plan
        } else {
            mealPlans.append(plan)
        }
        saveToUserDefaults()
    }

    func upsertMealPlan(date: Date, mealType: MealType, recipe: Recipe?, customMeal: String?, notes: String?) {
        let existing = mealPlans.first(where: {
            Calendar.current.isDate($0.date, inSameDayAs: date) && $0.mealType == mealType
        })
        let plan = MealPlanItem(
            id: existing?.id ?? UUID(),
            date: date,
            mealType: mealType,
            recipeId: recipe?.id,
            recipeName: recipe?.name,
            customMeal: customMeal,
            notes: notes,
            isCompleted: existing?.isCompleted ?? false
        )
        addMealPlan(plan)
    }

    func deleteMealPlan(_ plan: MealPlanItem) {
        mealPlans.removeAll { $0.id == plan.id }
        saveToUserDefaults()
    }

    func toggleMealCompleted(_ plan: MealPlanItem) {
        guard let index = mealPlans.firstIndex(where: { $0.id == plan.id }) else { return }
        mealPlans[index].isCompleted.toggle()
        saveToUserDefaults()
    }

    func addToShoppingList(from recipe: Recipe) {
        for ingredient in recipe.ingredients {
            let item = ShoppingItem(
                id: UUID(),
                name: ingredient.name,
                quantity: "\(String(format: "%.1f", ingredient.quantity)) \(ingredient.unit)",
                category: categorizeIngredient(ingredient.name),
                isPurchased: false,
                recipeId: recipe.id
            )
            if !shoppingItems.contains(where: { $0.name.lowercased() == item.name.lowercased() }) {
                shoppingItems.append(item)
            }
        }
        saveToUserDefaults()
    }

    func addShoppingItem(name: String, quantity: String, category: ShoppingCategory) {
        let item = ShoppingItem(
            id: UUID(),
            name: name,
            quantity: quantity,
            category: category,
            isPurchased: false,
            recipeId: nil
        )
        shoppingItems.append(item)
        saveToUserDefaults()
    }

    func updateShoppingItem(id: UUID, name: String, quantity: String, category: ShoppingCategory) {
        guard let index = shoppingItems.firstIndex(where: { $0.id == id }) else { return }
        shoppingItems[index].name = name
        shoppingItems[index].quantity = quantity
        shoppingItems[index].category = category
        saveToUserDefaults()
    }

    func togglePurchased(_ item: ShoppingItem) {
        guard let index = shoppingItems.firstIndex(where: { $0.id == item.id }) else { return }
        shoppingItems[index].isPurchased.toggle()
        saveToUserDefaults()
    }

    func deleteShoppingItem(_ item: ShoppingItem) {
        shoppingItems.removeAll { $0.id == item.id }
        saveToUserDefaults()
    }

    func clearPurchased() {
        shoppingItems.removeAll { $0.isPurchased }
        saveToUserDefaults()
    }

    private func categorizeIngredient(_ name: String) -> ShoppingCategory {
        let value = name.lowercased()
        if ["tomato", "cucumber", "carrot", "onion", "garlic", "potato", "broccoli", "pepper"].contains(where: { value.contains($0) }) {
            return .vegetables
        }
        if ["apple", "banana", "orange", "lemon", "pear", "berry"].contains(where: { value.contains($0) }) {
            return .fruits
        }
        if ["milk", "yogurt", "cheese", "cream", "butter"].contains(where: { value.contains($0) }) {
            return .dairy
        }
        if ["chicken", "beef", "pork", "turkey"].contains(where: { value.contains($0) }) {
            return .meat
        }
        if ["salmon", "tuna", "cod", "fish"].contains(where: { value.contains($0) }) {
            return .fish
        }
        if ["rice", "buckwheat", "oats", "pasta", "flour"].contains(where: { value.contains($0) }) {
            return .grains
        }
        if ["salt", "sugar", "pepper", "paprika", "cinnamon"].contains(where: { value.contains($0) }) {
            return .spices
        }
        if ["water", "juice", "tea", "coffee"].contains(where: { value.contains($0) }) {
            return .beverages
        }
        return .other
    }

    private let recipesKey = "mealplan_recipes"
    private let mealPlansKey = "mealplan_mealplans"
    private let shoppingKey = "mealplan_shopping"
    private let groceryListsKey = "mealplan_grocerylists"

    func saveToUserDefaults() {
        if let data = try? JSONEncoder().encode(recipes) {
            UserDefaults.standard.set(data, forKey: recipesKey)
        }
        if let data = try? JSONEncoder().encode(mealPlans) {
            UserDefaults.standard.set(data, forKey: mealPlansKey)
        }
        if let data = try? JSONEncoder().encode(shoppingItems) {
            UserDefaults.standard.set(data, forKey: shoppingKey)
        }
        if let data = try? JSONEncoder().encode(groceryLists) {
            UserDefaults.standard.set(data, forKey: groceryListsKey)
        }
    }

    func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: recipesKey),
           let decoded = try? JSONDecoder().decode([Recipe].self, from: data) {
            recipes = decoded
        }
        if let data = UserDefaults.standard.data(forKey: mealPlansKey),
           let decoded = try? JSONDecoder().decode([MealPlanItem].self, from: data) {
            mealPlans = decoded
        }
        if let data = UserDefaults.standard.data(forKey: shoppingKey),
           let decoded = try? JSONDecoder().decode([ShoppingItem].self, from: data) {
            shoppingItems = decoded
        }
        if let data = UserDefaults.standard.data(forKey: groceryListsKey),
           let decoded = try? JSONDecoder().decode([GroceryList].self, from: data) {
            groceryLists = decoded
        }

        if recipes.isEmpty {
            loadDemoData()
            saveToUserDefaults()
        }
    }

    private func loadDemoData() {
        let ingredients1 = [
            Ingredient(id: UUID(), name: "Chicken breast", quantity: 200, unit: "g", notes: nil),
            Ingredient(id: UUID(), name: "Rice", quantity: 100, unit: "g", notes: nil),
            Ingredient(id: UUID(), name: "Broccoli", quantity: 150, unit: "g", notes: nil),
            Ingredient(id: UUID(), name: "Soy sauce", quantity: 2, unit: "tbsp", notes: nil)
        ]

        let recipe1 = Recipe(
            id: UUID(),
            name: "Chicken Rice Bowl",
            cuisine: .asian,
            difficulty: .easy,
            prepTime: 10,
            cookTime: 20,
            servings: 2,
            ingredients: ingredients1,
            instructions: ["Sear chicken", "Cook rice", "Steam broccoli", "Combine with sauce"],
            calories: 450,
            protein: 35,
            carbs: 45,
            fat: 12,
            imageName: nil,
            notes: nil,
            isFavorite: true,
            createdAt: Date()
        )

        let recipe2 = Recipe(
            id: UUID(),
            name: "Pasta Carbonara",
            cuisine: .italian,
            difficulty: .medium,
            prepTime: 5,
            cookTime: 15,
            servings: 2,
            ingredients: [
                Ingredient(id: UUID(), name: "Pasta", quantity: 200, unit: "g", notes: nil),
                Ingredient(id: UUID(), name: "Bacon", quantity: 100, unit: "g", notes: nil),
                Ingredient(id: UUID(), name: "Eggs", quantity: 2, unit: "pcs", notes: nil),
                Ingredient(id: UUID(), name: "Parmesan", quantity: 50, unit: "g", notes: nil)
            ],
            instructions: ["Boil pasta", "Cook bacon", "Mix eggs and cheese", "Combine all ingredients"],
            calories: 650,
            protein: 28,
            carbs: 60,
            fat: 30,
            imageName: nil,
            notes: nil,
            isFavorite: false,
            createdAt: Date()
        )

        recipes = [recipe1, recipe2]

        let today = Date()
        mealPlans = [
            MealPlanItem(
                id: UUID(),
                date: today,
                mealType: .lunch,
                recipeId: recipe1.id,
                recipeName: recipe1.name,
                customMeal: nil,
                notes: nil,
                isCompleted: false
            )
        ]
    }
}
