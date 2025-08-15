//
//  DependencyContainer.swift
//  recipe_app
//
//  Created by Nik Uzair on 15/08/2025.
//

import Foundation
import SwiftUI
import CoreData

@MainActor
protocol DependencyContainerProtocol {
  var persistenceController: PersistenceController { get }
  var authService: AuthenticationService { get }
}

@MainActor
class DependencyContainer: ObservableObject, DependencyContainerProtocol {
  static let shared = DependencyContainer()
  
  let persistenceController: PersistenceController
  let authService: AuthenticationService
  
  private init() {
    self.persistenceController = PersistenceController.shared
    let viewContext = persistenceController.container.viewContext
    
    self.authService = AuthenticationService(viewContext: viewContext)
  }
  
  func makeLoginViewModel() -> LoginViewModel {
    LoginViewModel(authService: authService)
  }
}
