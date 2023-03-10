//
//  CatagoriesListView.swift
//  MoneyTracker
//
//  Created by Kimleng Hor on 3/7/23.
//

import SwiftUI

struct CatagoriesListView: View {
    
    @State private var name = ""
    @State private var color = Color.red
    
    @Binding var selectedCategories: Set<TransactionCategory>
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionCategory.timestamp, ascending: false)],
        animation: .default)
    private var categories: FetchedResults<TransactionCategory>
    
    var body: some View {
        Form {
            Section(header: Text("Select a catagory")) {
                ForEach(categories) { category in
                    Button {
                        if selectedCategories.contains(category) {
                            selectedCategories.remove(category)
                        } else {
                            selectedCategories.insert(category)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            if let data = category.colorData, let uiColor = UIColor.color(data: data) {
                                let color = Color(uiColor: uiColor)
                                Spacer()
                                    .frame(width: 30, height: 10)
                                    .background(color)
                            }
                            Text(category.name ?? "")
                            Spacer()
                            
                            if selectedCategories.contains(category) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }.onDelete { indexSet in
                    indexSet.forEach { i in
                        let category = categories[i]
                        selectedCategories.remove(category)
                        viewContext.delete(category)
                    }
                    
                    try? viewContext.save()
                }
            }
            
            Section(header: Text("Create a catagory")) {
                TextField("Name", text: $name)
                ColorPicker("Color", selection: $color)
                Button(action: handleCreate) {
                    HStack {
                        Spacer()
                        Text("Create").foregroundColor(Color.white)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(5)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private func handleCreate() {
        let context = PersistenceController.shared.container.viewContext
        let category = TransactionCategory(context: context)
        category.name = self.name
        category.colorData = UIColor(color).encode()
        category.timestamp = Date()
        
        do {
            try context.save()
            self.name = ""
        } catch {
            print("Failed to save catagory")
        }
    }
}

struct CatagoriesListView_Previews: PreviewProvider {
    static var previews: some View {
        CatagoriesListView(selectedCategories: .constant(.init())).environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
