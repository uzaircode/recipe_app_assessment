//
//  ProfileView.swift
//  recipe_app
//
//  Created by Nik Uzair on 15/08/2025.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
  @ObservedObject var authService: AuthenticationService
  @State private var selectedImage: PhotosPickerItem?
  @State private var profileImage: Image?
  @State private var showingDeleteConfirmation = false
  @Environment(\.dismiss) private var dismiss
  
  let onLogout: () -> Void
  let onDeleteAccount: () -> Void
  
  var body: some View {
    NavigationView {
      VStack(spacing: 20) {
        profileImageSection
          .padding(.top, 40)
        
        Text(authService.currentUser?.username ?? "User")
          .font(.title)
          .fontWeight(.semibold)
        
        Spacer()
        
        Button(action: {
          showingDeleteConfirmation = true
        }) {
          Label("Delete Account", systemImage: "trash")
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding(.horizontal)
        .padding(.bottom, 40)
      }
      .navigationTitle("Profile")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Logout") {
            onLogout()
          }
          .foregroundColor(.red)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Done") {
            dismiss()
          }
        }
      }
      .alert("Delete Account", isPresented: $showingDeleteConfirmation) {
        Button("Cancel", role: .cancel) { }
        Button("Delete", role: .destructive) {
          onDeleteAccount()
        }
      } message: {
        Text("Are you sure you want to delete your account?\n\nThis action cannot be undone. Your account and all associated recipes will be permanently deleted.")
      }
    }
    .onAppear {
      loadProfileImage()
    }
  }
  
  private var profileImageSection: some View {
    PhotosPicker(
      selection: $selectedImage,
      matching: .images,
      photoLibrary: .shared()
    ) {
      ZStack {
        if let profileImage = profileImage {
          profileImage
            .resizable()
            .scaledToFill()
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .overlay(
              Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        } else {
          Image(systemName: "person.circle.fill")
            .font(.system(size: 120))
            .foregroundColor(.blue)
        }
        
        VStack {
          Spacer()
          HStack {
            Spacer()
            Image(systemName: "camera.fill")
              .font(.caption)
              .foregroundColor(.white)
              .padding(6)
              .background(Circle().fill(Color.blue))
              .offset(x: -8, y: -8)
          }
        }
        .frame(width: 120, height: 120)
      }
    }
    .onChange(of: selectedImage) { _ in
      Task {
        await loadImage()
      }
    }
  }
  
  private func loadProfileImage() {
    if let imageData = authService.currentUser?.profileImageData,
       let uiImage = UIImage(data: imageData) {
      profileImage = Image(uiImage: uiImage)
    }
  }
  
  @MainActor
  private func loadImage() async {
    guard let selectedImage = selectedImage else { return }
    
    do {
      if let data = try await selectedImage.loadTransferable(type: Data.self) {
        if let uiImage = UIImage(data: data) {
          // Compress image to reduce storage size
          if let compressedData = uiImage.jpegData(compressionQuality: 0.7) {
            authService.updateProfileImage(compressedData)
            profileImage = Image(uiImage: uiImage)
          }
        }
      }
    } catch {
      print("Error loading image: \(error)")
    }
  }
}

