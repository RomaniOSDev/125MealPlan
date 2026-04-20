//
//  ContentView.swift
//  125MealPlan
//
//  Created by Роман Главацкий on 08.04.2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MealPlanViewModel()
    @State private var selectedTab = 0
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        Group {
            if hasSeenOnboarding {
                TabView(selection: $selectedTab) {
                    HomeView(viewModel: viewModel, selectedTab: $selectedTab)
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(0)

                    WeeklyMenuView(viewModel: viewModel)
                        .tabItem {
                            Label("Plan", systemImage: "calendar")
                        }
                        .tag(1)

                    RecipesView(viewModel: viewModel)
                        .tabItem {
                            Label("Recipes", systemImage: "book.fill")
                        }
                        .tag(2)

                    ShoppingListView(viewModel: viewModel)
                        .tabItem {
                            Label("Shopping", systemImage: "cart.fill")
                        }
                        .tag(3)

                    StatsView(viewModel: viewModel)
                        .tabItem {
                            Label("Stats", systemImage: "chart.bar.fill")
                        }
                        .tag(4)

                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                        .tag(5)
                }
            } else {
                OnboardingView()
            }
        }
        .onAppear {
            viewModel.loadFromUserDefaults()
        }
        .accentColor(.mealActive)
    }
}

#Preview {
    ContentView()
}
