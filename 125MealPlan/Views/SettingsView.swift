import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Support")
                        .font(.headline)
                        .foregroundColor(.mealDeep)

                    settingsButton(
                        title: "Rate Us",
                        icon: "star.fill",
                        tint: .mealActive,
                        action: rateApp
                    )

                    settingsButton(
                        title: "Privacy Policy",
                        icon: "hand.raised.fill",
                        tint: .mealDeep,
                        action: openPrivacyPolicy
                    )

                    settingsButton(
                        title: "Terms of Use",
                        icon: "doc.text.fill",
                        tint: .mealDeep,
                        action: openTermsOfUse
                    )
                }
                .padding()
                .mealCard(cornerRadius: 16)

                Spacer()
            }
            .padding()
            .background(Color.mealBackground.ignoresSafeArea())
            .navigationTitle("Settings")
        }
    }

    private func settingsButton(title: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(tint)
                Text(title)
                    .foregroundColor(.mealDeep)
                    .font(.body.weight(.semibold))
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption.weight(.bold))
            }
            .padding()
            .mealCard(cornerRadius: 12)
        }
    }

    private func openPrivacyPolicy() {
        if let url = URL(string: AppExternalLink.privacyPolicy.urlString) {
            UIApplication.shared.open(url)
        }
    }

    private func openTermsOfUse() {
        if let url = URL(string: AppExternalLink.termsOfUse.urlString) {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
