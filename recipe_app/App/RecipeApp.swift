//
//  RecipeApp.swift
//  recipe_app
//
//  Created by Nik Uzair on 15/08/2025.
//

import SwiftUI

@main
struct recipeApp: App {
  let persistenceController = PersistenceController.shared
  @StateObject private var authService: AuthenticationService
  
  init() {
    let viewContext = PersistenceController.shared.container.viewContext
    let authService = AuthenticationService(viewContext: viewContext)
    
    
    _authService = StateObject(wrappedValue: authService)
    
    authService.checkForExistingSession()
  }
  
  var body: some Scene {
    WindowGroup {
      MainView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
        .environmentObject(authService)
    }
  }
}
