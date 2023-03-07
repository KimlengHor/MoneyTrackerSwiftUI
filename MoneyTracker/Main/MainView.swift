//
//  MainView.swift
//  MoneyTracker
//
//  Created by Kimleng Hor on 3/1/23.
//

import SwiftUI

struct MainView: View {
    
    @State private var shouldPresentAddCardForm = false
    
    @State private var selectedCardHash = -1
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.timestamp, ascending: false)],
        animation: .default)
    private var cards: FetchedResults<Card>
    
    var body: some View {
        NavigationView {
            ScrollView {
                if cards.isEmpty {
                    emptyPromptMessage
                } else {
                    
                    TabView(selection: $selectedCardHash) {
                        ForEach(cards) { card in
                            CreditCardView(card: card)
                                .padding(.bottom, 50)
                                .tag(card.hash)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: 300)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    .onAppear {
                        self.selectedCardHash = cards.first?.hash ?? -1
                    }
                    
                    if let firstIndex = cards.firstIndex(where: {$0.hash == selectedCardHash}) {
                        let card = self.cards[firstIndex]
                        Text(card.name ?? "")
                        TransactionsListView(card: card)
                    }
                }
                
                Spacer()
                    .fullScreenCover(isPresented: $shouldPresentAddCardForm) {
                        AddCardForm(card: nil) { card in
                            self.selectedCardHash = card.hash
                        }
                    }
            }
            .navigationTitle("Credit Cards")
            .navigationBarItems(leading: HStack {
                addItemButton
                deleteAllButton
            }, trailing: addCardButton)
        }
    }
    
    private var emptyPromptMessage: some View {
        VStack {
            Text("You currently have no cards in the system.")
                .padding(.horizontal, 48)
                .padding(.vertical)
                .multilineTextAlignment(.center)
            Button {
                shouldPresentAddCardForm.toggle()
            } label: {
                Text("+ Add Your First Card")
            }
            .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14))
            .foregroundColor(Color(.systemBackground))
            .background(Color(.label))
            .cornerRadius(5)

        }.font(.system(size: 22, weight: .semibold))
    }
    
    private var addItemButton: some View {
        Button(action: {
            withAnimation {
                let viewContext = PersistenceController.shared.container.viewContext
                let card = Card(context: viewContext)
                card.timestamp = Date()

                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }, label: {
            HStack {
                Text("Add Item")
            }
        })
    }
    
    private var deleteAllButton: some View {
        Button {
            cards.forEach { card in
                viewContext.delete(card)
            }
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        } label: {
            Text("Delete All")
        }
    }
    
    struct CreditCardView: View {
        
        @State private var shouldShowActionSheet = false
        @State private var shouldShowEditForm = false
        
        @State var refreshId = UUID()
        
        let card: Card
        
        private func handleDelete() {
            let viewContext = PersistenceController.shared.container.viewContext
            viewContext.delete(card)
            do {
                try viewContext.save()
            } catch {
                print("Delete is not working")
            }
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(card.name ?? "")
                        .font(.system(size: 25, weight: .semibold))
                    Spacer()
                    Button {
                        shouldShowActionSheet.toggle()
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 28, weight: .bold))
                    }
                    .actionSheet(isPresented: $shouldShowActionSheet) {
                        .init(title: Text(card.name ?? ""), message: Text("Options"), buttons: [
                            .default(Text("Edit"), action: {
                                shouldShowEditForm.toggle()
                            }),
                            .destructive(Text("Delete Card"), action: handleDelete),
                            .cancel()
                        ])
                    }
                }
                HStack {
                    Image(card.type?.lowercased() ?? "visa")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 44)
                    Spacer()
                    Text("Balance: $5000")
                        .font(.system(size: 18, weight: .semibold))
                }
                .padding(.bottom, 20)
                
                Text(card.number ?? "")
                
                HStack {
                    Text("Credit Limit: $\(card.limit)")
                    Spacer()
                    Text("Valid Thru \(card.expMonth < 10 ? ("0" + String(card.expMonth)) : String(card.expMonth))/\(card.expYear % 100)")
                }
                
                HStack { Spacer() }
            }
            .padding()
            .background(
                VStack{
                    if let colorData = card.color,
                       let uiColor = UIColor.color(data: colorData),
                       let actualColor = Color(uiColor) {
                        
                        LinearGradient(colors: [actualColor.opacity(0.6), actualColor], startPoint: .top, endPoint: .bottom)
                    } else {
                        Color.purple
                    }
                }
            )
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(.black.opacity(0.5), lineWidth: 1))
            .foregroundColor(.white)
            .cornerRadius(8)
            .shadow(radius: 5)
            .padding(.horizontal)
            .padding(.top, 8)
            .fullScreenCover(isPresented: $shouldShowEditForm) {
                AddCardForm(card: card)
            }
        }
    }
    
    private var addCardButton: some View {
        Button(action: {
            //trigger action
            shouldPresentAddCardForm.toggle()
        }, label: {
            Text("+ Card")
                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                .foregroundColor(.white)
                .background(.black)
                .cornerRadius(5)
                .font(.system(size: 16, weight: .bold))
        })
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.shared.container.viewContext
        MainView()
            .environment(\.managedObjectContext, viewContext)
    }
}
