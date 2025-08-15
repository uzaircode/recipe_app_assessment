//
//  recipe_appTests.swift
//  recipe_appTests
//
//  Created by Nik Uzair on 15/08/2025.
//

import Testing
import CoreData
@testable import recipe_app

@Suite("Recipe App Tests")
struct RecipeAppTests {
  
  @Test("Recipe Model Creation")
  func testRecipeModelCreation() async throws {
    let recipe = RecipeModel(
      name: "Test Recipe",
      typeId: "breakfast",
      ingredients: ["Ingredient 1", "Ingredient 2"],
      steps: ["Step 1", "Step 2"],
      prepTime: 30,
      servings: 4
    )
    
    #expect(recipe.name == "Test Recipe")
    #expect(recipe.typeId == "breakfast")
    #expect(recipe.ingredients.count == 2)
    #expect(recipe.steps.count == 2)
    #expect(recipe.prepTime == 30)
    #expect(recipe.servings == 4)
    #expect(recipe.isFavorite == false)
  }
  
  @Test("Recipe Type Model Load From JSON")
  func testRecipeTypeModelLoadFromJSON() async throws {
    let recipeTypes = RecipeTypeModel.loadFromJSON()
    
    #expect(recipeTypes.count > 0)
    
    let breakfastType = recipeTypes.first { $0.id == "breakfast" }
    #expect(breakfastType != nil)
    #expect(breakfastType?.displayName == "Breakfast")
    #expect(breakfastType?.iconName == "sun.max.fill")
  }
  
  @Test("User Model Creation")
  func testUserModelCreation() async throws {
    let user = UserModel(
      username: "testuser",
      passwordHash: "hashedpassword123"
    )
    
    #expect(user.username == "testuser")
    #expect(user.passwordHash == "hashedpassword123")
    #expect(user.token == nil)
    #expect(user.lastLogin == nil)
  }
  
  @Test("Recipe Entity Conversion")
  @MainActor
  func testRecipeEntityConversion() async throws {
    let persistenceController = PersistenceController(inMemory: true)
    let viewContext = persistenceController.container.viewContext
    
    let recipe = RecipeModel(
      name: "Test Recipe",
      typeId: "lunch",
      ingredients: ["Ingredient 1"],
      steps: ["Step 1"],
      prepTime: 15,
      servings: 2
    )
    
    let entity = recipe.toEntity(context: viewContext)
    
    #expect(entity.name == recipe.name)
    #expect(entity.typeId == recipe.typeId)
    #expect(entity.prepTime == Int32(recipe.prepTime))
    #expect(entity.servings == Int32(recipe.servings))
    
    let convertedBack = RecipeModel(from: entity)
    #expect(convertedBack.name == recipe.name)
    #expect(convertedBack.typeId == recipe.typeId)
  }
  
  @Test("Authentication Service Registration and Login")
  @MainActor
  func testAuthenticationService() async throws {
    let persistenceController = PersistenceController(inMemory: true)
    let viewContext = persistenceController.container.viewContext
    let authService = AuthenticationService(viewContext: viewContext)
    
    try await authService.register(username: "testuser", password: "testpassword123")
    #expect(authService.isAuthenticated == true)
    
    authService.logout()
    #expect(authService.isAuthenticated == false)
    
    try await authService.login(username: "testuser", password: "testpassword123")
    #expect(authService.isAuthenticated == true)
    
    authService.logout()
    
    do {
      try await authService.login(username: "testuser", password: "wrongpassword")
      Issue.record("Login should fail with wrong password")
    } catch {
      #expect(true)
    }
  }
  
  @Test("Add Recipe View Model Validation")
  @MainActor
  func testAddRecipeViewModelValidation() async throws {
    let persistenceController = PersistenceController(inMemory: true)
    let viewContext = persistenceController.container.viewContext
    let recipeService = RecipeService(viewContext: viewContext)
    let viewModel = AddRecipeViewModel(recipeService: recipeService)
    
    #expect(viewModel.isFormValid == false)
    
    viewModel.recipeName = "Test Recipe"
    viewModel.selectedRecipeType = RecipeTypeModel(
      id: "test",
      name: "test",
      displayName: "Test",
      iconName: "test"
    )
    viewModel.ingredients = ["Ingredient 1"]
    viewModel.steps = ["Step 1"]
    
    #expect(viewModel.isFormValid == true)
  }
  
  @Test("Recipe Detail View Model Edit Mode")
  @MainActor
  func testRecipeDetailViewModelEdit() async throws {
    let persistenceController = PersistenceController(inMemory: true)
    let viewContext = persistenceController.container.viewContext
    let recipeService = RecipeService(viewContext: viewContext)
    
    let originalRecipe = RecipeModel(
      name: "Original",
      typeId: "breakfast",
      ingredients: ["Original Ingredient"],
      steps: ["Original Step"],
      prepTime: 20,
      servings: 2
    )
    
    let viewModel = RecipeDetailViewModel(
      recipe: originalRecipe,
      recipeService: recipeService
    )
    
    viewModel.toggleEditMode()
    #expect(viewModel.isEditMode == true)
    
    viewModel.editedName = "Updated Recipe"
    viewModel.editedPrepTime = 30
    
    #expect(viewModel.editedName == "Updated Recipe")
    #expect(viewModel.editedPrepTime == 30)
    
    viewModel.toggleEditMode()
    #expect(viewModel.isEditMode == false)
  }
}
