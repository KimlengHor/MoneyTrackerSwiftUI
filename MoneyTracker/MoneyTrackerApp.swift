//
//  MoneyTrackerApp.swift
//  MoneyTracker
//
//  Created by Kimleng Hor on 3/1/23.
//

import SwiftUI

@main
struct MoneyTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
