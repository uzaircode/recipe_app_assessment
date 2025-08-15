//
//  RecipeListViewModel.swift
//  recipe_app
//
//  Created by Nik Uzair on 15/08/2025.
//

import Foundation
import SwiftUI
import CoreData
import UIKit

@MainActor
class RecipeListViewModel: ObservableObject {
  @Published var searchText = ""
  @Published var selectedRecipeType: RecipeTypeModel?
  @Published var showingAddRecipe = false
  @Published var showingFilterSheet = false
  @Published var sortOption: SortOption = .name
  
  let recipeService: RecipeService
  let authService: AuthenticationService
  
  enum SortOption: String, CaseIterable {
    case updatedDate = "Recently Updated"
    case name = "Name"
    case prepTime = "Prep Time"
    case favorites = "Favorites First"
    
    var systemImage: String {
      switch self {
      case .updatedDate: return "clock"
      case .name: return "textformat"
      case .prepTime: return "timer"
      case .favorites: return "star.fill"
      }
    }
  }
  
  init(recipeService: RecipeService, authService: AuthenticationService) {
    self.recipeService = recipeService
    self.authService = authService
  }
  
  var recipes: [RecipeModel] {
    var filtered = recipeService.filteredRecipes
    
    // Apply search filtering
    if !searchText.isEmpty {
      let lowerSearch = searchText.lowercased()
      filtered = filtered.filter { recipe in
        recipe.name.lowercased().contains(lowerSearch) ||
        recipe.ingredients.joined(separator: " ").lowercased().contains(lowerSearch)
      }
    }
    
    // Apply selected recipe type filter
    if let selectedType = selectedRecipeType {
      filtered = filtered.filter { $0.typeId == selectedType.id }
    }
    
    // Sort
    switch sortOption {
    case .updatedDate:
      return filtered.sorted { $0.updatedAt > $1.updatedAt }
    case .name:
      return filtered.sorted { $0.name < $1.name }
    case .prepTime:
      return filtered.sorted { $0.prepTime < $1.prepTime }
    case .favorites:
      return filtered.sorted { recipe1, recipe2 in
        if recipe1.isFavorite == recipe2.isFavorite {
          return recipe1.updatedAt > recipe2.updatedAt
        }
        return recipe1.isFavorite && !recipe2.isFavorite
      }
    }
  }
  
  
  var recipeTypes: [RecipeTypeModel] {
    recipeService.recipeTypes
  }
  
  var isLoading: Bool {
    recipeService.isLoading
  }
  
  var currentUsername: String {
    authService.currentUser?.username ?? "User"
  }
  
  var filterBadgeCount: Int {
    var count = 0
    if selectedRecipeType != nil { count += 1 }
    if !searchText.isEmpty { count += 1 }
    return count
  }
  
  func toggleFavorite(_ recipe: RecipeModel) {
    do {
      // Add haptic feedback
      let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
      impactFeedback.impactOccurred()
      
      try recipeService.toggleFavorite(recipe)
      
      // Trigger UI update to resort if favorites first is active
      objectWillChange.send()
    } catch {
      print("Error toggling favorite: \(error)")
    }
  }
  
  func deleteRecipe(_ recipe: RecipeModel) {
    do {
      try recipeService.deleteRecipe(recipe)
    } catch {
      print("Error deleting recipe: \(error)")
    }
  }
  
  func clearFilters() {
    searchText = ""
    selectedRecipeType = nil
  }
  
  func refresh() {
    recipeService.fetchRecipes()
  }
  
  func logout() {
    authService.logout()
  }
  
  func deleteAccount() {
    authService.deleteAccount()
  }
}
