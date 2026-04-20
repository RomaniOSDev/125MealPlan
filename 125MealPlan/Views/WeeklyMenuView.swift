import SwiftUI

struct WeeklyMenuView: View {
    @ObservedObject var viewModel: MealPlanViewModel

    @State private var weekStart = Calendar.current.startOfDay(for: Date())
    @State private var selectedDate = Date()
    @State private var selectedMealType: MealType?
    @State private var selectedPlan: MealPlanItem?
    @State private var showAddMealSheet = false
    @State private var showAddRecipeSheet = false

    private var weekDays: [Date] {
        let start = startOfWeek(weekStart)
        return (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: start) }
    }

    private var weekRangeString: String {
        guard let first = weekDays.first, let last = weekDays.last else { return "" }
        return "\(formattedShortDate(first)) - \(formattedShortDate(last))"
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                HStack {
                    Button(action: previousWeek) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.mealActive)
                    }
                    Spacer()
                    Text(weekRangeString)
                        .font(.headline)
                        .foregroundColor(.mealDeep)
                    Spacer()
                    Button(action: nextWeek) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.mealActive)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [Color.white, Color.mealBackground],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
                .padding(.horizontal)
                .shadow(color: Color.mealDeep.opacity(0.08), radius: 8, x: 0, y: 5)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 16) {
                        ForEach(weekDays, id: \.self) { date in
                            DayColumn(
                                date: date,
                                mealPlan: viewModel.mealPlanForDate(date),
                                onTapSlot: { mealType, plan in
                                    selectedDate = date
                                    selectedMealType = mealType
                                    selectedPlan = plan
                                    showAddMealSheet = true
                                },
                                onQuickAdd: {
                                    selectedDate = date
                                    selectedMealType = nil
                                    selectedPlan = nil
                                    showAddMealSheet = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }

                Button(action: { showAddRecipeSheet = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Recipe")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .mealPrimaryButton(cornerRadius: 12)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .background(Color.mealBackground.ignoresSafeArea())
            .navigationTitle("Weekly Menu")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Today") {
                            weekStart = Date()
                        }
                    } label: {
                        Image(systemName: "calendar")
                            .foregroundColor(.mealActive)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddMealSheet) {
            AddMealView(
                viewModel: viewModel,
                date: selectedDate,
                existingPlan: selectedPlan,
                preselectedMealType: selectedMealType
            )
        }
        .sheet(isPresented: $showAddRecipeSheet) {
            AddRecipeView(viewModel: viewModel)
        }
    }

    private func startOfWeek(_ date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }

    private func previousWeek() {
        weekStart = Calendar.current.date(byAdding: .day, value: -7, to: weekStart) ?? weekStart
    }

    private func nextWeek() {
        weekStart = Calendar.current.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart
    }
}
