//
//  Springboard+Extensions.swift
//  recipe_app
//
//  Created by Nik Uzair on 20/08/2025.
//

class Springboard {
  
  static let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
  
  /**
   Terminate and delete the app via springboard
   */
  class func uninstall() {
    
    XCUIApplication().terminate()
    springboard.activate()
    
    // Force delete the app from the springboard
    let appIcon = springboard.icons["recipe_app"]
    appIcon.press(forDuration: 1.3)
    
    let _ = springboard.buttons["Remove App"].waitForExistence(timeout: 1.0)
    springboard.buttons["Remove App"].tap()
    
    let _ = springboard.buttons["Delete App"].waitForExistence(timeout: 5.0)
    springboard.buttons["Delete App"].tap()
    
    let _ = springboard.alerts.buttons["Delete"].waitForExistence(timeout: 5.0)
    springboard.alerts.buttons["Delete"].tap()
    
  }
}
