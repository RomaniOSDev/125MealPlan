import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: MealPlanViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatCard(
                        title: "Recipes",
                        value: "\(viewModel.recipes.count)",
                        icon: "book.fill",
                        color: .mealDeep,
                        backgroundColor: .white
                    )
                    StatCard(
                        title: "Plans",
                        value: "\(viewModel.mealPlanCount)",
                        icon: "calendar",
                        color: .mealDeep,
                        backgroundColor: .white
                    )
                    StatCard(
                        title: "Top Cuisine",
                        value: viewModel.favoriteCuisine?.rawValue ?? "—",
                        icon: "star.fill",
                        color: .mealActive,
                        backgroundColor: .white
                    )
                    StatCard(
                        title: "Avg Time",
                        value: "\(viewModel.averageCookTime) min",
                        icon: "clock.fill",
                        color: .mealDeep,
                        backgroundColor: .white
                    )
                }
                .padding(.horizontal)

                VStack(alignment: .leading) {
                    Text("Popular Meals")
                        .font(.headline)
                        .foregroundColor(.mealDeep)
                    ForEach(viewModel.mealTypeStats) { stat in
                        HStack {
                            Image(systemName: stat.icon)
                                .foregroundColor(.mealActive)
                                .frame(width: 30)
                            Text(stat.name)
                                .foregroundColor(.mealDeep)
                            Spacer()
                            Text("\(stat.count)")
                                .foregroundColor(.mealActive)
                                .bold()
                            Text("(\(Int(stat.percentage))%)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
                .mealCard(cornerRadius: 14)
                .padding(.horizontal)
                .padding(.top, 8)

                VStack(alignment: .leading) {
                    Text("Top Recipes")
                        .font(.headline)
                        .foregroundColor(.mealDeep)
                    ForEach(viewModel.topRecipes) { recipe in
                        HStack {
                            Text(recipe.name)
                                .foregroundColor(.mealDeep)
                            Spacer()
                            Text("\(recipe.count) times")
                                .foregroundColor(.mealActive)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
                .mealCard(cornerRadius: 14)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .background(Color.mealBackground.ignoresSafeArea())
            .navigationTitle("Stats")
        }
    }
}
