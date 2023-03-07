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
    
    var fetchRequest: FetchRequest<CardTransaction>
    
    var body: some View {
        VStack {
            Text("Get started by adding your first transaction")
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
            .fullScreenCover(isPresented: $shouldShowTransactionForm) {
                AddTransactionForm(card: self.card)
            }
            ForEach(fetchRequest.wrappedValue) { transaction in
                CardTransactionView(transaction: transaction)
            }
        }
    }
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
        ScrollView {
            if let card = firstCard {
                TransactionsListView(card: card)
                    .environment(\.managedObjectContext, context)
            }
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
                            .foregroundColor(.black)
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
        .background(Color.white)
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
