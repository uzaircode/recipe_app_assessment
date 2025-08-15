//
//  RecipeTypeModel.swift
//  recipe_app
//
//  Created by Nik Uzair on 15/08/2025.
//

import Foundation

struct RecipeTypeModel: Codable, Identifiable, Hashable {
  let id: String
  let name: String
  let displayName: String
  let iconName: String
  
  static func loadFromJSON() -> [RecipeTypeModel] {
    guard let url = Bundle.main.url(forResource: "recipetypes", withExtension: "json"),
          let data = try? Data(contentsOf: url) else {
      return []
    }
    
    do {
      let decoder = JSONDecoder()
      let response = try decoder.decode(RecipeTypesResponse.self, from: data)
      return response.recipeTypes
    } catch {
      print("Error decoding recipe types: \(error)")
      return []
    }
  }
}

struct RecipeTypesResponse: Codable {
  let recipeTypes: [RecipeTypeModel]
}

