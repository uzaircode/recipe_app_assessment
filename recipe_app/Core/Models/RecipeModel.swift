//
//  RecipeModel.swift
//  recipe_app
//
//  Created by Nik Uzair on 15/08/2025.
//

import Foundation
import SwiftUI
import CoreData

struct RecipeModel: Identifiable {
  let id: UUID
  var name: String
  var typeId: String
  var userId: UUID?
  var imageData: Data?
  var ingredients: [String]
  var steps: [String]
  var isFavorite: Bool
  var prepTime: Int
  var servings: Int
  let createdAt: Date
  var updatedAt: Date
  
  init(id: UUID = UUID(),
       name: String,
       typeId: String,
       userId: UUID? = nil,
       imageData: Data? = nil,
       ingredients: [String] = [],
       steps: [String] = [],
       isFavorite: Bool = false,
       prepTime: Int = 0,
       servings: Int = 1,
       createdAt: Date = Date(),
       updatedAt: Date = Date()) {
    self.id = id
    self.name = name
    self.typeId = typeId
    self.userId = userId
    self.imageData = imageData
    self.ingredients = ingredients
    self.steps = steps
    self.isFavorite = isFavorite
    self.prepTime = prepTime
    self.servings = servings
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
  
  init(from entity: Recipe) {
    self.id = entity.id ?? UUID()
    self.name = entity.name ?? ""
    self.typeId = entity.typeId ?? ""
    self.userId = entity.userId
    self.imageData = entity.imageData
    self.ingredients = entity.ingredients as? [String] ?? []
    self.steps = entity.steps as? [String] ?? []
    self.isFavorite = entity.isFavorite
    self.prepTime = Int(entity.prepTime)
    self.servings = Int(entity.servings)
    self.createdAt = entity.createdAt ?? Date()
    self.updatedAt = entity.updatedAt ?? Date()
  }
  
  func toEntity(context: NSManagedObjectContext) -> Recipe {
    let entity = Recipe(context: context)
    entity.id = self.id
    entity.name = self.name
    entity.typeId = self.typeId
    entity.userId = self.userId
    entity.imageData = self.imageData
    entity.ingredients = self.ingredients as NSArray
    entity.steps = self.steps as NSArray
    entity.isFavorite = self.isFavorite
    entity.prepTime = Int32(self.prepTime)
    entity.servings = Int32(self.servings)
    entity.createdAt = self.createdAt
    entity.updatedAt = self.updatedAt
    return entity
  }
  
  mutating func updateEntity(_ entity: Recipe) {
    entity.name = self.name
    entity.typeId = self.typeId
    entity.userId = self.userId
    entity.imageData = self.imageData
    entity.ingredients = self.ingredients as NSArray
    entity.steps = self.steps as NSArray
    entity.isFavorite = self.isFavorite
    entity.prepTime = Int32(self.prepTime)
    entity.servings = Int32(self.servings)
    entity.updatedAt = Date()
    self.updatedAt = Date()
  }
  
  var image: Image? {
    guard let imageData = imageData,
          let uiImage = UIImage(data: imageData) else {
      return nil
    }
    return Image(uiImage: uiImage)
  }
}

