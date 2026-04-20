import SwiftUI

struct ShoppingListView: View {
    @ObservedObject var viewModel: MealPlanViewModel

    @State private var showAddItem = false
    @State private var editingItem: ShoppingItem?
    @State private var itemName = ""
    @State private var itemQty = "1"
    @State private var itemCategory: ShoppingCategory = .other

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                List {
                    ForEach(ShoppingCategory.allCases, id: \.self) { category in
                        let itemsInCategory = viewModel.shoppingItems.filter {
                            $0.category == category && !$0.isPurchased
                        }
                        if !itemsInCategory.isEmpty {
                            Section {
                                ForEach(itemsInCategory) { item in
                                    ShoppingItemRow(item: item)
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                        .onTapGesture { viewModel.togglePurchased(item) }
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                viewModel.deleteShoppingItem(item)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                            Button {
                                                startEditing(item)
                                            } label: {
                                                Label("Edit", systemImage: "pencil")
                                            }
                                            .tint(.mealActive)
                                        }
                                }
                            } header: {
                                HStack {
                                    Image(systemName: category.icon)
                                        .foregroundColor(.mealActive)
                                    Text(category.rawValue)
                                        .font(.headline)
                                        .foregroundColor(.mealDeep)
                                    Spacer()
                                    Text("\(itemsInCategory.count)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }

                    let purchasedItems = viewModel.shoppingItems.filter { $0.isPurchased }
                    if !purchasedItems.isEmpty {
                        Section {
                            ForEach(purchasedItems) { item in
                                ShoppingItemRow(item: item)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .onTapGesture { viewModel.togglePurchased(item) }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            viewModel.deleteShoppingItem(item)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        Button {
                                            startEditing(item)
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(.mealActive)
                                    }
                            }
                        } header: {
                            Text("Purchased")
                                .font(.headline)
                                .foregroundColor(.mealDeep)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)

                Button("Clear Purchased") {
                    viewModel.clearPurchased()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.white, Color.mealBackground],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundColor(.mealActive)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.mealActive.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: Color.mealDeep.opacity(0.08), radius: 8, x: 0, y: 5)
                .padding(.horizontal)

                Button("Add Item") {
                    editingItem = nil
                    itemName = ""
                    itemQty = "1"
                    itemCategory = .other
                    showAddItem = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .mealPrimaryButton(cornerRadius: 12)
                .padding(.horizontal)
            }
            .background(Color.mealBackground.ignoresSafeArea())
            .navigationTitle("Shopping List")
        }
        .sheet(isPresented: $showAddItem) {
            NavigationView {
                Form {
                    TextField("Name", text: $itemName)
                    TextField("Quantity", text: $itemQty)
                    Picker("Category", selection: $itemCategory) {
                        ForEach(ShoppingCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
                .navigationTitle(editingItem == nil ? "Add Item" : "Edit Item")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { showAddItem = false }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            if !itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                if let editingItem {
                                    viewModel.updateShoppingItem(
                                        id: editingItem.id,
                                        name: itemName,
                                        quantity: itemQty,
                                        category: itemCategory
                                    )
                                } else {
                                    viewModel.addShoppingItem(name: itemName, quantity: itemQty, category: itemCategory)
                                }
                                itemName = ""
                                itemQty = "1"
                                itemCategory = .other
                                editingItem = nil
                                showAddItem = false
                            }
                        }
                    }
                }
            }
        }
    }

    private func startEditing(_ item: ShoppingItem) {
        editingItem = item
        itemName = item.name
        itemQty = item.quantity
        itemCategory = item.category
        showAddItem = true
    }
}
