# Recipe App

A modern iOS recipe management application built with SwiftUI and Core Data, providing a seamless experience for organizing, creating, and discovering recipes.

## Screenshots (Light Mode)
<img width="150" height="450" alt="simulator_screenshot_AE9724E8-6F86-4F28-AC2E-DD780AF98982" src="https://github.com/user-attachments/assets/40a3b426-b8d7-4a87-8a56-d48234d274f1" />
<img width="150" height="450" alt="simulator_screenshot_CF0BF97D-A9A3-4BC4-847A-80C25312FFA1" src="https://github.com/user-attachments/assets/49f09e4f-5222-4241-954f-7588fde0c9bc" />
<img width="150" height="450" alt="simulator_screenshot_AA7E266F-086E-4B85-A1E2-7BF99C9C2696" src="https://github.com/user-attachments/assets/8f7f8029-322f-4d57-b94f-9b75285b3802" />
<img width="150" height="450" alt="simulator_screenshot_48424D10-1972-4E6B-927F-E9DE17851FB9" src="https://github.com/user-attachments/assets/b9bc8dbc-080d-4765-9841-aeac8f9fec59" />
<img width="150" height="450" alt="simulator_screenshot_22AD38FD-FF16-4806-A20C-2BB5CCCB6601" src="https://github.com/user-attachments/assets/d7dfdb70-776a-4e8f-8529-c46df3da3550" />
<img width="150" height="450" alt="simulator_screenshot_700D8F04-FEBB-44A4-9D99-D42C84758D78" src="https://github.com/user-attachments/assets/a436a1b4-706d-4865-b9c6-ed9a37b500ca" />
<img width="150" height="450" alt="simulator_screenshot_47566674-A567-4A41-9073-E98009CB4702" src="https://github.com/user-attachments/assets/e97b6f3f-e042-4dcc-a42f-4c64570c1ac8" />
<img width="150" height="450" alt="simulator_screenshot_0FCA587A-1B31-42CC-95D8-9B13491AC06B" src="https://github.com/user-attachments/assets/7b70b237-c457-4677-92c8-96a7f1db335c" />

## Screenshots (Dark Mode)

<img width="150" height="450" alt="simulator_screenshot_F78877DA-A41A-4294-86E4-76BEBF99EA0F" src="https://github.com/user-attachments/assets/01304a20-0e7a-4013-877f-ea11fc45a7a0" />
<img width="150" height="450" alt="simulator_screenshot_9109C1FA-F3CD-42A5-8A45-B601534B909C" src="https://github.com/user-attachments/assets/0cd10559-94db-4391-abd0-0a1e1df9d12f" />
<img width="150" height="450" alt="simulator_screenshot_B2C67054-C95A-4FE1-BDCC-518AAF731038" src="https://github.com/user-attachments/assets/4aef2559-08f5-4643-83e1-42812095f4df" />
<img width="150" height="450" alt="simulator_screenshot_56F7F20B-8DC8-4F5B-A379-86E33D9F6D40" src="https://github.com/user-attachments/assets/8e3059c5-a671-4d08-a32d-97f7bcff714b" />
<img width="150" height="450" alt="simulator_screenshot_7DFB3573-D200-49DC-A673-9EBFC4C588A7" src="https://github.com/user-attachments/assets/9c6f6e27-cef1-49d9-8cc0-474936e55dcd" />
<img width="150" height="450" alt="simulator_screenshot_B866A340-1215-43C8-AA18-59E31772D37A" src="https://github.com/user-attachments/assets/940a12d6-eb48-46d2-8cd5-941227b8409c" />
<img width="150" height="450" alt="simulator_screenshot_42E7BDC9-3474-4761-90E1-54CC61A5AC5A" src="https://github.com/user-attachments/assets/035fac6f-fcc5-4c8d-ac71-3bb46ad55501" />
<img width="150" height="450" alt="simulator_screenshot_8E10E79F-69F0-4D02-83B7-15F0559AADAF" src="https://github.com/user-attachments/assets/00c7ab36-ce88-4052-ae08-6365a72d440b" />


## Table of Contents
- [Features](#features)
- [Technical Architecture](#technical-architecture)
- [Project Structure](#project-structure)
- [Core Technologies](#core-technologies)
- [Testing](#testing)
- [Data Models](#data-models)
- [Key Components](#key-components)
- [Security & Authentication](#security--authentication)
- [UI/UX Design](#uiux-design)
- [Installation](#installation)
- [Requirements](#requirements)

## Quick Start

### Run the App
```bash
git clone https://github.com/yourusername/recipe_app_assessment.git
cd recipe_app_assessment
open recipe_app_assessment.xcodeproj
# Press Cmd+R in Xcode
```

### Run All Tests
```bash
xcodebuild test -scheme recipe_app_assessment -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### Test Coverage
**~90% coverage** with comprehensive unit, UI, and performance tests using Swift Testing framework

## Features

### User Management
- **Secure Authentication**: Username/password based authentication with SHA256 password hashing
- **Account Management**: User registration, login, logout, and account deletion with confirmation
- **Session Persistence**: Automatic session restoration using iOS Keychain Services
- **Profile Management**: View profile with logout in navigation bar and account deletion option

### Recipe Management
- **Create Recipes**: Add new recipes with name, category, ingredients, steps, prep time, and servings
- **Image Support**: Attach photos to recipes from photo library with PhotosUI integration
- **Edit Recipes**: Modify existing recipes with inline editing and real-time updates
- **Delete Recipes**: Swipe-to-delete functionality with confirmation alert and Core Data cascade deletion
- **Favorite Recipes**: Star/unstar recipes with haptic feedback and automatic resorting

### Organization & Discovery
- **Recipe Categories**: 11 pre-defined categories (Breakfast, Lunch, Dinner, Dessert, Appetizer, Salad, Soup, Snack, Beverage, Vegetarian, Other)
- **Smart Search**: Real-time search by recipe name or ingredients
- **Multiple Sort Options**: Sort by name (default), recently updated, prep time, or favorites first
- **Filter by Category**: Quick filtering with visual category indicator
- **Sample Data**: New users receive 14 pre-populated sample recipes across all categories

## Technical Architecture

### Architecture Pattern
The app follows the **MVVM (Model-View-ViewModel)** architecture pattern:

- **Models**: Data structures and Core Data entities
- **Views**: SwiftUI views for UI presentation
- **ViewModels**: Business logic and state management with @Published properties
- **Services**: Centralized business logic for authentication and recipe operations
- **App Initialization**: Proper service connection and session restoration

### Data Flow
```
User Input → View → ViewModel → Service → Core Data
                ↑                    ↓
            UI Update ← @Published State
```

## Core Technologies

### SwiftUI
- **Declarative UI**: All views built with SwiftUI
- **@StateObject/@ObservedObject**: Reactive state management
- **@EnvironmentObject**: Dependency injection for services
- **@FocusState**: Keyboard and input field management
- **Custom Modifiers**: Reusable UI components and styling

### Core Data
- **Entities**:
  - `User`: Stores user credentials and metadata
  - `Recipe`: Stores recipe data with relationships to users
- **Persistence**: SQLite backend with automatic migration support
- **Context Management**: Single managed object context with automatic save
- **Transformable Attributes**: Arrays stored as transformable for ingredients/steps

### Security
- **Password Hashing**: SHA256 cryptographic hashing for passwords
- **Keychain Storage**: Secure token storage using iOS Keychain Services
- **Session Management**: Token-based authentication with persistence
- **Account Deletion**: Cascade deletion of user data with confirmation

### PhotosUI
- **Image Picker**: Native photo selection from device library
- **Image Processing**: Automatic image compression and storage
- **Data Persistence**: Images stored as binary data in Core Data

## Project Structure

```
recipe/
├── App/
│   ├── recipeApp.swift           # Main app entry point
│   ├── MainView.swift            # Root view controller
│   └── DependencyContainer.swift # Dependency injection setup
│
├── Core/
│   ├── Data/
│   │   ├── CoreData/            # Core Data stack and persistence
│   │   ├── Network/             # API endpoints and network manager
│   │   └── Local/               # Local JSON data (recipetypes.json)
│   │
│   ├── Models/                  # Data models
│   │   ├── RecipeModel.swift
│   │   ├── RecipeTypeModel.swift
│   │   └── UserModel.swift
│   │
│   └── Services/                # Business logic services
│       ├── AuthenticationService.swift
│       └── RecipeService.swift
│
├── Features/
│   ├── Authentication/
│   │   ├── ViewModels/
│   │   │   ├── LoginViewModel.swift
│   │   │   └── RegisterViewModel.swift
│   │   └── Views/
│   │       ├── LoginView.swift
│   │       └── RegisterView.swift
│   │
│   ├── RecipeList/
│   │   ├── ViewModels/
│   │   │   └── RecipeListViewModel.swift
│   │   └── Views/
│   │       ├── RecipeListView.swift
│   │       └── RecipeRowView.swift
│   │
│   ├── AddRecipe/
│   │   ├── ViewModels/
│   │   │   └── AddRecipeViewModel.swift
│   │   └── Views/
│   │       └── AddRecipeView.swift
│   │
│   └── RecipeDetail/
│       ├── ViewModels/
│       │   └── RecipeDetailViewModel.swift
│       └── Views/
│           └── RecipeDetailView.swift
│
├── Resources/
│   └── Assets.xcassets          # Images, colors, and app icons
│
└── Tests/
    ├── recipe_appTests/             # Unit tests
    │   ├── recipe_appTests.swift    # Comprehensive unit test suite
    │
    └── recipe_appUITests/           # UI tests
        ├── recipe_appUITests.swift  # End-to-end UI flow tests
        ├── recipe_appUITestsLaunchTests.swift # Launch performance tests
```

## Getting Started

## Requirements

- **iOS**: 18.5+
- **Xcode**: 15.0+
- **Swift**: 5.9+
- **Device**: iPhone (iPad support possible but not optimized)
- **macOS**: Ventura or later for development

## Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/recipe_app_assessment.git
cd recipe
```

2. **Open in Xcode**
```bash
open recipe.xcodeproj
```

3. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run
   - No external dependencies to install (all code is native)

### First Launch
- The app will display a login screen on first launch
- Tap "Don't have an account? Register" to create a new account
- Registration requires username and password (minimum 6 characters)
- 14 sample recipes will be automatically loaded for new users

## Data Models

### User Entity
```swift
- id: UUID (Primary Key)
- username: String (Unique)
- passwordHash: String
- token: String? (Optional)
- createdAt: Date
- lastLogin: Date? (Optional)
```

### Recipe Entity
```swift
- id: UUID (Primary Key)
- userId: UUID (Foreign Key)
- name: String
- typeId: String
- imageData: Data? (Optional)
- ingredients: [String] (Transformable)
- steps: [String] (Transformable)
- isFavorite: Bool
- prepTime: Int32 (minutes)
- servings: Int32
- createdAt: Date
- updatedAt: Date
```

### Recipe Categories
Pre-defined categories loaded from JSON:
- Breakfast, Lunch, Dinner
- Appetizer, Salad, Soup
- Snack, Dessert, Beverage
- Vegetarian, Other

Each category includes:
- Unique identifier
- Display name
- SF Symbol icon name

## Key Components

### AuthenticationService
- User registration with duplicate username prevention
- Secure login with SHA256 password validation
- Token generation and management
- Session restoration on app launch (fixed initialization order)
- Account deletion with cascade delete of all user recipes
- Keychain integration for secure token storage

### RecipeService
- CRUD operations for recipes with Core Data persistence
- Real-time filtering and search across recipe names and ingredients
- Recipe type management from JSON configuration
- Sample data generation for new users (14 recipes)
- Favorite toggling with optimistic UI updates
- Proper user context management

### Custom UI Components
- **RecipeRowView**: Reusable recipe card with image, metadata, and favorite star
- **List Separators**: Clean edge-to-edge separators for all list items
- **Password Toggle**: Show/hide password with eye icon in auth screens
- **Haptic Feedback**: Medium impact feedback for favorite actions
- **Scrollable Forms**: Support for small screens (iPhone SE compatible)
- **Tap to Dismiss**: Keyboard dismissal on tap in forms

## UI/UX Design

### Design Principles
- **iOS Native**: Follows Apple Human Interface Guidelines
- **Responsive**: Supports all iPhone sizes including iPhone SE with ScrollView
- **Accessibility**: VoiceOver compatible with semantic labels
- **Dark Mode**: System appearance support (automatic)

### Navigation
- **NavigationView Stack**: Push navigation for registration
- **Modal Sheets**: Add/edit recipes and profile in modal presentations
- **Swipe Actions**: Delete and favorite actions on recipe cards
- **Search Bar**: Integrated search with real-time filtering
- **Toolbar Actions**: Profile, filters, and add recipe in navigation bar

### Visual Design
- **Color Scheme**: 
  - Primary: System blue
  - Accent: Yellow (favorite stars)
  - Destructive: Red (delete actions, logout)
  - Secondary: Gray for metadata
- **Typography**: System fonts with semantic sizing
- **Spacing**: Consistent 8-point grid system
- **Animations**: Smooth SwiftUI transitions (0.2s for favorites)
- **Loading States**: ProgressView during async operations

## App Screens

### 1. Authentication
- **LoginView**: Username/password fields with "Done" keyboard button
- **RegisterView**: Push navigation from login, automatic sign-in after registration
- **Password Features**: Toggle visibility with eye icon, minimum 6 characters for registration
- **Keyboard Management**: Tap to dismiss (using toolbar Done button in forms)

### 2. Recipe List
- **Main View**: Displays all recipes in a scrollable list
- **Recipe Cards**: Shows recipe image, name, type, prep time, and servings
- **Actions**:
  - Tap anywhere on card to view details (except star icon)
  - Star icon to toggle favorite status
  - Swipe left for quick actions (delete with confirmation, favorite)
  - Pull to refresh
- **Filter & Sort**:
  - Filter by recipe type
  - Sort by date, name, prep time, or favorites
- **Search**: Real-time search by recipe name or ingredients

### 3. Add Recipe
- **Recipe Information**:
  - Recipe name
  - Category selection (picker)
  - Prep time and servings
- **Image**: Add photo from camera or photo library
- **Ingredients**: Dynamic list with add/remove functionality
- **Steps**: Numbered instructions with add/remove capability
- **Validation**: Form validation ensures all required fields are filled

### 4. Recipe Detail
- **View Mode**:
  - Large recipe image
  - Complete ingredient list
  - Step-by-step instructions
  - Recipe metadata (type, prep time, servings)
- **Edit Mode**:
  - In-place editing of all fields
  - Image replacement
  - Save or cancel changes
- **Actions**:
  - Edit recipe
  - Delete recipe (with confirmation)
  - Toggle favorite with star icon
  - Share recipe

### 5. Profile
- **User Information**: Display current username with person.circle.fill icon
- **Logout**: Red button in top-left navigation bar
- **Delete Account**: Destructive action with confirmation alert
- **Warning**: Clear message about permanent account and recipe deletion

## Development Features

### Debug Logging
The app includes comprehensive logging for debugging:
- Authentication flow tracking (session found, user registration)
- Recipe persistence operations (loaded X recipes for user)
- Core Data save operations
- Sample data loading status

### Error Handling
- Graceful error recovery with user-friendly alerts
- Form validation before submission
- Duplicate username prevention
- Safe unwrapping of optionals

### Performance Optimizations
- Lazy loading of images from Core Data
- Efficient Core Data fetching with predicates
- Minimal view re-renders using @StateObject
- Optimized search using filteredRecipes computed property

## Testing

## Screenshots
<img width="150" height="450" alt="Screenshot 2025-08-15 at 6 54 17 PM" src="https://github.com/user-attachments/assets/59df6dd2-eba0-436b-a2f5-86a0b5ae26f2" />


### Comprehensive Test Suite
The app includes a modern, comprehensive test suite with ~90% code coverage across two testing layers:

### Unit Tests (`recipe_appTests.swift`)
Comprehensive business logic testing using Swift Testing framework:

**Model Testing**
- Recipe, User, and RecipeType model creation and validation
- Edge cases (empty values, excessive data, boundary conditions)
- CoreData entity conversion and persistence
- Validation test suite with expected outcomes

**Service Testing**
- Full CRUD operations for RecipeService
- Authentication flows (registration, login, duplicate prevention)
- Search and filter functionality
- Error handling and recovery

### UI Tests (`recipe_appUITests.swift`)
End-to-end user flow testing with accessibility identifiers:

**Authentication Testing**
- Login flow with valid/invalid credentials
- Registration with unique username generation
- Password visibility toggle
- Session persistence

**Recipe Management**
- Complete add recipe flow with validation
- Edit recipe with inline changes
- Delete with swipe and confirmation
- Favorite toggle with persistence

**Navigation & Search**
- Deep navigation paths
- Modal presentations
- Search with real-time filtering
- Filter and sort combinations

**Edge Cases**
- Empty state handling
- Form validation states
- Network timeout simulation
- Keyboard management

**Visual Testing**
- Dark/Light mode variations
- Portrait/Landscape orientations
- Multiple device sizes (iPhone SE to Pro Max)

### Test Best Practices Implemented
1. **Accessibility First**: All UI elements have identifiers
2. **Isolation**: Each test runs in isolation with clean state
3. **Mock Data**: Consistent, predictable test data
4. **Performance Monitoring**: Track metrics over time
5. **Flake Prevention**: Proper waits and timeout handling
6. **Parallel Execution**: Tests can run concurrently
7. **Clear Naming**: Descriptive test names indicate purpose

## Security & Authentication

### Implementation Details
- **Password Hashing**: SHA256 with CryptoKit for secure storage
- **Keychain Integration**: Using Security framework for token persistence
- **Session Flow**: 
  1. Login generates UUID-based token
  2. Token saved to Keychain
  3. App restart checks Keychain for valid session
  4. Automatic restoration with proper service initialization
- **Account Security**: Delete account requires confirmation, cascades to all user data

## Persistence Strategy

### Core Data Stack
- **PersistenceController**: Singleton pattern for Core Data stack management
- **View Context**: Single NSManagedObjectContext for all operations
- **Auto-save**: Context saves after each modification
- **Migration**: Lightweight migration enabled for schema updates

### Data Management
- Recipe images stored as binary data (compressed)
- Ingredients and steps as transformable arrays
- Automatic timestamps (createdAt, updatedAt)
- User-recipe relationship via userId foreign key

## License

This project is proprietary software. All rights reserved.

## Author

Created by Nik Uzair (2025)
