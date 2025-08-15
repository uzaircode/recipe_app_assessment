//
//  ContentView.swift
//  recipe_app
//
//  Created by Nik Uzair on 15/08/2025.
//

import SwiftUI

struct MainView: View {
  @EnvironmentObject var authService: AuthenticationService
  
  var body: some View {
    if authService.isAuthenticated {
      RecipeListView()
    } else {
      LoginView(authService: authService)
    }
  }
}
