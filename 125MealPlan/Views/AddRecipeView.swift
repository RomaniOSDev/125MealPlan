import SwiftUI

struct AddRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MealPlanViewModel

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
                    TextField("Calories", text: $calories)
                        .keyboardType(.numberPad)
                    TextField("Protein (g)", text: $protein)
                        .keyboardType(.numberPad)
                    TextField("Carbs (g)", text: $carbs)
                        .keyboardType(.numberPad)
                    TextField("Fat (g)", text: $fat)
                        .keyboardType(.numberPad)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }
            }
            .navigationTitle("Add Recipe")
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

        let recipe = Recipe(
            id: UUID(),
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
            imageName: nil,
            notes: notes.isEmpty ? nil : notes,
            isFavorite: false,
            createdAt: Date()
        )
        viewModel.addRecipe(recipe)
        dismiss()
    }
}
