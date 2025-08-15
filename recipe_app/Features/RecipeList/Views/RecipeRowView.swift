//
//  RecipeRowView.swift
//  recipe_app
//
//  Created by Nik Uzair on 15/08/2025.
//

import SwiftUI

struct RecipeRowView: View {
  let recipe: RecipeModel
  let recipeType: RecipeTypeModel?
  let onToggleFavorite: () -> Void
  
  var body: some View {
    HStack(spacing: 12) {
      if let image = recipe.image {
        image
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: 80, height: 80)
          .cornerRadius(10)
      } else {
        RoundedRectangle(cornerRadius: 10)
          .fill(LinearGradient(
            gradient: Gradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.3)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ))
          .frame(width: 80, height: 80)
          .overlay(
            Image(systemName: "photo")
              .font(.title2)
              .foregroundColor(.gray)
          )
      }
      
      VStack(alignment: .leading, spacing: 4) {
        HStack(alignment: .top) {
          Text(recipe.name)
            .font(.headline)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
          
          Spacer(minLength: 8)
          
          Button(action: onToggleFavorite) {
            Image(systemName: recipe.isFavorite ? "star.fill" : "star")
              .foregroundColor(recipe.isFavorite ? .yellow : .gray)
              .animation(.easeInOut(duration: 0.2), value: recipe.isFavorite)
          }
          .buttonStyle(PlainButtonStyle())
        }
        
        if let recipeType = recipeType {
          HStack(spacing: 6) {
            Image(systemName: recipeType.iconName)
              .font(.caption)
            Text(recipeType.displayName)
              .font(.caption)
          }
          .foregroundColor(.secondary)
        }
        
        HStack(spacing: 12) {
          HStack(spacing: 4) {
            Image(systemName: "clock")
              .font(.caption)
            Text("\(recipe.prepTime) min")
              .font(.caption)
          }
          .foregroundColor(.secondary)
          
          HStack(spacing: 4) {
            Image(systemName: "person.2")
              .font(.caption)
            Text("\(recipe.servings) servings")
              .font(.caption)
          }
          .foregroundColor(.secondary)
        }
        
        HStack(spacing: 4) {
          Image(systemName: "checklist")
            .font(.caption2)
          Text("\(recipe.ingredients.count) ingredients • \(recipe.steps.count) steps")
            .font(.caption2)
            .foregroundColor(.secondary)
        }
      }
      .padding(.vertical, 4)
    }
    .padding(.vertical, 4)
  }
}

