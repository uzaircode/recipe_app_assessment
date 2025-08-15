//
//  AddRecipeViewModel.swift
//  recipe_app
//
//  Created by Nik Uzair on 15/08/2025.
//

import Foundation
import SwiftUI
import PhotosUI
import CoreData

@MainActor
class AddRecipeViewModel: ObservableObject {
  @Published var recipeName = ""
  @Published var selectedRecipeType: RecipeTypeModel?
  @Published var ingredients: [String] = [""]
  @Published var steps: [String] = [""]
  @Published var prepTime = 30
  @Published var servings = 4
  @Published var selectedImage: PhotosPickerItem?
  @Published var recipeImage: Image?
  @Published var recipeImageData: Data?
  @Published var isLoading = false
  @Published var showError = false
  @Published var errorMessage = ""
  
  private let recipeService: RecipeService
  
  init(recipeService: RecipeService) {
    self.recipeService = recipeService
    if !recipeService.recipeTypes.isEmpty {
      selectedRecipeType = recipeService.recipeTypes.first
    }
  }
  
  var recipeTypes: [RecipeTypeModel] {
    recipeService.recipeTypes
  }
  
  var isFormValid: Bool {
    !recipeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
    selectedRecipeType != nil &&
    ingredients.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } &&
    steps.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
  }
  
  func addIngredient() {
    ingredients.append("")
  }
  
  func removeIngredient(at index: Int) {
    guard ingredients.count > 1 else { return }
    ingredients.remove(at: index)
  }
  
  func addStep() {
    steps.append("")
  }
  
  func removeStep(at index: Int) {
    guard steps.count > 1 else { return }
    steps.remove(at: index)
  }
  
  func loadImage() async {
    guard let selectedImage = selectedImage else { return }
    
    do {
      if let data = try await selectedImage.loadTransferable(type: Data.self) {
        if let uiImage = UIImage(data: data) {
          self.recipeImage = Image(uiImage: uiImage)
          self.recipeImageData = uiImage.jpegData(compressionQuality: 0.8)
        }
      }
    } catch {
      print("Error loading image: \(error)")
    }
  }
  
  func saveRecipe() async -> Bool {
    guard isFormValid else {
      errorMessage = "Please fill in all required fields"
      showError = true
      return false
    }
    
    isLoading = true
    
    let filteredIngredients = ingredients
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
    
    let filteredSteps = steps
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
    
    let recipe = RecipeModel(
      name: recipeName.trimmingCharacters(in: .whitespacesAndNewlines),
      typeId: selectedRecipeType?.id ?? "",
      userId: nil, // Will be set by RecipeService
      imageData: recipeImageData,
      ingredients: filteredIngredients,
      steps: filteredSteps,
      prepTime: prepTime,
      servings: servings
    )
    
    do {
      try recipeService.addRecipe(recipe)
      isLoading = false
      return true
    } catch {
      errorMessage = error.localizedDescription
      showError = true
      isLoading = false
      return false
    }
  }
  
  func clearForm() {
    recipeName = ""
    selectedRecipeType = recipeService.recipeTypes.first
    ingredients = [""]
    steps = [""]
    prepTime = 30
    servings = 4
    selectedImage = nil
    recipeImage = nil
    recipeImageData = nil
  }
}

