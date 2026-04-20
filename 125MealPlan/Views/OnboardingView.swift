import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "calendar.badge.clock",
            title: "Plan Your Week",
            subtitle: "Build your weekly meals in a clean and simple flow."
        ),
        OnboardingPage(
            icon: "book.closed.fill",
            title: "Keep Recipes Handy",
            subtitle: "Save, edit, and reuse recipes for faster planning."
        ),
        OnboardingPage(
            icon: "cart.fill.badge.plus",
            title: "Shop Smarter",
            subtitle: "Turn ingredients into a focused shopping list."
        )
    ]

    var body: some View {
        ZStack {
            Color.mealBackground.ignoresSafeArea()
            backgroundGlow

            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button("Skip") { finishOnboarding() }
                        .foregroundColor(.mealActive)
                        .padding(.horizontal)
                }

                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                            .padding(.horizontal, 24)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                Button(action: primaryAction) {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .mealPrimaryButton(cornerRadius: 14)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }

    private var backgroundGlow: some View {
        ZStack {
            Circle()
                .fill(Color.mealActive.opacity(0.18))
                .frame(width: 260, height: 260)
                .blur(radius: 30)
                .offset(x: -110, y: -260)
            Circle()
                .fill(Color.mealDeep.opacity(0.14))
                .frame(width: 220, height: 220)
                .blur(radius: 30)
                .offset(x: 120, y: 260)
        }
        .allowsHitTesting(false)
    }

    private func primaryAction() {
        if currentPage < pages.count - 1 {
            withAnimation(.easeInOut) {
                currentPage += 1
            }
        } else {
            finishOnboarding()
        }
    }

    private func finishOnboarding() {
        hasSeenOnboarding = true
    }
}

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 22) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.mealActive, Color.mealDeep],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 150, height: 150)
                    .shadow(color: Color.mealDeep.opacity(0.25), radius: 16, x: 0, y: 10)

                Image(systemName: page.icon)
                    .font(.system(size: 58, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(spacing: 10) {
                Text(page.title)
                    .font(.title2.bold())
                    .foregroundColor(.mealDeep)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
            }
            .padding(18)
            .mealCard(cornerRadius: 18)

            Spacer()
            Spacer()
        }
    }
}
