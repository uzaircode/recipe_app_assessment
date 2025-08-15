//
//  recipe_appApp.swift
//  recipe_app
//
//  Created by Nik Uzair on 15/08/2025.
//

import SwiftUI

struct recipe_appApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
