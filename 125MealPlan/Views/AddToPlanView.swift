import SwiftUI

struct AddToPlanView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MealPlanViewModel
    let recipe: Recipe

    @State private var selectedDate = Date()
    @State private var selectedMealType: MealType = .lunch
    @State private var notes = ""

    var body: some View {
        NavigationView {
            Form {
                Section("When") {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    Picker("Meal Type", selection: $selectedMealType) {
                        ForEach(MealType.allCases.sorted(by: { $0.order < $1.order }), id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon).tag(type)
                        }
                    }
                }
                Section("Recipe") {
                    Text(recipe.name)
                        .foregroundColor(.mealDeep)
                }
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 90)
                }
            }
            .navigationTitle("Add to Plan")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        viewModel.upsertMealPlan(
                            date: selectedDate,
                            mealType: selectedMealType,
                            recipe: recipe,
                            customMeal: nil,
                            notes: notes.isEmpty ? nil : notes
                        )
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            selectedMealType = defaultMealType(for: Date())
        }
    }

    private func defaultMealType(for date: Date) -> MealType {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<11:
            return .breakfast
        case 11..<16:
            return .lunch
        case 16..<20:
            return .snack
        default:
            return .dinner
        }
    }
}
