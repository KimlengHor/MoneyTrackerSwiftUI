//
//  AddCardForm.swift
//  MoneyTracker
//
//  Created by Kimleng Hor on 3/1/23.
//

import SwiftUI

struct AddCardForm: View {
    
    let card: Card?
    var didAddCard: ((Card) -> ())? = nil
    
    init(card: Card? = nil, didAddCard: ((Card) -> ())? = nil) {
        self.card = card
        self.didAddCard = didAddCard
        
        _name = State(initialValue: self.card?.name ?? "")
        _cardNumber = State(initialValue: self.card?.number ?? "")
        
        if let limit = self.card?.limit {
            _limit = State(initialValue: String(limit))
        }
        
        _cardType = State(initialValue: self.card?.type ?? "Visa")
        
        _month = State(initialValue: Int(self.card?.expMonth ?? 1))
        _currentYear = State(initialValue: Int(self.card?.expYear ?? Int16(Calendar.current.component(.year, from: Date()))))
        
        if let colorData = self.card?.color, let uiColor = UIColor.color(data: colorData) {
            _color = State(initialValue: Color(uiColor: uiColor))
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var cardNumber = ""
    @State private var limit = ""
    
    @State private var cardType = ""
    
    @State private var month = 0
    @State private var currentYear = 0
    
    @State private var color = Color.blue
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Card information")) {
                    TextField("Name", text: $name)
                    TextField("Credit Card Number", text: $cardNumber)
                        .keyboardType(.numberPad)
                    TextField("Credit Limit", text: $limit)
                        .keyboardType(.numberPad)
                    
                    Picker("Type", selection: $cardType) {
                        ForEach(["Visa", "Mastercard", "Discover"], id: \.self) { cardType in
                            Text(cardType).tag(cardType)
                        }
                    }
                }
                Section(header: Text("Expiration")) {
                    Picker("Month", selection: $month) {
                        ForEach(1..<13, id: \.self) { num in
                            Text(String(num)).tag(num)
                        }
                    }
                    Picker("Year", selection: $currentYear) {
                        ForEach(currentYear..<currentYear + 20, id: \.self) { num in
                            Text(String(num)).tag(num)
                        }
                    }
                }
                Section(header: Text("Color")) {
                    ColorPicker("Color", selection: $color)
                }
                
            }
            .navigationTitle(self.card != nil ? (self.card?.name ?? "") : "Add credit card")
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
    }
    
    private var cancelButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Cancel")
        })
    }
    
    private var saveButton: some View {
        Button(action: {
            let viewContext = PersistenceController.shared.container.viewContext
            
            let card = self.card != nil ? self.card! : Card(context: viewContext)
            
            card.name = self.name
            card.number = self.cardNumber
            card.limit = Int32(self.limit) ?? 0
            card.type = self.cardType
            card.expMonth = Int16(self.month)
            card.expYear = Int16(self.currentYear)
            card.timestamp = Date()
            card.color = UIColor(self.color).encode()
            
            do {
                try viewContext.save()
                presentationMode.wrappedValue.dismiss()
                didAddCard?(card)
            } catch {
                print("Failed to persist new card")
            }
            
        }, label: {
            Text("Save")
        })
    }
}

struct AddCardForm_Previews: PreviewProvider {
    static var previews: some View {
        AddCardForm()
    }
}

extension UIColor {
    class func color(data: Data) -> UIColor? {
        return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor
    }
    
    func encode() -> Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
}
