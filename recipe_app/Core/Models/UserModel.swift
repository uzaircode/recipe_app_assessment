//
//  UserModel.swift
//  recipe_app
//
//  Created by Nik Uzair on 15/08/2025.
//

import Foundation
import CoreData

struct UserModel {
  let id: UUID
  var username: String
  var passwordHash: String
  var token: String?
  let createdAt: Date
  var lastLogin: Date?
  var profileImageData: Data?
  
  init(id: UUID = UUID(),
       username: String,
       passwordHash: String,
       token: String? = nil,
       createdAt: Date = Date(),
       lastLogin: Date? = nil,
       profileImageData: Data? = nil) {
    self.id = id
    self.username = username
    self.passwordHash = passwordHash
    self.token = token
    self.createdAt = createdAt
    self.lastLogin = lastLogin
    self.profileImageData = profileImageData
  }
  
  init(from entity: User) {
    self.id = entity.id ?? UUID()
    self.username = entity.username ?? ""
    self.passwordHash = entity.passwordHash ?? ""
    self.token = entity.token
    self.createdAt = entity.createdAt ?? Date()
    self.lastLogin = entity.lastLogin
    self.profileImageData = entity.profileImageData
  }
  
  func toEntity(context: NSManagedObjectContext) -> User {
    let entity = User(context: context)
    entity.id = self.id
    entity.username = self.username
    entity.passwordHash = self.passwordHash
    entity.token = self.token
    entity.createdAt = self.createdAt
    entity.lastLogin = self.lastLogin
    entity.profileImageData = self.profileImageData
    return entity
  }
  
  mutating func updateEntity(_ entity: User) {
    entity.username = self.username
    entity.passwordHash = self.passwordHash
    entity.token = self.token
    entity.lastLogin = self.lastLogin
    entity.profileImageData = self.profileImageData
  }
}
