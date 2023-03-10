//
//  MainPadDeviceView.swift
//  MoneyTracker
//
//  Created by Kimleng Hor on 3/10/23.
//

import SwiftUI

struct MainPadDeviceView: View {
    
    @State var shouldShowAddCardForm = false

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.timestamp, ascending: false)],
        animation: .default)
    private var cards: FetchedResults<Card>
    
    @State var selectedCard: Card?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(cards) { card in
                                CreditCardView(card: card)
                                    .frame(width: 350)
                                    .onTapGesture {
                                        withAnimation {
                                            self.selectedCard = card
                                        }
                                    }
                                    .scaleEffect(self.selectedCard == card ? 1.1 : 1)
                            }
                        }
                        .frame(height: 300)
                        .onAppear {
                            self.selectedCard = cards.first
                        }
                        .padding(.leading)
                    }
                    if let card = self.selectedCard {
                        TransactionGrid(card: card)
                    }
                }
            }.navigationTitle("Money Tracker")
                .navigationBarItems(trailing: addCardButton)
                .sheet(isPresented: $shouldShowAddCardForm) {
                    AddCardForm(card: nil, didAddCard: nil)
                }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var addCardButton: some View {
        Button {
            shouldShowAddCardForm.toggle()
        } label: {
            Text("+ Card")
        }

    }
}

struct TransactionGrid: View {
    
    @State private var shouldShowAddTransactionForm = false
    
    let card: Card
    
    init(card: Card) {
        self.card = card
        
        fetchRequest = FetchRequest<CardTransaction>(entity: CardTransaction.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \CardTransaction.timestamp, ascending: false)], predicate: .init(format: "card == %@", self.card))
    }
    
    var fetchRequest: FetchRequest<CardTransaction>
    
    var body: some View {
        VStack {
            HStack {
                Text("Transactions")
                Spacer()
                Button {
                    shouldShowAddTransactionForm.toggle()
                } label: {
                    Text("+ Transaction")
                }
            }
            .sheet(isPresented: $shouldShowAddTransactionForm) {
                AddTransactionForm(card: card)
            }
            
            let columns: [GridItem] = [
                .init(.fixed(100), spacing: 16, alignment: .leading),
                .init(.fixed(200), spacing: 16, alignment: .leading),
                .init(.adaptive(minimum: 300, maximum: 800), spacing: 16, alignment: .leading),
                .init(.flexible(minimum: 100, maximum: 450), spacing: 16, alignment: .trailing)
            ]
            
            LazyVGrid(columns: columns) {
                HStack{
                    Text("Date")
                    Image(systemName: "arrow.up.arrow.down")
                }
               
                Text("Photo / Reciept")
            
                HStack{
                    Text("Name")
                    Image(systemName: "arrow.up.arrow.down")
                }
                
                HStack{
                    Text("Amount")
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
            .foregroundColor(Color(.darkGray))
            
            LazyVGrid(columns: columns) {
                ForEach(fetchRequest.wrappedValue) { transaction in
                    Group {
                        if let date = transaction.timestamp {
                            Text(dateFormatter.string(from: date))
                        }
                        if let data = transaction.photoData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .cornerRadius(8)
                        } else {
                            Text("No photo available")
                        }
                        Text(transaction.name ?? "")
                        Text(String(format: "$%.2f",transaction.amount))
                    }
                    .multilineTextAlignment(.leading)
                }
            }
            
        }.font(.system(size: 24, weight: .semibold))
            .padding()
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}

struct MainPadDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        MainPadDeviceView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
