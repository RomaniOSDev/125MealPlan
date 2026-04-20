import SwiftUI

struct MealCardStyle: ViewModifier {
    var cornerRadius: CGFloat = 14

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white, Color.white.opacity(0.96)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.mealActive.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: Color.mealDeep.opacity(0.07), radius: 12, x: 0, y: 8)
            .shadow(color: Color.white.opacity(0.75), radius: 3, x: -2, y: -2)
    }
}

struct MealPrimaryButtonStyle: ViewModifier {
    var cornerRadius: CGFloat = 12

    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [Color.mealActive, Color.mealDeep],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.mealActive.opacity(0.35), radius: 10, x: 0, y: 6)
    }
}

extension View {
    func mealCard(cornerRadius: CGFloat = 14) -> some View {
        modifier(MealCardStyle(cornerRadius: cornerRadius))
    }

    func mealPrimaryButton(cornerRadius: CGFloat = 12) -> some View {
        modifier(MealPrimaryButtonStyle(cornerRadius: cornerRadius))
    }
}
