//
//  AddRecipeView.swift
//  recipe_app
//
//  Created by Nik Uzair on 15/08/2025.
//

import SwiftUI
import PhotosUI

struct AddRecipeView: View {
  @StateObject private var viewModel: AddRecipeViewModel
  @Environment(\.dismiss) private var dismiss
  @FocusState private var focusedField: Field?
  
  init(recipeService: RecipeService) {
    _viewModel = StateObject(wrappedValue: AddRecipeViewModel(recipeService: recipeService))
  }
  
  enum Field: Hashable {
    case recipeName
    case ingredient(Int)
    case step(Int)
  }
  
  var body: some View {
    NavigationView {
      Form {
        recipeInfoSection
        recipeTypeSection
        imageSection
        ingredientsSection
        stepsSection
        timingSection
      }
      .navigationTitle("New Recipe")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            dismiss()
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Save") {
            Task {
              if await viewModel.saveRecipe() {
                dismiss()
              }
            }
          }
          .fontWeight(.semibold)
          .disabled(!viewModel.isFormValid || viewModel.isLoading)
        }
        
        ToolbarItem(placement: .keyboard) {
          HStack {
            Spacer()
            Button("Done") {
              hideKeyboard()
            }
          }
        }
      }
      .alert("Error", isPresented: $viewModel.showError) {
        Button("OK") { }
      } message: {
        Text(viewModel.errorMessage)
      }
      .interactiveDismissDisabled(viewModel.isLoading)
      .overlay {
        if viewModel.isLoading {
          Color.black.opacity(0.3)
            .ignoresSafeArea()
            .overlay {
              ProgressView("Saving...")
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
            }
        }
      }
    }
  }
  
  private var recipeInfoSection: some View {
    Section("Recipe Information") {
      TextField("Recipe Name", text: $viewModel.recipeName)
        .focused($focusedField, equals: .recipeName)
        .submitLabel(.next)
        .onSubmit {
          focusedField = .ingredient(0)
        }
    }
  }
  
  private var recipeTypeSection: some View {
    Section("Category") {
      HStack {
        Text("Recipe Type")
        Spacer()
        Menu {
          ForEach(viewModel.recipeTypes) { type in
            Button(action: {
              viewModel.selectedRecipeType = type
            }) {
              HStack {
                if viewModel.selectedRecipeType?.id == type.id {
                  Image(systemName: "checkmark")
                    .foregroundColor(.blue)
                }
                Label(type.displayName, systemImage: type.iconName)
                  .foregroundColor(viewModel.selectedRecipeType?.id == type.id ? .blue : .primary)
              }
            }
          }
        } label: {
          if let selectedType = viewModel.selectedRecipeType {
            HStack(spacing: 6) {
              Image(systemName: selectedType.iconName)
              Text(selectedType.displayName)
              Image(systemName: "chevron.up.chevron.down")
                .font(.caption)
            }
            .foregroundColor(.blue)
          } else {
            Text("Select Type")
              .foregroundColor(.gray)
          }
        }
      }
    }
  }
  
  private var imageSection: some View {
    Section("Recipe Image") {
      VStack {
        if let image = viewModel.recipeImage {
          image
            .resizable()
            .scaledToFill()
            .frame(height: 200)
            .clipped()
            .cornerRadius(10)
            .overlay(alignment: .topTrailing) {
              Button(action: {
                viewModel.recipeImage = nil
                viewModel.recipeImageData = nil
                viewModel.selectedImage = nil
              }) {
                Image(systemName: "xmark.circle.fill")
                  .font(.title2)
                  .foregroundColor(.white)
                  .background(Circle().fill(Color.black.opacity(0.5)))
              }
              .padding(8)
            }
        }
        
        PhotosPicker(
          selection: $viewModel.selectedImage,
          matching: .images,
          photoLibrary: .shared()
        ) {
          Label(
            viewModel.recipeImage == nil ? "Select Image" : "Change Image",
            systemImage: "photo"
          )
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.blue.opacity(0.1))
          .foregroundColor(.blue)
          .cornerRadius(8)
        }
        .onChange(of: viewModel.selectedImage) { _ in
          Task {
            await viewModel.loadImage()
          }
        }
      }
    }
  }
  
  private var ingredientsSection: some View {
    Section {
      ForEach(viewModel.ingredients.indices, id: \.self) { index in
        HStack {
          TextField("Ingredient \(index + 1)", text: $viewModel.ingredients[index])
            .focused($focusedField, equals: .ingredient(index))
            .submitLabel(.next)
            .onSubmit {
              if index == viewModel.ingredients.count - 1 {
                viewModel.addIngredient()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                  focusedField = .ingredient(index + 1)
                }
              } else {
                focusedField = .ingredient(index + 1)
              }
            }
          
          if viewModel.ingredients.count > 1 {
            Button(action: {
              viewModel.removeIngredient(at: index)
            }) {
              Image(systemName: "minus.circle.fill")
                .foregroundColor(.red)
            }
          }
        }
      }
      
      Button(action: {
        viewModel.addIngredient()
      }) {
        Label("Add Ingredient", systemImage: "plus.circle.fill")
          .foregroundColor(.blue)
      }
    } header: {
      Text("Ingredients")
    } footer: {
      Text("Add at least one ingredient")
        .font(.caption)
        .foregroundColor(.secondary)
    }
  }
  
  private var stepsSection: some View {
    Section {
      ForEach(viewModel.steps.indices, id: \.self) { index in
        HStack(alignment: .top, spacing: 12) {
          Text("\(index + 1).")
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
            .frame(width: 25, alignment: .center)
          
          VStack {
            TextField("Step \(index + 1)", text: $viewModel.steps[index], axis: .vertical)
              .lineLimit(1...)
              .textFieldStyle(.plain)
              .focused($focusedField, equals: .step(index))
              .submitLabel(.next)
              .onSubmit {
                if index == viewModel.steps.count - 1 {
                  viewModel.addStep()
                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    focusedField = .step(index + 1)
                  }
                } else {
                  focusedField = .step(index + 1)
                }
              }
          }
          .frame(maxWidth: .infinity)
          
          if viewModel.steps.count > 1 {
            Button(action: {
              viewModel.removeStep(at: index)
            }) {
              Image(systemName: "minus.circle.fill")
                .foregroundColor(.red)
            }
          }
        }
        .padding(.vertical, 4)
      }
      
      Button(action: {
        viewModel.addStep()
      }) {
        Label("Add Step", systemImage: "plus.circle.fill")
          .foregroundColor(.blue)
      }
    } header: {
      Text("Instructions")
    } footer: {
      Text("Add step-by-step instructions")
        .font(.caption)
        .foregroundColor(.secondary)
    }
  }
  
  private var timingSection: some View {
    Section("Details") {
      Menu {
        ForEach([5, 10, 15, 20, 25, 30, 45, 60, 90, 120], id: \.self) { time in
          Button(action: {
            viewModel.prepTime = time
          }) {
            if time < 60 {
              Text("\(time) min")
            } else {
              let hours = time / 60
              let minutes = time % 60
              if minutes == 0 {
                Text("\(hours) hr")
              } else {
                Text("\(hours) hr \(minutes) min")
              }
            }
          }
        }
      } label: {
        HStack {
          Label("Prep Time", systemImage: "clock")
            .foregroundColor(.primary)
          Spacer()
          Text(viewModel.prepTime < 60 ? "\(viewModel.prepTime) min" : (viewModel.prepTime % 60 == 0 ? "\(viewModel.prepTime / 60) hr" : "\(viewModel.prepTime / 60) hr \(viewModel.prepTime % 60) min"))
            .foregroundColor(.secondary)
          Image(systemName: "chevron.up.chevron.down")
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
      
      Menu {
        ForEach(1...12, id: \.self) { serving in
          Button(action: {
            viewModel.servings = serving
          }) {
            Text("\(serving)")
          }
        }
      } label: {
        HStack {
          Label("Servings", systemImage: "person.2")
            .foregroundColor(.primary)
          Spacer()
          Text("\(viewModel.servings)")
            .foregroundColor(.secondary)
          Image(systemName: "chevron.up.chevron.down")
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
    }
  }
  
  private func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}

