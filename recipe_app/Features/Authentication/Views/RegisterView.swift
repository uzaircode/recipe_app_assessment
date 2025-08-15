//
//  RegisterView.swift
//  recipe_app
//
//  Created by Nik Uzair on 15/08/2025.
//

import SwiftUI

struct RegisterView: View {
  @StateObject private var viewModel: RegisterViewModel
  @FocusState private var focusedField: Field?
  @Environment(\.dismiss) private var dismiss
  @State private var isPasswordVisible = false
  
  init(authService: AuthenticationService) {
    _viewModel = StateObject(wrappedValue: RegisterViewModel(authService: authService))
  }
  
  enum Field {
    case username
    case password
  }
  
  var body: some View {
    ZStack {
      LinearGradient(
        gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()
      
      ScrollView {
        VStack(spacing: 30) {
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
                  TextField("Enter password (min. 6 characters)", text: $viewModel.password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($focusedField, equals: .password)
                } else {
                  SecureField("Enter password (min. 6 characters)", text: $viewModel.password)
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
                    await viewModel.register()
                  }
                }
              }
            }
          }
          .padding(.top, 30)
          .padding(.horizontal, 30)
          
          VStack(spacing: 15) {
            Button(action: {
              Task {
                await viewModel.register()
              }
            }) {
              HStack {
                if viewModel.isLoading {
                  ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.8)
                } else {
                  Text("Create Account")
                    .fontWeight(.semibold)
                }
              }
              .frame(maxWidth: .infinity)
              .padding()
              .background(
                viewModel.isFormValid ?
                LinearGradient(
                  gradient: Gradient(colors: [Color.purple, Color.blue]),
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
            
            Button(action: {
              dismiss()
            }) {
              Text("Already have an account? Login")
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
    .navigationTitle("Create Account")
    .navigationBarTitleDisplayMode(.large)
    .navigationBarBackButtonHidden(false)
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
    .onChange(of: viewModel.registrationSuccessful) { _, success in
      if success {
        dismiss()
      }
    }
  }
  
  private func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}
