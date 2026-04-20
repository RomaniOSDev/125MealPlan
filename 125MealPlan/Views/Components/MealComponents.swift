import SwiftUI

struct DayColumn: View {
    let date: Date
    let mealPlan: [MealPlanItem]
    let onTapSlot: (MealType, MealPlanItem?) -> Void
    let onQuickAdd: () -> Void

    private var dayName: String {
        date.formatted(.dateTime.weekday(.abbreviated))
    }

    private var dayNumber: String {
        date.formatted(.dateTime.day().month(.abbreviated))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack {
                Text(dayName)
                    .font(.headline)
                    .foregroundColor(.mealDeep)
                Text(dayNumber)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 4)

            ForEach(MealType.allCases.sorted(by: { $0.order < $1.order }), id: \.self) { mealType in
                let plan = mealPlan.first(where: { $0.mealType == mealType })
                MealSlot(mealType: mealType, plan: plan) {
                    onTapSlot(mealType, plan)
                }
            }

            Button(action: onQuickAdd) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.mealActive)
                    .frame(maxWidth: .infinity)
            }
            .padding(.top, 4)
        }
        .frame(width: 120)
        .padding(.vertical, 8)
    }
}

struct MealSlot: View {
    let mealType: MealType
    let plan: MealPlanItem?
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: mealType.icon)
                    .font(.caption)
                    .foregroundColor(.mealActive)
                Text(mealType.rawValue)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            if let recipeName = plan?.recipeName {
                Text(recipeName)
                    .font(.caption)
                    .foregroundColor(.mealDeep)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            } else if let customMeal = plan?.customMeal {
                Text(customMeal)
                    .font(.caption)
                    .foregroundColor(.mealDeep)
                    .lineLimit(2)
            } else {
                Text("—")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            if plan?.isCompleted == true {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption2)
                    .foregroundColor(.mealActive)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(plan != nil ? Color.mealActive.opacity(0.08) : Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(plan != nil ? Color.mealActive.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.mealDeep.opacity(0.08), radius: 6, x: 0, y: 4)
        .onTapGesture(perform: onTap)
    }
}

struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(recipe.cuisine.icon)
                    .font(.title2)
                VStack(alignment: .leading) {
                    Text(recipe.name)
                        .font(.headline)
                        .foregroundColor(.mealDeep)
                    Text(recipe.cuisine.rawValue)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                if recipe.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.mealActive)
                        .font(.caption)
                }
            }

            HStack {
                Label("\(recipe.totalTime) min", systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.mealActive)
                Spacer()
                Label("\(recipe.servings) servings", systemImage: "person")
                    .font(.caption)
                    .foregroundColor(.mealActive)
                Spacer()
                Image(systemName: recipe.difficulty.icon)
                    .font(.caption)
                    .foregroundColor(.mealDeep)
            }

            if let calories = recipe.calories {
                Text("~\(calories) kcal per serving")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .mealCard(cornerRadius: 14)
    }
}

struct ShoppingItemRow: View {
    let item: ShoppingItem

    var body: some View {
        HStack {
            Image(systemName: item.isPurchased ? "checkmark.circle.fill" : "circle")
                .foregroundColor(item.isPurchased ? .mealActive : .gray)
                .font(.title2)
            Text(item.name)
                .foregroundColor(item.isPurchased ? .gray : .mealDeep)
                .strikethrough(item.isPurchased)
            Spacer()
            Text(item.quantity)
                .foregroundColor(.mealActive)
                .font(.caption)
                .bold()
        }
        .padding()
        .mealCard(cornerRadius: 10)
        .padding(.horizontal)
    }
}
