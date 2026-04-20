import Foundation

enum MealType: String, CaseIterable, Codable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"

    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.fill"
        case .snack: return "applelogo"
        }
    }

    var order: Int {
        switch self {
        case .breakfast: return 1
        case .lunch: return 2
        case .snack: return 3
        case .dinner: return 4
        }
    }
}

enum MealDifficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var icon: String {
        switch self {
        case .easy: return "1.circle"
        case .medium: return "2.circle"
        case .hard: return "3.circle"
        }
    }
}

enum CuisineType: String, CaseIterable, Codable {
    case italian = "Italian"
    case asian = "Asian"
    case russian = "Russian"
    case european = "European"
    case mexican = "Mexican"
    case vegetarian = "Vegetarian"
    case healthy = "Healthy"
    case other = "Other"

    var icon: String {
        switch self {
        case .italian: return "🍕"
        case .asian: return "🥢"
        case .russian: return "🥟"
        case .european: return "🍝"
        case .mexican: return "🌮"
        case .vegetarian: return "🥗"
        case .healthy: return "🥑"
        case .other: return "🍽️"
        }
    }
}

struct Recipe: Identifiable, Codable {
    let id: UUID
    var name: String
    var cuisine: CuisineType
    var difficulty: MealDifficulty
    var prepTime: Int
    var cookTime: Int
    var servings: Int
    var ingredients: [Ingredient]
    var instructions: [String]
    var calories: Int?
    var protein: Int?
    var carbs: Int?
    var fat: Int?
    var imageName: String?
    var notes: String?
    var isFavorite: Bool
    let createdAt: Date

    var totalTime: Int {
        prepTime + cookTime
    }
}

struct Ingredient: Identifiable, Codable {
    let id: UUID
    var name: String
    var quantity: Double
    var unit: String
    var notes: String?
}

struct MealPlanItem: Identifiable, Codable {
    let id: UUID
    let date: Date
    var mealType: MealType
    var recipeId: UUID?
    var recipeName: String?
    var customMeal: String?
    var notes: String?
    var isCompleted: Bool
}

struct ShoppingItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var quantity: String
    var category: ShoppingCategory
    var isPurchased: Bool
    var recipeId: UUID?
}

enum ShoppingCategory: String, CaseIterable, Codable {
    case vegetables = "Vegetables"
    case fruits = "Fruits"
    case dairy = "Dairy"
    case meat = "Meat"
    case fish = "Fish"
    case grains = "Grains"
    case spices = "Spices"
    case beverages = "Beverages"
    case other = "Other"

    var icon: String {
        switch self {
        case .vegetables: return "leaf.fill"
        case .fruits: return "applelogo"
        case .dairy: return "cup.and.saucer.fill"
        case .meat: return "fork.knife"
        case .fish: return "fish.fill"
        case .grains: return "crop"
        case .spices: return "flame.fill"
        case .beverages: return "mug.fill"
        case .other: return "tag"
        }
    }
}

struct WeeklyPlan: Identifiable, Codable {
    let id: UUID
    let startDate: Date
    var items: [MealPlanItem]
    let createdAt: Date
}

struct GroceryList: Identifiable, Codable {
    let id: UUID
    let name: String
    var items: [ShoppingItem]
    let createdAt: Date
}
