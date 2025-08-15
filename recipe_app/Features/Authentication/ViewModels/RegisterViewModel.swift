//
//  RegisterViewModel.swift
//  recipe_app
//
//  Created by Nik Uzair on 15/08/2025.
//

import Foundation
import SwiftUI

@MainActor
class RegisterViewModel: ObservableObject {
  @Published var username = ""
  @Published var password = ""
  @Published var isLoading = false
  @Published var errorMessage: String?
  @Published var showError = false
  @Published var registrationSuccessful = false
  
  private let authService: AuthenticationService
  
  init(authService: AuthenticationService) {
    self.authService = authService
  }
  
  var isFormValid: Bool {
    !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
    password.count >= 6
  }
  
  func clearError() {
    errorMessage = nil
    showError = false
  }
  
  func register() async {
    guard isFormValid else {
      errorMessage = "Please enter a valid username and password (minimum 6 characters)"
      showError = true
      return
    }
    
    isLoading = true
    clearError()
    
    do {
      try await authService.register(
        username: username.trimmingCharacters(in: .whitespacesAndNewlines),
        password: password
      )
      
      registrationSuccessful = true
    } catch {
      errorMessage = error.localizedDescription
      showError = true
    }
    
    isLoading = false
  }
}
