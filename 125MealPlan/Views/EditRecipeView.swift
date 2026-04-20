import SwiftUI

struct EditRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MealPlanViewModel
    let recipe: Recipe

    @State private var name = ""
    @State private var cuisine: CuisineType = .other
    @State private var difficulty: MealDifficulty = .easy
    @State private var prepTime = 10
    @State private var cookTime = 20
    @State private var servings = 2
    @State private var ingredientsText = ""
    @State private var instructionsText = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    @State private var notes = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Basics") {
                    TextField("Recipe name", text: $name)
                    Picker("Cuisine", selection: $cuisine) {
                        ForEach(CuisineType.allCases, id: \.self) { type in
                            Text("\(type.icon) \(type.rawValue)").tag(type)
                        }
                    }
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(MealDifficulty.allCases, id: \.self) { value in
                            Label(value.rawValue, systemImage: value.icon).tag(value)
                        }
                    }
                }

                Section("Timing") {
                    Stepper("Prep: \(prepTime) min", value: $prepTime, in: 0...300)
                    Stepper("Cook: \(cookTime) min", value: $cookTime, in: 0...300)
                    Stepper("Servings: \(servings)", value: $servings, in: 1...20)
                }

                Section("Ingredients (one per line: name, qty, unit)") {
                    TextEditor(text: $ingredientsText)
                        .frame(height: 120)
                }

                Section("Instructions (one step per line)") {
                    TextEditor(text: $instructionsText)
                        .frame(height: 120)
                }

                Section("Nutrition (optional)") {
                    TextField("Calories", text: $calories).keyboardType(.numberPad)
                    TextField("Protein (g)", text: $protein).keyboardType(.numberPad)
                    TextField("Carbs (g)", text: $carbs).keyboardType(.numberPad)
                    TextField("Fat (g)", text: $fat).keyboardType(.numberPad)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }
            }
            .navigationTitle("Edit Recipe")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", action: save)
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear(perform: preload)
    }

    private func preload() {
        name = recipe.name
        cuisine = recipe.cuisine
        difficulty = recipe.difficulty
        prepTime = recipe.prepTime
        cookTime = recipe.cookTime
        servings = recipe.servings
        ingredientsText = recipe.ingredients
            .map { "\($0.name), \($0.quantity), \($0.unit)" }
            .joined(separator: "\n")
        instructionsText = recipe.instructions.joined(separator: "\n")
        calories = recipe.calories.map(String.init) ?? ""
        protein = recipe.protein.map(String.init) ?? ""
        carbs = recipe.carbs.map(String.init) ?? ""
        fat = recipe.fat.map(String.init) ?? ""
        notes = recipe.notes ?? ""
    }

    private func save() {
        let ingredients = ingredientsText
            .split(separator: "\n")
            .map { String($0) }
            .compactMap { line -> Ingredient? in
                let parts = line.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                guard let first = parts.first, !first.isEmpty else { return nil }
                let qty = parts.count > 1 ? Double(parts[1]) ?? 1 : 1
                let unit = parts.count > 2 ? parts[2] : "pcs"
                return Ingredient(id: UUID(), name: first, quantity: qty, unit: unit, notes: nil)
            }

        let instructions = instructionsText
            .split(separator: "\n")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let updated = Recipe(
            id: recipe.id,
            name: name,
            cuisine: cuisine,
            difficulty: difficulty,
            prepTime: prepTime,
            cookTime: cookTime,
            servings: servings,
            ingredients: ingredients,
            instructions: instructions,
            calories: Int(calories),
            protein: Int(protein),
            carbs: Int(carbs),
            fat: Int(fat),
            imageName: recipe.imageName,
            notes: notes.isEmpty ? nil : notes,
            isFavorite: recipe.isFavorite,
            createdAt: recipe.createdAt
        )

        viewModel.updateRecipe(updated)
        dismiss()
    }
}
