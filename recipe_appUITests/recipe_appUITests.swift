//
//  recipe_appUITests.swift
//  recipe_appUITests
//
//  Created by Nik Uzair on 15/08/2025.
//

import XCTest

final class recipeUITests: XCTestCase {
  
  var app: XCUIApplication!
  
  override func setUpWithError() throws {
    app = XCUIApplication()
    continueAfterFailure = false
    app.launch()
  }
  
  override func tearDownWithError() throws {
    Springboard.uninstall()
  }
  
  @MainActor
  func testRegistrationFlow() throws {
    let toggleButton = app.buttons["Don't have an account? Register"]
    toggleButton.tap()
    
    let usernameField = app.textFields["Enter username"]
    let passwordField = app.secureTextFields["Enter password (min. 6 characters)"]
    let registerButton = app.buttons["Create Account"]
    
    usernameField.tap()
    usernameField.typeText("newuser\(Int.random(in: 1000...9999))")
    
    passwordField.tap()
    passwordField.typeText("newpassword123")
    
    registerButton.tap()
    
    let recipeListTitle = app.navigationBars["Recipes"]
    XCTAssertTrue(recipeListTitle.waitForExistence(timeout: 5))
  }
  
  @MainActor
  func testAddRecipe() throws {
    performLogin()
    
    let addButton = app.navigationBars["Recipes"].buttons["plus"]
    XCTAssertTrue(addButton.waitForExistence(timeout: 5))
    addButton.tap()
    
    let recipeNameField = app.textFields["Recipe Name"]
    XCTAssertTrue(recipeNameField.waitForExistence(timeout: 2))
    recipeNameField.tap()
    recipeNameField.typeText("UI Test Recipe")
    
    let ingredientField = app.textFields["Ingredient 1"]
    ingredientField.tap()
    ingredientField.typeText("Test Ingredient")
    
    let addIngredientButton = app.buttons["Add Ingredient"]
    addIngredientButton.tap()
    
    let ingredient2Field = app.textFields["Ingredient 2"]
    ingredient2Field.tap()
    ingredient2Field.typeText("Another Ingredient")
    
    let stepField = app.textFields["Step 1"]
    stepField.tap()
    stepField.typeText("First step of recipe")
    
    let addStepButton = app.buttons["Add Step"]
    addStepButton.tap()
    
    let step2Field = app.textFields["Step 2"]
    step2Field.tap()
    step2Field.typeText("Second step of recipe")
    
    let saveButton = app.navigationBars["New Recipe"].buttons["Save"]
    saveButton.tap()
    
    let recipeCell = app.cells.containing(.staticText, identifier: "UI Test Recipe").firstMatch
    scrollToElement(recipeCell, in: app)
    XCTAssertTrue(recipeCell.waitForExistence(timeout: 5))
  }
  
  @MainActor
  func testRecipeListFiltering() throws {
    performLogin()
    
    let filterButton = app.navigationBars["Recipes"].buttons["line.3.horizontal.decrease.circle"]
    XCTAssertTrue(filterButton.waitForExistence(timeout: 5))
    filterButton.tap()
    
    let breakfastOption = app.buttons["Breakfast"]
    XCTAssertTrue(breakfastOption.waitForExistence(timeout: 2))
    breakfastOption.tap()
    
    let doneButton = app.navigationBars["Filter & Sort"].buttons["Done"]
    doneButton.tap()
    
    XCTAssertTrue(app.staticTexts["Breakfast"].waitForExistence(timeout: 2))
  }
  
  @MainActor
  func testRecipeDetail() throws {
    performLogin()
    addSampleRecipe()
    
    let recipeCell = app.cells.containing(.staticText, identifier: "UI Test Recipe").firstMatch
    scrollToElement(recipeCell, in: app)
    recipeCell.tap()
    
    let recipeTitle = app.navigationBars["UI Test Recipe"]
    XCTAssertTrue(recipeTitle.waitForExistence(timeout: 2))
    
    XCTAssertTrue(app.staticTexts["Ingredients"].exists)
    XCTAssertTrue(app.staticTexts["Instructions"].exists)
  }
  
  @MainActor
  func testDeleteRecipe() throws {
    performLogin()
    addSampleRecipe()
    
    let recipeCell = app.cells.containing(.staticText, identifier: "UI Test Recipe").firstMatch
    scrollToElement(recipeCell, in: app)
    XCTAssertTrue(recipeCell.waitForExistence(timeout: 5))
    
    recipeCell.swipeLeft()
    
    let deleteButton = app.buttons["Delete"]
    XCTAssertTrue(deleteButton.waitForExistence(timeout: 2))
    deleteButton.tap()
    
    let confirmButton = app.alerts.buttons["Delete"]
    XCTAssertTrue(confirmButton.waitForExistence(timeout: 2))
    confirmButton.tap()
    
    XCTAssertFalse(recipeCell.exists)
  }
  
  func scrollToElement(_ element: XCUIElement, in app: XCUIApplication) {
    while !element.exists || !element.isHittable {
      app.swipeUp()
    }
  }
  
  @MainActor
  func testFavoriteRecipe() throws {
    performLogin()
    addSampleRecipe()
    
    let recipeCell = app.cells.containing(.staticText, identifier: "UI Test Recipe").firstMatch
    scrollToElement(recipeCell, in: app)
    
    recipeCell.swipeLeft()
    
    let favoriteButton = app.buttons["Favorite"]
    XCTAssertTrue(favoriteButton.waitForExistence(timeout: 2))
    favoriteButton.tap()
    
    recipeCell.tap()
    
    //    let heartIcon = app.buttons["heart.fill"]
    //    XCTAssertTrue(heartIcon.waitForExistence(timeout: 2))
  }
  
  @MainActor
  func testSearchRecipes() throws {
    performLogin()
    addSampleRecipe()
    
    let searchField = app.searchFields["Search recipes or ingredients"]
    XCTAssertTrue(searchField.waitForExistence(timeout: 5))
    searchField.tap()
    searchField.typeText("UI Test")
    
    let recipeCell = app.cells.containing(.staticText, identifier: "UI Test Recipe").firstMatch
    XCTAssertTrue(recipeCell.exists)
    
    searchField.clearAndTypeText("NonExistent")
    XCTAssertFalse(recipeCell.exists)
  }
  
  @MainActor
  func testLogout() throws {
    performLogin()
    
    let profileButton = app.navigationBars["Recipes"].buttons["person.circle"]
    XCTAssertTrue(profileButton.waitForExistence(timeout: 5))
    profileButton.tap()
    
    let logoutButton = app.buttons["Logout"]
    XCTAssertTrue(logoutButton.waitForExistence(timeout: 2))
    logoutButton.tap()
    
    let loginButton = app.buttons["Login"]
    XCTAssertTrue(loginButton.waitForExistence(timeout: 2))
  }
  
  private func performLogin() {
    let toggleButton = app.buttons["Don't have an account? Register"]
    toggleButton.tap()
    
    let usernameField = app.textFields["Enter username"]
    let passwordField = app.secureTextFields["Enter password (min. 6 characters)"]
    let registerButton = app.buttons["Create Account"]
    
    usernameField.tap()
    usernameField.typeText("newuser\(Int.random(in: 1000...9999))")
    
    passwordField.tap()
    passwordField.typeText("newpassword123")
    
    registerButton.tap()
    
    let recipeListTitle = app.navigationBars["Recipes"]
    XCTAssertTrue(recipeListTitle.waitForExistence(timeout: 5))
  }
  
  private func addSampleRecipe() {
    let addButton = app.navigationBars["Recipes"].buttons["plus"]
    addButton.tap()
    
    let recipeNameField = app.textFields["Recipe Name"]
    recipeNameField.tap()
    recipeNameField.typeText("UI Test Recipe")
    
    let ingredientField = app.textFields["Ingredient 1"]
    ingredientField.tap()
    ingredientField.typeText("Test Ingredient")
    
    let stepField = app.textFields["Step 1"]
    stepField.tap()
    stepField.typeText("Test Step")
    
    let saveButton = app.navigationBars["New Recipe"].buttons["Save"]
    saveButton.tap()
    
    _ = app.cells.containing(.staticText, identifier: "UI Test Recipe").firstMatch.waitForExistence(timeout: 10)
  }
}

extension XCUIElement {
  func clearAndTypeText(_ text: String) {
    guard let stringValue = self.value as? String else {
      typeText(text)
      return
    }
    
    tap()
    let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
    typeText(deleteString)
    typeText(text)
  }
}
