import SwiftUI

struct RecipesView: View {
    @ObservedObject var viewModel: MealPlanViewModel

    @State private var showAddRecipeSheet = false
    @State private var selectedRecipe: Recipe?
    @State private var recipeForPlan: Recipe?
    @State private var recipeForEdit: Recipe?

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.mealActive)
                    TextField("Search recipes", text: $viewModel.searchText)
                        .foregroundColor(.mealDeep)
                        .accentColor(.mealActive)
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.white, Color.mealBackground],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: Color.mealDeep.opacity(0.08), radius: 8, x: 0, y: 5)
                .padding(.horizontal)

                List {
                    ForEach(viewModel.filteredRecipes) { recipe in
                        RecipeCard(recipe: recipe)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .onTapGesture { selectedRecipe = recipe }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    viewModel.deleteRecipe(recipe)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                Button {
                                    viewModel.toggleFavorite(recipe)
                                } label: {
                                    Label("Favorite", systemImage: "star")
                                }
                                .tint(.mealActive)
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    recipeForPlan = recipe
                                } label: {
                                    Label("Plan", systemImage: "calendar")
                                }
                                .tint(.mealDeep)

                                Button {
                                    recipeForEdit = recipe
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.mealActive)
                            }
                    }

                    Button("Add Recipe") {
                        showAddRecipeSheet = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .mealPrimaryButton(cornerRadius: 12)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .background(Color.mealBackground.ignoresSafeArea())
            .navigationTitle("My Recipes")
        }
        .sheet(isPresented: $showAddRecipeSheet) {
            AddRecipeView(viewModel: viewModel)
        }
        .sheet(item: $selectedRecipe) { recipe in
            RecipeDetailView(viewModel: viewModel, recipe: recipe)
        }
        .sheet(item: $recipeForPlan) { recipe in
            AddToPlanView(viewModel: viewModel, recipe: recipe)
        }
        .sheet(item: $recipeForEdit) { recipe in
            EditRecipeView(viewModel: viewModel, recipe: recipe)
        }
    }
}
