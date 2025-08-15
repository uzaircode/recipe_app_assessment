//
//  RecipeListView.swift
//  recipe_app
//
//  Created by Nik Uzair on 15/08/2025.
//

import SwiftUI

struct RecipeListView: View {
  @StateObject private var viewModel: RecipeListViewModel
  @State private var selectedRecipe: RecipeModel?
  @State private var showingProfile = false
  @State private var showingDeleteConfirmation = false
  @State private var recipeToDelete: RecipeModel?
  @State private var showingAccountDeleteConfirmation = false
  
  init(recipeService: RecipeService, authService: AuthenticationService) {
    _viewModel = StateObject(wrappedValue: RecipeListViewModel(
      recipeService: recipeService,
      authService: authService
    ))
  }
  
  var body: some View {
    NavigationView {
      ZStack {
        if viewModel.recipes.isEmpty && !viewModel.isLoading {
          emptyStateView
        } else {
          recipeList
        }
      }
      .navigationTitle("Recipes")
      .toolbar {
        toolbarContent
      }
      .searchable(text: $viewModel.searchText, prompt: "Search recipes or ingredients")
      .refreshable {
        viewModel.refresh()
      }
      .sheet(isPresented: $viewModel.showingAddRecipe) {
        AddRecipeView(recipeService: viewModel.recipeService)
      }
      .sheet(isPresented: $viewModel.showingFilterSheet) {
        filterSheet
      }
      .sheet(item: $selectedRecipe) { recipe in
        RecipeDetailView(
          recipe: recipe,
          recipeService: viewModel.recipeService
        )
      }
      .sheet(isPresented: $showingProfile) {
        profileView
      }
      .alert("Delete Recipe", isPresented: $showingDeleteConfirmation) {
        Button("Cancel", role: .cancel) { }
        Button("Delete", role: .destructive) {
          if let recipe = recipeToDelete {
            viewModel.deleteRecipe(recipe)
          }
        }
      } message: {
        Text("Are you sure you want to delete this recipe?\n\nThis action is permanent and cannot be undone.")
      }
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
  
  private var recipeList: some View {
    List {
      if let selectedType = viewModel.selectedRecipeType {
        Section {
          HStack {
            Label(selectedType.displayName, systemImage: selectedType.iconName)
              .font(.subheadline)
              .foregroundColor(.blue)
            
            Spacer()
            
            Button("Clear") {
              withAnimation {
                viewModel.selectedRecipeType = nil
              }
            }
            .font(.caption)
          }
          .padding(.vertical, 4)
        }
      }
      
      ForEach(viewModel.recipes) { recipe in
        RecipeRowView(
          recipe: recipe,
          recipeType: viewModel.recipeService.getRecipeType(for: recipe.typeId),
          onToggleFavorite: {
            viewModel.toggleFavorite(recipe)
          }
        )
        .contentShape(Rectangle())
        .onTapGesture {
          selectedRecipe = recipe
        }
        .listRowSeparator(.visible)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
          Button(role: .destructive) {
            recipeToDelete = recipe
            showingDeleteConfirmation = true
          } label: {
            Label("Delete", systemImage: "trash")
          }
          
          Button {
            viewModel.toggleFavorite(recipe)
          } label: {
            Label(
              recipe.isFavorite ? "Unfavorite" : "Favorite",
              systemImage: recipe.isFavorite ? "star.slash" : "star"
            )
          }
          .tint(recipe.isFavorite ? .gray : .yellow)
        }
      }
    }
    .listStyle(PlainListStyle())
  }
  
  private var emptyStateView: some View {
    VStack(spacing: 20) {
      Image(systemName: "fork.knife.circle")
        .font(.system(size: 80))
        .foregroundColor(.gray.opacity(0.5))
      
      Text("No Recipes Yet")
        .font(.title2)
        .fontWeight(.semibold)
      
      Text("Add your first recipe to get started")
        .font(.subheadline)
        .foregroundColor(.secondary)
      
      Button(action: {
        viewModel.showingAddRecipe = true
      }) {
        Label("Add Recipe", systemImage: "plus.circle.fill")
          .font(.headline)
          .padding()
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(10)
      }
    }
    .padding()
  }
  
  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarItem(placement: .navigationBarLeading) {
      Button(action: {
        showingProfile = true
      }) {
        Image(systemName: "person.circle")
      }
    }
    
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      Button(action: {
        viewModel.showingFilterSheet = true
      }) {
        ZStack(alignment: .topTrailing) {
          Image(systemName: "line.3.horizontal.decrease.circle")
          
          if viewModel.filterBadgeCount > 0 {
            Circle()
              .fill(Color.red)
              .frame(width: 10, height: 10)
              .offset(x: 8, y: -8)
          }
        }
      }
      
      Button(action: {
        viewModel.showingAddRecipe = true
      }) {
        Image(systemName: "plus")
      }
    }
  }
  
  private var filterSheet: some View {
    NavigationView {
      Form {
        Section("Recipe Type") {
          ForEach(viewModel.recipeTypes) { type in
            Button(action: {
              withAnimation {
                if viewModel.selectedRecipeType?.id == type.id {
                  viewModel.selectedRecipeType = nil
                } else {
                  viewModel.selectedRecipeType = type
                }
              }
            }) {
              HStack {
                Label(type.displayName, systemImage: type.iconName)
                  .foregroundColor(.primary)
                
                Spacer()
                
                if viewModel.selectedRecipeType?.id == type.id {
                  Image(systemName: "checkmark")
                    .foregroundColor(.blue)
                }
              }
            }
          }
        }
        
        Section("Sort By") {
          ForEach(RecipeListViewModel.SortOption.allCases, id: \.self) { option in
            Button(action: {
              withAnimation {
                viewModel.sortOption = option
              }
            }) {
              HStack {
                Label(option.rawValue, systemImage: option.systemImage)
                  .foregroundColor(.primary)
                
                Spacer()
                
                if viewModel.sortOption == option {
                  Image(systemName: "checkmark")
                    .foregroundColor(.blue)
                }
              }
            }
          }
        }
        
        if viewModel.filterBadgeCount > 0 {
          Section {
            Button("Clear All Filters") {
              viewModel.clearFilters()
            }
            .foregroundColor(.red)
          }
        }
      }
      .navigationTitle("Filter & Sort")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Done") {
            viewModel.showingFilterSheet = false
          }
        }
      }
    }
  }
  
  private var profileView: some View {
    ProfileView(
      authService: viewModel.authService,
      onLogout: {
        showingProfile = false
        viewModel.logout()
      },
      onDeleteAccount: {
        showingProfile = false
        viewModel.deleteAccount()
      }
    )
  }
}
