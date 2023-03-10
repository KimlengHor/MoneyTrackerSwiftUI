//
//  TransactionsListView.swift
//  MoneyTracker
//
//  Created by Kimleng Hor on 3/7/23.
//

import SwiftUI

struct TransactionsListView: View {
    
    let card: Card
    
    init(card: Card) {
        self.card = card
        
        fetchRequest = FetchRequest<CardTransaction>(entity: CardTransaction.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \CardTransaction.timestamp, ascending: false)], predicate: .init(format: "card == %@", self.card))
    }
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var shouldShowTransactionForm = false
    @State private var shouldShowFilterSheet = false
    
    @State var selectedCategories = Set<TransactionCategory>()
    
    var fetchRequest: FetchRequest<CardTransaction>
    
    var body: some View {
        VStack {
            if fetchRequest.wrappedValue.isEmpty {
                Text("Get started by adding your first transaction")
                addTransactionButton
            } else {
                HStack {
                    Spacer()
                    addTransactionButton
                    filterButton
                        .sheet(isPresented: $shouldShowFilterSheet) {
                            
                            FilterSheet(didSaveFilter: { categories in
                                self.selectedCategories = categories
                            }, selectedCategories: selectedCategories)
                        }
                }.padding(.horizontal)
                
                ForEach(filterTransactions(selectedCategories: self.selectedCategories)) { transaction in
                    CardTransactionView(transaction: transaction)
                }            }
        }.fullScreenCover(isPresented: $shouldShowTransactionForm) {
            AddTransactionForm(card: self.card)
        }
    }
    
    private func filterTransactions(selectedCategories: Set<TransactionCategory>) -> [CardTransaction] {
        if selectedCategories.isEmpty {
            return Array(fetchRequest.wrappedValue)
        }
        
        return fetchRequest.wrappedValue.filter { transaction in
            var shouldKeep = false
            if let categories = transaction.categories as? Set<TransactionCategory> {
                categories.forEach({ category in
                    if selectedCategories.contains(category) {
                        shouldKeep = true
                    }
                })
            }
            
            return shouldKeep
        }
    }
    
    private var addTransactionButton: some View {
        Button {
            shouldShowTransactionForm.toggle()
        } label: {
            Text("+ Transaction")
                .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14))
                .background(Color(.label))
                .foregroundColor(Color(.systemBackground))
                .cornerRadius(5)
                .font(.headline)
        }
    }
    
    private var filterButton: some View {
        Button {
            shouldShowFilterSheet.toggle()
        } label: {
            HStack{
                Image(systemName: "line.horizontal.3.decrease.circle")
                Text("+ Filter")
            }
            .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14))
            .background(Color(.label))
            .foregroundColor(Color(.systemBackground))
            .cornerRadius(5)
            .font(.headline)
        }
    }
}

struct FilterSheet: View {
    
    let didSaveFilter: (Set<TransactionCategory>) -> ()
    
    @Environment(\.presentationMode) var presentationMode
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionCategory.timestamp, ascending: false)],
        animation: .default)
    private var categories: FetchedResults<TransactionCategory>
    @State var selectedCategories: Set<TransactionCategory>
    
    var body: some View {
        NavigationView {
            Form {
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
                }
            }.navigationTitle("Select filters")
                .navigationBarItems(trailing: saveButton)
        }
    }
    
    private var saveButton: some View {
        Button {
            didSaveFilter(selectedCategories)
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text("Save")
        }

    }
}

struct CardTransactionView: View {
    
    let transaction: CardTransaction
    
    @State var shouldPresentActionSheet = false
    
    private func handleDelete() {
        withAnimation {
            do {
                let context = PersistenceController.shared.container.viewContext
                context.delete(transaction)
                try context.save()
            } catch {
                print("Failed to delete transaction: ", error)
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(transaction.name ?? "")
                        .font(.headline)
                    if let date = transaction.timestamp {
                        Text(dateFormatter.string(from: date))
                    }
                }
                Spacer()
                
                VStack(alignment: .trailing) {
                    Button {
                        shouldPresentActionSheet.toggle()
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 24))
                            .foregroundColor(Color(.label))
                    }
                    .padding(EdgeInsets(top: 6, leading: 8, bottom: 4, trailing: 0))
                    .actionSheet(isPresented: $shouldPresentActionSheet) {
                        .init(title: Text(transaction.name ?? ""), message: nil, buttons: [.cancel(), .destructive(Text("Delete"), action: handleDelete)])
                    }
                    
                    Text(String(format: "$%.2f", transaction.amount))
                }
            }
            
            if let categories = transaction.categories as? Set<TransactionCategory> {
                let sortedByTimeStampCategories = Array(categories).sorted(by: {$0.timestamp?.compare($1.timestamp ?? Date()) == .orderedDescending})
                HStack {
                    ForEach(sortedByTimeStampCategories) { category in
                        if let data = category.colorData, let uiColor = UIColor.color(data: data) {
                            let color = Color(uiColor: uiColor)
                            Text(category.name ?? "")
                                .font(.system(size: 16, weight: .semibold))
                                .padding(.vertical, 6)
                                .padding(.horizontal, 8)
                                .background(color)
                                .foregroundColor(.white)
                                .cornerRadius(5)
                        }
                    }
                    Spacer()
                }
            }
            
            if let photoData = transaction.photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            }
        }
        .padding()
        .background(Color.cardTransactionBackground)
        .cornerRadius(5)
        .shadow(radius: 5)
        .padding()
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}

struct TransactionsListView_Previews: PreviewProvider {
    
    static let firstCard: Card? = {
        let context = PersistenceController.shared.container.viewContext
        let request = Card.fetchRequest()
        request.sortDescriptors = [.init(key: "timestamp", ascending: false)]
        return try? context.fetch(request).first
    }()
    
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        NavigationView {
            if let card = firstCard {
                TransactionsListView(card: card)
            }
        }.colorScheme(.light)
            .environment(\.managedObjectContext, context)
    }
}
