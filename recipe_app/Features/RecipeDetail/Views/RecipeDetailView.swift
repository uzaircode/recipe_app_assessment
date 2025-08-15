//
//  RecipeDetailView.swift
//  recipe_app
//
//  Created by Nik Uzair on 15/08/2025.
//

import SwiftUI
import PhotosUI

struct RecipeDetailView: View {
  @StateObject private var viewModel: RecipeDetailViewModel
  @Environment(\.dismiss) private var dismiss
  @State private var showShareSheet = false
  @FocusState private var focusedField: AddRecipeView.Field?
  
  init(recipe: RecipeModel, recipeService: RecipeService) {
    _viewModel = StateObject(wrappedValue: RecipeDetailViewModel(
      recipe: recipe,
      recipeService: recipeService,
      onDelete: nil
    ))
  }
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 0) {
          if viewModel.isEditMode {
            editModeContent
          } else {
            viewModeContent
          }
        }
      }
      .onTapGesture {
        if viewModel.isEditMode {
          focusedField = nil
        }
      }
      .navigationTitle(viewModel.isEditMode ? "Edit Recipe" : viewModel.recipe.name)
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        toolbarContent
      }
      .alert("Delete Recipe", isPresented: $viewModel.showDeleteAlert) {
        Button("Cancel", role: .cancel) { }
        Button("Delete", role: .destructive) {
          viewModel.deleteRecipe()
          dismiss()
        }
      } message: {
        Text("Are you sure you want to delete this recipe? This action cannot be undone.")
      }
      .alert("Error", isPresented: $viewModel.showError) {
        Button("OK") { }
      } message: {
        Text(viewModel.errorMessage)
      }
      .sheet(isPresented: $showShareSheet) {
        ShareSheet(items: [viewModel.shareRecipe()])
      }
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
  
  @ViewBuilder
  private var viewModeContent: some View {
    VStack(spacing: 0) {
      if let image = viewModel.displayImage {
        image
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(height: 300)
          .clipped()
      } else {
        Rectangle()
          .fill(LinearGradient(
            gradient: Gradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.3)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ))
          .frame(height: 300)
          .overlay {
            Image(systemName: "photo")
              .font(.system(size: 60))
              .foregroundColor(.gray)
          }
      }
      
      VStack(alignment: .leading, spacing: 20) {
        recipeInfoView
        ingredientsView
        stepsView
      }
      .padding()
    }
  }
  
  @ViewBuilder
  private var editModeContent: some View {
    VStack(alignment: .leading, spacing: 20) {
      editImageSection
      editBasicInfoSection
      editIngredientsSection
      editStepsSection
      editDetailsSection
    }
    .padding()
  }
  
  private var recipeInfoView: some View {
    VStack(alignment: .leading, spacing: 12) {
      if let type = viewModel.recipeType {
        HStack {
          Label(type.displayName, systemImage: type.iconName)
            .font(.subheadline)
            .foregroundColor(.secondary)
          
          Spacer()
          
          Button(action: {
            viewModel.toggleFavorite()
          }) {
            Image(systemName: viewModel.recipe.isFavorite ? "star.fill" : "star")
              .font(.title2)
              .foregroundColor(viewModel.recipe.isFavorite ? .yellow : .gray)
          }
        }
      }
      
      HStack(spacing: 20) {
        Label("\(viewModel.recipe.prepTime) min", systemImage: "clock")
        Label("\(viewModel.recipe.servings) servings", systemImage: "person.2")
      }
      .font(.subheadline)
      .foregroundColor(.secondary)
    }
  }
  
  private var ingredientsView: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Ingredients")
        .font(.title2)
        .fontWeight(.bold)
      
      VStack(alignment: .leading, spacing: 8) {
        ForEach(Array(viewModel.recipe.ingredients.enumerated()), id: \.offset) { index, ingredient in
          HStack(alignment: .top, spacing: 12) {
            Image(systemName: "circle.fill")
              .font(.system(size: 6))
              .foregroundColor(.secondary)
              .padding(.top, 6)
            
            Text(ingredient)
              .font(.body)
            
            Spacer()
          }
        }
      }
    }
  }
  
  private var stepsView: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Instructions")
        .font(.title2)
        .fontWeight(.bold)
      
      VStack(alignment: .leading, spacing: 16) {
        ForEach(Array(viewModel.recipe.steps.enumerated()), id: \.offset) { index, step in
          HStack(alignment: .top, spacing: 12) {
            Text("\(index + 1)")
              .font(.headline)
              .foregroundColor(.white)
              .frame(width: 28, height: 28)
              .background(Circle().fill(Color.blue))
            
            Text(step)
              .font(.body)
              .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
          }
        }
      }
    }
  }
  
  private var editImageSection: some View {
    VStack {
      if let image = viewModel.editedImage {
        image
          .resizable()
          .scaledToFill()
          .frame(height: 200)
          .clipped()
          .cornerRadius(10)
          .overlay(alignment: .topTrailing) {
            Button(action: {
              viewModel.editedImage = nil
              viewModel.editedImageData = nil
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
          viewModel.editedImage == nil ? "Add Image" : "Change Image",
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
  
  private var editBasicInfoSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Recipe Name")
        .font(.headline)
      TextField("Recipe Name", text: $viewModel.editedName)
        .textFieldStyle(RoundedBorderTextFieldStyle())
      
      Text("Category")
        .font(.headline)
        .padding(.top, 8)
      Picker("Recipe Type", selection: $viewModel.editedRecipeType) {
        ForEach(viewModel.recipeTypes) { type in
          Label(type.displayName, systemImage: type.iconName)
            .tag(type as RecipeTypeModel?)
        }
      }
      .pickerStyle(MenuPickerStyle())
      .padding(.vertical, 8)
      .padding(.horizontal, 12)
      .background(Color(.systemGray6))
      .cornerRadius(8)
    }
  }
  
  private var editIngredientsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Ingredients")
        .font(.headline)
      
      ForEach(viewModel.editedIngredients.indices, id: \.self) { index in
        HStack {
          TextField("Ingredient \(index + 1)", text: $viewModel.editedIngredients[index])
            .textFieldStyle(RoundedBorderTextFieldStyle())
          
          if viewModel.editedIngredients.count > 1 {
            Button(action: {
              viewModel.removeIngredient(at: index)
            }) {
              Image(systemName: "minus.circle.fill")
                .foregroundColor(.red)
            }
          }
        }
      }
      
      Button(action: viewModel.addIngredient) {
        Label("Add Ingredient", systemImage: "plus.circle.fill")
          .foregroundColor(.blue)
      }
    }
  }
  
  private var editStepsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Instructions")
        .font(.headline)
      
      ForEach(viewModel.editedSteps.indices, id: \.self) { index in
        HStack(alignment: .top) {
          Text("\(index + 1).")
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
            .frame(width: 25, alignment: .center)
            .padding(.top, 8)
          
          TextField("Step \(index + 1)", text: $viewModel.editedSteps[index], axis: .vertical)
            .lineLimit(1...)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .foregroundColor(.primary)
          
          if viewModel.editedSteps.count > 1 {
            Button(action: {
              viewModel.removeStep(at: index)
            }) {
              Image(systemName: "minus.circle.fill")
                .foregroundColor(.red)
            }
            .padding(.top, 8)
          }
        }
      }
      
      Button(action: viewModel.addStep) {
        Label("Add Step", systemImage: "plus.circle.fill")
          .foregroundColor(.blue)
      }
    }
  }
  
  private var editDetailsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Details")
        .font(.headline)
      
      Menu {
        ForEach([5, 10, 15, 20, 25, 30, 45, 60, 90, 120], id: \.self) { time in
          Button(action: {
            viewModel.editedPrepTime = time
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
          Text(viewModel.editedPrepTime < 60 ? "\(viewModel.editedPrepTime) min" : (viewModel.editedPrepTime % 60 == 0 ? "\(viewModel.editedPrepTime / 60) hr" : "\(viewModel.editedPrepTime / 60) hr \(viewModel.editedPrepTime % 60) min"))
            .foregroundColor(.secondary)
          Image(systemName: "chevron.up.chevron.down")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
      }
      
      Menu {
        ForEach(1...12, id: \.self) { serving in
          Button(action: {
            viewModel.editedServings = serving
          }) {
            Text("\(serving)")
          }
        }
      } label: {
        HStack {
          Label("Servings", systemImage: "person.2")
            .foregroundColor(.primary)
          Spacer()
          Text("\(viewModel.editedServings)")
            .foregroundColor(.secondary)
          Image(systemName: "chevron.up.chevron.down")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
      }
    }
  }
  
  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarItem(placement: .navigationBarLeading) {
      if !viewModel.isEditMode {
        Button("Done") {
          dismiss()
        }
      } else {
        Button("Cancel") {
          viewModel.toggleEditMode()
        }
      }
    }
    
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      if viewModel.isEditMode {
        Button("Save") {
          Task {
            if await viewModel.saveChanges() {
              viewModel.toggleEditMode()
            }
          }
        }
        .fontWeight(.semibold)
        .disabled(!viewModel.isFormValid)
      } else {
        Menu {
          Button(action: {
            viewModel.toggleEditMode()
          }) {
            Label("Edit", systemImage: "pencil")
          }
          
          Button(action: {
            showShareSheet = true
          }) {
            Label("Share", systemImage: "square.and.arrow.up")
          }
          
          Divider()
          
          Button(role: .destructive, action: {
            viewModel.showDeleteAlert = true
          }) {
            Label("Delete", systemImage: "trash")
          }
        } label: {
          Image(systemName: "ellipsis.circle")
        }
        .accessibilityIdentifier("moreMenu")
      }
    }
  }
}

struct ShareSheet: UIViewControllerRepresentable {
  let items: [Any]
  
  func makeUIViewController(context: Context) -> UIActivityViewController {
    UIActivityViewController(activityItems: items, applicationActivities: nil)
  }
  
  func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}

