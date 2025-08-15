//
//  LoginView.swift
//  recipe_app
//
//  Created by Nik Uzair on 15/08/2025.
//

import SwiftUI

struct LoginView: View {
  @StateObject private var viewModel: LoginViewModel
  @FocusState private var focusedField: Field?
  @State private var isPasswordVisible = false
  
  init(authService: AuthenticationService) {
    _viewModel = StateObject(wrappedValue: LoginViewModel(authService: authService))
  }
  
  enum Field {
    case username
    case password
  }
  
  var body: some View {
    NavigationView {
      ZStack {
        LinearGradient(
          gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        ScrollView {
          VStack(spacing: 30) {
            VStack(spacing: 10) {
              Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
              
              Text("Recipe App")
                .font(.largeTitle)
                .fontWeight(.bold)
              
              Text("Welcome Back!")
                .font(.title3)
                .foregroundColor(.secondary)
            }
            .padding(.top, 50)
            
            VStack(spacing: 20) {
              VStack(alignment: .leading, spacing: 8) {
                Label("Username", systemImage: "person.fill")
                  .font(.caption)
                  .foregroundColor(.secondary)
                
                TextField("Enter username", text: $viewModel.username)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                  .autocapitalization(.none)
                  .disableAutocorrection(true)
                  .focused($focusedField, equals: .username)
                  .submitLabel(.next)
                  .onSubmit {
                    focusedField = .password
                  }
              }
              
              VStack(alignment: .leading, spacing: 8) {
                Label("Password", systemImage: "lock.fill")
                  .font(.caption)
                  .foregroundColor(.secondary)
                
                ZStack(alignment: .trailing) {
                  if isPasswordVisible {
                    TextField("Enter password", text: $viewModel.password)
                      .autocapitalization(.none)
                      .disableAutocorrection(true)
                      .textFieldStyle(RoundedBorderTextFieldStyle())
                      .focused($focusedField, equals: .password)
                  } else {
                    SecureField("Enter password", text: $viewModel.password)
                      .textFieldStyle(RoundedBorderTextFieldStyle())
                      .focused($focusedField, equals: .password)
                  }
                  
                  Button(action: {
                    isPasswordVisible.toggle()
                  }) {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                      .foregroundColor(.secondary)
                      .font(.system(size: 16))
                  }
                  .padding(.trailing, 8)
                }
                .submitLabel(.done)
                .onSubmit {
                  if viewModel.isFormValid {
                    Task {
                      await viewModel.authenticate()
                    }
                  }
                }
              }
            }
            .padding(.horizontal, 30)
            
            VStack(spacing: 15) {
              Button(action: {
                Task {
                  await viewModel.authenticate()
                }
              }) {
                HStack {
                  if viewModel.isLoading {
                    ProgressView()
                      .progressViewStyle(CircularProgressViewStyle(tint: .white))
                      .scaleEffect(0.8)
                  } else {
                    Text("Login")
                      .fontWeight(.semibold)
                  }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                  viewModel.isFormValid ?
                  LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                  ) : LinearGradient(
                    gradient: Gradient(colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.3)]),
                    startPoint: .leading,
                    endPoint: .trailing
                  )
                )
                .foregroundColor(.white)
                .cornerRadius(10)
              }
              .disabled(!viewModel.isFormValid || viewModel.isLoading)
              
              NavigationLink(destination: RegisterView(authService: viewModel.authService)) {
                Text("Don't have an account? Register")
                  .font(.footnote)
                  .foregroundColor(.blue)
              }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
          }
        }
        .onTapGesture {
          hideKeyboard()
        }
      }
      .navigationBarHidden(true)
      .alert("Error", isPresented: $viewModel.showError) {
        Button("OK") {
          viewModel.clearError()
        }
      } message: {
        Text(viewModel.errorMessage ?? "An unknown error occurred")
      }
      .onAppear {
        focusedField = .username
      }
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
  
  private func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}
