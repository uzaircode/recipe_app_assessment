//
//  RecipeDetailViewModel.swift
//  recipe_app
//
//  Created by Nik Uzair on 15/08/2025.
//

import Foundation
import SwiftUI
import PhotosUI
import CoreData
import UIKit

@MainActor
class RecipeDetailViewModel: ObservableObject {
  @Published var recipe: RecipeModel
  @Published var isEditMode = false
  @Published var editedName: String
  @Published var editedRecipeType: RecipeTypeModel?
  @Published var editedIngredients: [String]
  @Published var editedSteps: [String]
  @Published var editedPrepTime: Int
  @Published var editedServings: Int
  @Published var selectedImage: PhotosPickerItem?
  @Published var editedImage: Image?
  @Published var editedImageData: Data?
  @Published var showDeleteAlert = false
  @Published var showError = false
  @Published var errorMessage = ""
  @Published var isLoading = false
  
  private let recipeService: RecipeService
  let onDelete: (() -> Void)?
  
  init(recipe: RecipeModel, recipeService: RecipeService, onDelete: (() -> Void)? = nil) {
    self.recipe = recipe
    self.recipeService = recipeService
    self.onDelete = onDelete
    
    self.editedName = recipe.name
    self.editedRecipeType = recipeService.getRecipeType(for: recipe.typeId)
    self.editedIngredients = recipe.ingredients.isEmpty ? [""] : recipe.ingredients
    self.editedSteps = recipe.steps.isEmpty ? [""] : recipe.steps
    self.editedPrepTime = recipe.prepTime
    self.editedServings = recipe.servings
    self.editedImage = recipe.image
    self.editedImageData = recipe.imageData
  }
  
  var recipeType: RecipeTypeModel? {
    recipeService.getRecipeType(for: recipe.typeId)
  }
  
  var recipeTypes: [RecipeTypeModel] {
    recipeService.recipeTypes
  }
  
  var displayImage: Image? {
    isEditMode ? editedImage : recipe.image
  }
  
  var isFormValid: Bool {
    !editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
    editedRecipeType != nil &&
    editedIngredients.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } &&
    editedSteps.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
  }
  
  func toggleEditMode() {
    withAnimation {
      if isEditMode {
        cancelEdit()
      } else {
        startEdit()
      }
    }
  }
  
  private func startEdit() {
    editedName = recipe.name
    editedRecipeType = recipeService.getRecipeType(for: recipe.typeId)
    editedIngredients = recipe.ingredients.isEmpty ? [""] : recipe.ingredients
    editedSteps = recipe.steps.isEmpty ? [""] : recipe.steps
    editedPrepTime = recipe.prepTime
    editedServings = recipe.servings
    editedImage = recipe.image
    editedImageData = recipe.imageData
    isEditMode = true
  }
  
  private func cancelEdit() {
    isEditMode = false
    selectedImage = nil
  }
  
  func saveChanges() async -> Bool {
    guard isFormValid else {
      errorMessage = "Please fill in all required fields"
      showError = true
      return false
    }
    
    isLoading = true
    
    let filteredIngredients = editedIngredients
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
    
    let filteredSteps = editedSteps
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
    
    var updatedRecipe = recipe
    updatedRecipe.name = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
    updatedRecipe.typeId = editedRecipeType?.id ?? ""
    updatedRecipe.ingredients = filteredIngredients
    updatedRecipe.steps = filteredSteps
    updatedRecipe.prepTime = editedPrepTime
    updatedRecipe.servings = editedServings
    updatedRecipe.imageData = editedImageData
    
    do {
      try recipeService.updateRecipe(updatedRecipe)
      self.recipe = updatedRecipe
      isEditMode = false
      isLoading = false
      return true
    } catch {
      errorMessage = error.localizedDescription
      showError = true
      isLoading = false
      return false
    }
  }
  
  func deleteRecipe() {
    do {
      try recipeService.deleteRecipe(recipe)
      onDelete?()
    } catch {
      errorMessage = error.localizedDescription
      showError = true
    }
  }
  
  func toggleFavorite() {
    do {
      // Add haptic feedback
      let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
      impactFeedback.impactOccurred()
      
      try recipeService.toggleFavorite(recipe)
      recipe.isFavorite.toggle()
    } catch {
      errorMessage = error.localizedDescription
      showError = true
    }
  }
  
  func addIngredient() {
    editedIngredients.append("")
  }
  
  func removeIngredient(at index: Int) {
    guard editedIngredients.count > 1 else { return }
    editedIngredients.remove(at: index)
  }
  
  func addStep() {
    editedSteps.append("")
  }
  
  func removeStep(at index: Int) {
    guard editedSteps.count > 1 else { return }
    editedSteps.remove(at: index)
  }
  
  func loadImage() async {
    guard let selectedImage = selectedImage else { return }
    
    do {
      if let data = try await selectedImage.loadTransferable(type: Data.self) {
        if let uiImage = UIImage(data: data) {
          self.editedImage = Image(uiImage: uiImage)
          self.editedImageData = uiImage.jpegData(compressionQuality: 0.8)
        }
      }
    } catch {
      print("Error loading image: \(error)")
    }
  }
  
  func shareRecipe() -> String {
    var shareText = "Check out this recipe: \(recipe.name)\n\n"
    
    if let type = recipeType {
      shareText += "Category: \(type.displayName)\n"
    }
    
    shareText += "Prep Time: \(recipe.prepTime) minutes\n"
    shareText += "Servings: \(recipe.servings)\n\n"
    
    shareText += "Ingredients:\n"
    for (index, ingredient) in recipe.ingredients.enumerated() {
      shareText += "\(index + 1). \(ingredient)\n"
    }
    
    shareText += "\nInstructions:\n"
    for (index, step) in recipe.steps.enumerated() {
      shareText += "\(index + 1). \(step)\n"
    }
    
    return shareText
  }
}

