//
//  DependencyContainer.swift
//  recipe_app
//
//  Created by Nik Uzair on 15/08/2025.
//

import Foundation
import SwiftUI
import CoreData

@MainActor
protocol DependencyContainerProtocol {
  var persistenceController: PersistenceController { get }
  var authService: AuthenticationService { get }
  var recipeService: RecipeService { get }
}

@MainActor
class DependencyContainer: ObservableObject, DependencyContainerProtocol {
  static let shared = DependencyContainer()
  
  let persistenceController: PersistenceController
  let authService: AuthenticationService
  let recipeService: RecipeService
  
  private init() {
    self.persistenceController = PersistenceController.shared
    let viewContext = persistenceController.container.viewContext
    
    self.authService = AuthenticationService(viewContext: viewContext)
    self.recipeService = RecipeService(viewContext: viewContext)
    
    self.authService.recipeService = self.recipeService
  }
  
  func makeLoginViewModel() -> LoginViewModel {
    LoginViewModel(authService: authService)
  }
  
  func makeRecipeListViewModel() -> RecipeListViewModel {
    RecipeListViewModel(recipeService: recipeService, authService: authService)
  }
  
  func makeAddRecipeViewModel() -> AddRecipeViewModel {
    AddRecipeViewModel(recipeService: recipeService)
  }
  
  func makeRecipeDetailViewModel(recipe: RecipeModel) -> RecipeDetailViewModel {
    RecipeDetailViewModel(recipe: recipe, recipeService: recipeService)
  }
}
