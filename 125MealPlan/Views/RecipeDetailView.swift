import SwiftUI

struct RecipeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MealPlanViewModel
    let recipe: Recipe
    @State private var showAddToPlan = false
    @State private var showEditRecipe = false

    private var currentRecipe: Recipe {
        viewModel.recipes.first(where: { $0.id == recipe.id }) ?? recipe
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(currentRecipe.cuisine.icon)
                            .font(.system(size: 40))
                        Text(currentRecipe.name)
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.mealDeep)
                        HStack {
                            Label("\(currentRecipe.totalTime) min", systemImage: "clock")
                            Spacer()
                            Label("\(currentRecipe.servings) servings", systemImage: "person")
                            Spacer()
                            Label(currentRecipe.difficulty.rawValue, systemImage: currentRecipe.difficulty.icon)
                        }
                        .font(.caption)
                        .foregroundColor(.mealActive)
                    }
                    .padding()

                    VStack(alignment: .leading) {
                        Text("Ingredients")
                            .font(.headline)
                            .foregroundColor(.mealDeep)
                        ForEach(currentRecipe.ingredients) { ingredient in
                            HStack {
                                Text("• \(ingredient.name)")
                                    .foregroundColor(.mealDeep)
                                Spacer()
                                Text("\(ingredient.quantity, specifier: "%.1f") \(ingredient.unit)")
                                    .foregroundColor(.mealActive)
                                    .font(.caption)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)

                    VStack(alignment: .leading) {
                        Text("Instructions")
                            .font(.headline)
                            .foregroundColor(.mealDeep)
                        ForEach(Array(currentRecipe.instructions.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top) {
                                Text("\(index + 1).")
                                    .foregroundColor(.mealActive)
                                    .frame(width: 30)
                                Text(step)
                                    .foregroundColor(.mealDeep)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)

                    if let calories = currentRecipe.calories {
                        VStack(alignment: .leading) {
                            Text("Nutrition (per serving)")
                                .font(.headline)
                                .foregroundColor(.mealDeep)
                            HStack {
                                StatPill(title: "Calories", value: "\(calories)", color: .mealActive)
                                if let protein = currentRecipe.protein {
                                    StatPill(title: "Protein", value: "\(protein)g", color: .mealActive)
                                }
                                if let carbs = currentRecipe.carbs {
                                    StatPill(title: "Carbs", value: "\(carbs)g", color: .mealActive)
                                }
                                if let fat = currentRecipe.fat {
                                    StatPill(title: "Fat", value: "\(fat)g", color: .mealActive)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    HStack {
                        Button("Add to Plan") {
                            showAddToPlan = true
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mealActive)
                        .foregroundColor(.white)
                        .cornerRadius(10)

                        Button("To Shopping") {
                            viewModel.addToShoppingList(from: recipe)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.mealActive, lineWidth: 1)
                        )
                        .foregroundColor(.mealActive)
                    }
                    .padding()
                }
            }
            .background(Color.mealBackground.ignoresSafeArea())
            .navigationTitle("Recipe")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showEditRecipe = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .sheet(isPresented: $showAddToPlan) {
            AddToPlanView(viewModel: viewModel, recipe: currentRecipe)
        }
        .sheet(isPresented: $showEditRecipe) {
            EditRecipeView(viewModel: viewModel, recipe: currentRecipe)
        }
    }
}
