//
//  MainView.swift
//  MoneyTracker
//
//  Created by Kimleng Hor on 3/1/23.
//

import SwiftUI

struct MainView: View {
    
    @State private var shouldPresentAddCardForm = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                TabView {
                    ForEach(0..<5) { num in
                        CreditCardView()
                            .padding(.bottom, 50)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .frame(height: 300)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
//                .onAppear {
//                    shouldPresentAddCardForm.toggle()
//                }
                
                Spacer()
                    .fullScreenCover(isPresented: $shouldPresentAddCardForm) {
                        AddCardForm()
                    }
            }
            .navigationTitle("Credit Cards")
            .navigationBarItems(trailing: addCardButton)
        }
    }
    
    struct CreditCardView: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Apple Blue Visa Card")
                    .font(.system(size: 25, weight: .semibold))
                HStack {
                    Image("visa")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 44)
                    Spacer()
                    Text("Balance: $5000")
                        .font(.system(size: 18, weight: .semibold))
                }
                .padding(.bottom, 20)
                
                Text("1234 1234 1234 1234")
                Text("Credit Limit: $50,000")
                
                HStack { Spacer() }
            }
            .padding()
            .background(LinearGradient(colors: [.blue.opacity(0.6), .blue], startPoint: .top, endPoint: .bottom))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(.black.opacity(0.5), lineWidth: 1))
            .foregroundColor(.white)
            .cornerRadius(8)
            .shadow(radius: 5)
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }
    
    var addCardButton: some View {
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
        MainView()
    }
}
