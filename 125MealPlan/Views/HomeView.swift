import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: MealPlanViewModel
    @Binding var selectedTab: Int

    private var todayPlans: [MealPlanItem] {
        viewModel.mealPlanForDate(Date()).sorted { $0.mealType.order < $1.mealType.order }
    }

    private var completedToday: Int {
        todayPlans.filter(\.isCompleted).count
    }

    private var openShoppingCount: Int {
        viewModel.shoppingItems.filter { !$0.isPurchased }.count
    }

    private var favoriteRecipesCount: Int {
        viewModel.recipes.filter(\.isFavorite).count
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    heroCard
                    quickActions
                    todaySection
                    insightsSection
                }
                .padding()
            }
            .background(Color.mealBackground.ignoresSafeArea())
            .navigationTitle("Home")
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Today")
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))

            Text(Date().formatted(date: .abbreviated, time: .omitted))
                .font(.title2)
                .bold()
                .foregroundColor(.white)

            HStack {
                statBadge(title: "Planned", value: "\(todayPlans.count)")
                statBadge(title: "Done", value: "\(completedToday)")
                statBadge(title: "Left", value: "\(max(todayPlans.count - completedToday, 0))")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.mealActive, Color.mealDeep],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: Color.mealDeep.opacity(0.25), radius: 14, x: 0, y: 8)
    }

    private func statBadge(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.16))
        .cornerRadius(10)
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(.mealDeep)

            HStack(spacing: 10) {
                actionButton("Open Plan", icon: "calendar", tint: .mealActive) { selectedTab = 1 }
                actionButton("Add Recipe", icon: "plus.circle.fill", tint: .mealDeep) { selectedTab = 2 }
            }
            HStack(spacing: 10) {
                actionButton("Shopping", icon: "cart.fill", tint: .mealActive) { selectedTab = 3 }
                actionButton("Statistics", icon: "chart.bar.fill", tint: .mealDeep) { selectedTab = 4 }
            }
        }
    }

    private func actionButton(_ title: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .lineLimit(1)
            }
            .font(.subheadline.weight(.semibold))
            .foregroundColor(tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [Color.white, Color.mealBackground],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(tint.opacity(0.22), lineWidth: 1)
            )
            .cornerRadius(12)
            .shadow(color: tint.opacity(0.18), radius: 8, x: 0, y: 5)
        }
    }

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Today's Meals")
                .font(.headline)
                .foregroundColor(.mealDeep)

            if todayPlans.isEmpty {
                Text("No meals planned yet. Open Plan and add your first meal.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .mealCard(cornerRadius: 12)
            } else {
                ForEach(todayPlans) { plan in
                    HStack(spacing: 10) {
                        Image(systemName: plan.mealType.icon)
                            .foregroundColor(.mealActive)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(plan.mealType.rawValue)
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(plan.recipeName ?? plan.customMeal ?? "Meal")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.mealDeep)
                        }
                        Spacer()
                        Button {
                            viewModel.toggleMealCompleted(plan)
                        } label: {
                            Image(systemName: plan.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(plan.isCompleted ? .mealActive : .gray)
                                .font(.title3)
                        }
                    }
                    .padding()
                    .mealCard(cornerRadius: 12)
                }
            }
        }
    }

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Insights")
                .font(.headline)
                .foregroundColor(.mealDeep)

            HStack(spacing: 10) {
                insightCard(title: "Recipes", value: "\(viewModel.recipes.count)", icon: "book.fill")
                insightCard(title: "Favorites", value: "\(favoriteRecipesCount)", icon: "star.fill")
                insightCard(title: "Shopping", value: "\(openShoppingCount)", icon: "cart.fill")
            }
        }
    }

    private func insightCard(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(.mealActive)
            Text(value)
                .font(.headline)
                .foregroundColor(.mealDeep)
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .mealCard(cornerRadius: 12)
    }
}
