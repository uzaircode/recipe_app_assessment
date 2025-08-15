//
//  AuthenticationService.swift
//  recipe_app
//
//  Created by Nik Uzair on 15/08/2025.
//

import Foundation
import CoreData
import CryptoKit

enum AuthenticationError: LocalizedError {
  case invalidCredentials
  case userNotFound
  case userAlreadyExists
  case tokenExpired
  case unknown
  
  var errorDescription: String? {
    switch self {
    case .invalidCredentials:
      return "Invalid username or password"
    case .userNotFound:
      return "User not found"
    case .userAlreadyExists:
      return "Username already exists"
    case .tokenExpired:
      return "Session has expired"
    case .unknown:
      return "An unknown error occurred"
    }
  }
}

@MainActor
class AuthenticationService: ObservableObject {
  @Published private(set) var currentUser: UserModel?
  @Published private(set) var isAuthenticated = false
  
  private let viewContext: NSManagedObjectContext
  private let keychainKey = "com.recipe.authToken"
  
  init(viewContext: NSManagedObjectContext) {
    self.viewContext = viewContext
  }
  
  private func hashPassword(_ password: String) -> String {
    let inputData = Data(password.utf8)
    let hashed = SHA256.hash(data: inputData)
    return hashed.compactMap { String(format: "%02x", $0) }.joined()
  }
  
  private func generateToken() -> String {
    UUID().uuidString + "-" + String(Date().timeIntervalSince1970)
  }
  
  func updateProfileImage(_ imageData: Data?) {
    guard var user = currentUser else { return }
    
    user.profileImageData = imageData
    
    let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "id == %@", user.id as CVarArg)
    
    do {
      if let userEntity = try viewContext.fetch(fetchRequest).first {
        user.updateEntity(userEntity)
        try viewContext.save()
        currentUser = user
      }
    } catch {
      print("Error updating profile image: \(error)")
    }
  }
  
  private func saveTokenToKeychain(_ token: String) {
    let data = token.data(using: .utf8)!
    let query = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrAccount: keychainKey,
      kSecValueData: data
    ] as CFDictionary
    
    SecItemDelete(query)
    SecItemAdd(query, nil)
  }
  
  private func getTokenFromKeychain() -> String? {
    let query = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrAccount: keychainKey,
      kSecReturnData: true
    ] as CFDictionary
    
    var result: AnyObject?
    let status = SecItemCopyMatching(query, &result)
    
    if status == errSecSuccess,
       let data = result as? Data,
       let token = String(data: data, encoding: .utf8) {
      return token
    }
    return nil
  }
  
  private func removeTokenFromKeychain() {
    let query = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrAccount: keychainKey
    ] as CFDictionary
    
    SecItemDelete(query)
  }
  
  func checkForExistingSession() {
    guard let token = getTokenFromKeychain() else {
      isAuthenticated = false
      return
    }
    
    let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "token == %@", token)
    fetchRequest.fetchLimit = 1
    
    do {
      let users = try viewContext.fetch(fetchRequest)
      if let user = users.first {
        self.currentUser = UserModel(from: user)
        self.isAuthenticated = true
        
        user.lastLogin = Date()
        try viewContext.save()
        
      } else {
        removeTokenFromKeychain()
        isAuthenticated = false
      }
    } catch {
      print("Error checking session: \(error)")
      isAuthenticated = false
    }
  }
  
  func login(username: String, password: String) async throws {
    let hashedPassword = hashPassword(password)
    
    let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "username == %@", username)
    fetchRequest.fetchLimit = 1
    
    let users = try viewContext.fetch(fetchRequest)
    
    guard let user = users.first else {
      throw AuthenticationError.userNotFound
    }
    
    guard user.passwordHash == hashedPassword else {
      throw AuthenticationError.invalidCredentials
    }
    
    let token = generateToken()
    user.token = token
    user.lastLogin = Date()
    
    try viewContext.save()
    
    saveTokenToKeychain(token)
    
    self.currentUser = UserModel(from: user)
    self.isAuthenticated = true
    
  }
  
  func register(username: String, password: String) async throws {
    let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "username == %@", username)
    fetchRequest.fetchLimit = 1
    
    let existingUsers = try viewContext.fetch(fetchRequest)
    
    guard existingUsers.isEmpty else {
      throw AuthenticationError.userAlreadyExists
    }
    
    let hashedPassword = hashPassword(password)
    let token = generateToken()
    
    let newUser = User(context: viewContext)
    newUser.id = UUID()
    newUser.username = username
    newUser.passwordHash = hashedPassword
    newUser.token = token
    newUser.createdAt = Date()
    newUser.lastLogin = Date()
    
    try viewContext.save()
    
    saveTokenToKeychain(token)
    
    self.currentUser = UserModel(from: newUser)
    self.isAuthenticated = true
    
    if let userId = newUser.id {
      print("AuthService: New user registered with ID: \(userId)")
    }
  }
  
  func logout() {
    if let currentUser = currentUser {
      let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
      fetchRequest.predicate = NSPredicate(format: "id == %@", currentUser.id as CVarArg)
      fetchRequest.fetchLimit = 1
      
      do {
        let users = try viewContext.fetch(fetchRequest)
        if let user = users.first {
          user.token = nil
          try viewContext.save()
        }
      } catch {
        print("Error during logout: \(error)")
      }
    }
    
    removeTokenFromKeychain()
    self.currentUser = nil
    self.isAuthenticated = false
    
  }
  
  func deleteAccount() {
    guard let currentUser = currentUser else { return }
    
    // Then delete the user account
    let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
    userFetchRequest.predicate = NSPredicate(format: "id == %@", currentUser.id as CVarArg)
    userFetchRequest.fetchLimit = 1
    
    do {
      let users = try viewContext.fetch(userFetchRequest)
      if let user = users.first {
        viewContext.delete(user)
        try viewContext.save()
        print("Account deleted successfully for user: \(currentUser.username)")
      }
    } catch {
      print("Error deleting account: \(error)")
    }
    
    // Finally, logout
    removeTokenFromKeychain()
    self.currentUser = nil
    self.isAuthenticated = false
  }
}
