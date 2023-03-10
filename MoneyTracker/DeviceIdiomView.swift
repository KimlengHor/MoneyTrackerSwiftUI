//
//  DeviceIdiomView.swift
//  MoneyTracker
//
//  Created by Kimleng Hor on 3/10/23.
//

import SwiftUI

struct DeviceIdiomView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            MainView()
        } else {
//            if horizontalSizeClass == .compact {
//                Color.blue
//            } else {
//
//            }
            MainPadDeviceView()
        }
    }
}

struct DeviceIdiomView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceIdiomView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        
        DeviceIdiomView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
