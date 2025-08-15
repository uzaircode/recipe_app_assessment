//
//  ContentView.swift
//  recipe_app
//
//  Created by Nik Uzair on 15/08/2025.
//

import SwiftUI

struct MainView: View {
  @EnvironmentObject var authService: AuthenticationService
  @EnvironmentObject var recipeService: RecipeService
  
  var body: some View {
    if authService.isAuthenticated {
      RecipeListView(
        recipeService: recipeService,
        authService: authService
      )
    } else {
      LoginView(authService: authService)
    }
  }
}
