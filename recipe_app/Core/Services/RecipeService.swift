//
//  RecipeService.swift
//  recipe_app
//
//  Created by Nik Uzair on 15/08/2025.
//

import Foundation
import CoreData
import SwiftUI

@MainActor
class RecipeService: ObservableObject {
  @Published private(set) var recipes: [RecipeModel] = []
  @Published private(set) var recipeTypes: [RecipeTypeModel] = []
  @Published private(set) var isLoading = false
  @Published var searchText = ""
  @Published var selectedRecipeType: RecipeTypeModel?
  
  private let viewContext: NSManagedObjectContext
  private var currentUserId: UUID?
  
  init(viewContext: NSManagedObjectContext) {
    self.viewContext = viewContext
    loadRecipeTypes()
  }
  
  var filteredRecipes: [RecipeModel] {
    var filtered = recipes
    
    if let selectedType = selectedRecipeType {
      filtered = filtered.filter { $0.typeId == selectedType.id }
    }
    
    if !searchText.isEmpty {
      filtered = filtered.filter { recipe in
        recipe.name.localizedCaseInsensitiveContains(searchText) ||
        recipe.ingredients.contains { $0.localizedCaseInsensitiveContains(searchText) }
      }
    }
    
    return filtered.sorted { $0.updatedAt > $1.updatedAt }
  }
  
  private func loadRecipeTypes() {
    recipeTypes = RecipeTypeModel.loadFromJSON()
  }
  
  func setCurrentUser(_ userId: UUID?) {
    print("RecipeService.setCurrentUser: Setting user to \(userId?.uuidString ?? "nil")")
    self.currentUserId = userId
    if userId != nil {
      print("RecipeService.setCurrentUser: Calling fetchRecipes")
      fetchRecipes()
    } else {
      print("RecipeService.setCurrentUser: Clearing recipes (user is nil)")
      self.recipes = []
    }
  }
  
  func fetchRecipes() {
    guard let userId = currentUserId else {
      print("fetchRecipes: No currentUserId set")
      self.recipes = []
      return
    }
    
    isLoading = true
    
    let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "userId == %@", userId as CVarArg)
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
    
    do {
      let entities = try viewContext.fetch(fetchRequest)
      self.recipes = entities.map { RecipeModel(from: $0) }
      print("fetchRecipes: Loaded \(self.recipes.count) recipes for user \(userId)")
    } catch {
      print("Error fetching recipes: \(error)")
    }
    
    isLoading = false
  }
  
  func addRecipe(_ recipe: RecipeModel) throws {
    var recipeWithUser = recipe
    if recipeWithUser.userId == nil {
      recipeWithUser.userId = currentUserId
    }
    _ = recipeWithUser.toEntity(context: viewContext)
    try viewContext.save()
    fetchRecipes()
  }
  
  func updateRecipe(_ recipe: RecipeModel) throws {
    let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "id == %@ AND userId == %@",
                                         recipe.id as CVarArg,
                                         currentUserId as CVarArg? ?? NSNull())
    fetchRequest.fetchLimit = 1
    
    guard let entity = try viewContext.fetch(fetchRequest).first else {
      throw RecipeError.notFound
    }
    
    var updatedRecipe = recipe
    updatedRecipe.userId = currentUserId
    updatedRecipe.updateEntity(entity)
    try viewContext.save()
    fetchRecipes()
  }
  
  func deleteRecipe(_ recipe: RecipeModel) throws {
    let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "id == %@ AND userId == %@",
                                         recipe.id as CVarArg,
                                         currentUserId as CVarArg? ?? NSNull())
    fetchRequest.fetchLimit = 1
    
    guard let entity = try viewContext.fetch(fetchRequest).first else {
      throw RecipeError.notFound
    }
    
    viewContext.delete(entity)
    try viewContext.save()
    fetchRecipes()
  }
  
  func toggleFavorite(_ recipe: RecipeModel) throws {
    var updatedRecipe = recipe
    updatedRecipe.isFavorite.toggle()
    try updateRecipe(updatedRecipe)
  }
  
  func getRecipeType(for typeId: String) -> RecipeTypeModel? {
    recipeTypes.first { $0.id == typeId }
  }
  
  func loadSampleData(for userId: UUID, force: Bool = false) {
    guard currentUserId == userId else {
      print("Warning: currentUserId mismatch when loading sample data")
      return
    }
    
    if !force {
      let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
      fetchRequest.predicate = NSPredicate(format: "userId == %@", userId as CVarArg)
      fetchRequest.fetchLimit = 1
      
      do {
        let existingRecipes = try viewContext.fetch(fetchRequest)
        if !existingRecipes.isEmpty {
          print("loadSampleData: User \(userId) already has \(existingRecipes.count) recipes, skipping sample data")
          return
        }
        print("loadSampleData: User \(userId) has no recipes, loading sample data")
      } catch {
        print("Error checking existing recipes: \(error)")
      }
    }
    
    let sampleRecipes = [
      RecipeModel(
        name: "Pancakes",
        typeId: "breakfast",
        userId: userId,
        imageData: UIImage(named: "pancakes")!.pngData()!,
        ingredients: ["2 cups flour", "2 eggs", "1.5 cups milk", "2 tbsp butter", "2 tbsp sugar", "1 tsp baking powder", "1/2 tsp salt"],
        steps: ["Mix dry ingredients", "Beat eggs and milk together", "Combine wet and dry ingredients", "Melt butter and add to batter", "Cook on griddle until bubbles form", "Flip and cook until golden"],
        prepTime: 20,
        servings: 4
      ),
      RecipeModel(
        name: "Caesar Salad",
        typeId: "salad",
        userId: userId,
        imageData: UIImage(named: "caesar_salad")!.pngData()!,
        ingredients: ["Romaine lettuce", "Parmesan cheese", "Croutons", "Caesar dressing", "Lemon juice", "Black pepper"],
        steps: ["Wash and chop lettuce", "Add dressing and toss", "Top with parmesan and croutons", "Add lemon juice and pepper to taste"],
        prepTime: 15,
        servings: 2
      ),
      RecipeModel(
        name: "Spaghetti Carbonara",
        typeId: "dinner",
        userId: userId,
        imageData: UIImage(named: "spaghetti_carbonara")!.pngData()!,
        ingredients: ["400g spaghetti", "200g pancetta", "4 eggs", "100g Pecorino Romano", "Black pepper", "Salt"],
        steps: ["Cook spaghetti al dente", "Fry pancetta until crispy", "Beat eggs with cheese", "Drain pasta, reserve water", "Mix pasta with pancetta", "Remove from heat, add egg mixture", "Toss quickly, add pasta water if needed"],
        prepTime: 25,
        servings: 4
      ),
      RecipeModel(
        name: "Chocolate Chip Cookies",
        typeId: "dessert",
        userId: userId,
        imageData: UIImage(named: "chocolate_chip_cookies")!.pngData()!,
        ingredients: ["2.25 cups flour", "1 cup butter", "0.75 cup sugar", "0.75 cup brown sugar", "2 eggs", "1 tsp vanilla", "1 tsp baking soda", "1 tsp salt", "2 cups chocolate chips"],
        steps: ["Preheat oven to 375°F", "Cream butter and sugars", "Beat in eggs and vanilla", "Mix in flour, baking soda, and salt", "Stir in chocolate chips", "Drop onto baking sheets", "Bake 9-11 minutes"],
        prepTime: 30,
        servings: 48
      ),
      RecipeModel(
        name: "Greek Yogurt Parfait",
        typeId: "snack",
        userId: userId,
        imageData: UIImage(named: "greek_yogurt_parfait")!.pngData()!,
        ingredients: ["Greek yogurt", "Granola", "Fresh berries", "Honey", "Chia seeds"],
        steps: ["Layer yogurt in glass", "Add granola layer", "Add berries", "Drizzle with honey", "Top with chia seeds"],
        prepTime: 5,
        servings: 1
      ),
      RecipeModel(
        name: "Tomato Soup",
        typeId: "soup",
        userId: userId,
        imageData: UIImage(named: "tomato_soup")!.pngData()!,
        ingredients: ["6 large tomatoes", "1 onion", "3 cloves garlic", "2 cups vegetable broth", "1/2 cup cream", "Basil", "Salt", "Pepper"],
        steps: ["Roast tomatoes at 400°F for 30 min", "Sauté onion and garlic", "Add roasted tomatoes and broth", "Simmer for 15 minutes", "Blend until smooth", "Stir in cream and basil", "Season to taste"],
        prepTime: 45,
        servings: 4
      ),
      RecipeModel(
        name: "Bruschetta",
        typeId: "appetizer",
        userId: userId,
        imageData: UIImage(named: "bruschetta")!.pngData()!,
        ingredients: ["Baguette", "4 tomatoes", "2 cloves garlic", "Fresh basil", "Olive oil", "Balsamic vinegar", "Salt", "Pepper"],
        steps: ["Slice and toast baguette", "Dice tomatoes", "Mince garlic and basil", "Mix tomatoes, garlic, basil", "Add oil and vinegar", "Season with salt and pepper", "Top bread with mixture"],
        prepTime: 15,
        servings: 6
      )
    ]
    
    var addedCount = 0
    for recipe in sampleRecipes {
      do {
        try addRecipe(recipe)
        addedCount += 1
      } catch {
        print("Error adding sample recipe \(recipe.name): \(error)")
      }
    }
    
    print("loadSampleData: Added \(addedCount) sample recipes for user \(userId)")
    
    do {
      try viewContext.save()
      print("loadSampleData: Successfully saved context")
    } catch {
      print("loadSampleData: Error saving context: \(error)")
    }
    
    fetchRecipes()
  }
}

enum RecipeError: LocalizedError {
  case notFound
  case invalidData
  
  var errorDescription: String? {
    switch self {
    case .notFound:
      return "Recipe not found"
    case .invalidData:
      return "Invalid recipe data"
    }
  }
}

