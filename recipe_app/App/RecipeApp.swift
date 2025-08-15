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
  @StateObject private var recipeService: RecipeService
  
  init() {
    let viewContext = PersistenceController.shared.container.viewContext
    let authService = AuthenticationService(viewContext: viewContext)
    let recipeService = RecipeService(viewContext: viewContext)
    
    authService.recipeService = recipeService
    
    _authService = StateObject(wrappedValue: authService)
    _recipeService = StateObject(wrappedValue: recipeService)
    
    authService.checkForExistingSession()
  }
  
  var body: some Scene {
    WindowGroup {
      MainView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
        .environmentObject(authService)
        .environmentObject(recipeService)
    }
  }
}
