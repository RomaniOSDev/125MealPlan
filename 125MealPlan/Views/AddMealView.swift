import SwiftUI

struct AddMealView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MealPlanViewModel

    let date: Date
    let existingPlan: MealPlanItem?
    let preselectedMealType: MealType?

    @State private var mealType: MealType = .breakfast
    @State private var selectedRecipeId: UUID?
    @State private var showCustomMeal = false
    @State private var customMealName = ""
    @State private var notes = ""

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Meal Type", selection: $mealType) {
                        ForEach(MealType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon).tag(type)
                        }
                    }
                    .accentColor(.mealActive)
                }

                Section(header: Text("Choose Recipe").foregroundColor(.gray)) {
                    ForEach(viewModel.recipes) { recipe in
                        Button(action: { selectedRecipeId = recipe.id }) {
                            HStack {
                                Text(recipe.name)
                                    .foregroundColor(.mealDeep)
                                Spacer()
                                if selectedRecipeId == recipe.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.mealActive)
                                }
                            }
                        }
                    }

                    Button("Or enter custom meal") {
                        showCustomMeal = true
                        selectedRecipeId = nil
                    }
                    .foregroundColor(.mealActive)
                }

                if showCustomMeal {
                    Section(header: Text("Custom Meal").foregroundColor(.gray)) {
                        TextField("Meal name", text: $customMealName)
                            .foregroundColor(.mealDeep)
                            .accentColor(.mealActive)
                    }
                }

                Section(header: Text("Notes").foregroundColor(.gray)) {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                        .foregroundColor(.mealDeep)
                        .accentColor(.mealActive)
                }

                if let plan = existingPlan {
                    Section(header: Text("Actions").foregroundColor(.gray)) {
                        Button(plan.isCompleted ? "Mark as Not Completed" : "Mark as Completed") {
                            viewModel.toggleMealCompleted(plan)
                            dismiss()
                        }
                        .foregroundColor(.mealActive)

                        Button("Delete Meal", role: .destructive) {
                            viewModel.deleteMealPlan(plan)
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Select Meal")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.mealActive)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", action: save)
                        .foregroundColor(.mealActive)
                        .disabled(selectedRecipeId == nil && customMealName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .background(Color.mealBackground.ignoresSafeArea())
        }
        .onAppear(perform: preload)
    }

    private func preload() {
        mealType = preselectedMealType ?? existingPlan?.mealType ?? .breakfast
        selectedRecipeId = existingPlan?.recipeId
        customMealName = existingPlan?.customMeal ?? ""
        notes = existingPlan?.notes ?? ""
        showCustomMeal = existingPlan?.customMeal != nil
    }

    private func save() {
        let recipe = viewModel.recipes.first(where: { $0.id == selectedRecipeId })
        viewModel.upsertMealPlan(
            date: date,
            mealType: mealType,
            recipe: recipe,
            customMeal: showCustomMeal ? customMealName : nil,
            notes: notes.isEmpty ? nil : notes
        )
        dismiss()
    }
}
