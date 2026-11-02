//
//  ProfileService.swift
//  IRL
//
//  Created by Jill Anderson on 2/11/26.
//

import Foundation
import Amplify
import UIKit

@MainActor
class ProfileService: ObservableObject {
    static let shared = ProfileService()

    private init() {}

    // MARK: - Profile Management

    func createUserProfile(
        userId: String,
        email: String,
        displayName: String,
        gender: User.Gender,
        interestedIn: User.Gender,
        jobTitle: String?,
        religiousAffiliation: String?,
        profileImage: UIImage?,
        galleryImages: [UIImage]
    ) async throws -> User {
        print("📝 Creating user profile for: \(userId)")

        // Upload profile photo
        var profilePhotoUrl: String? = nil
        if let profileImage = profileImage {
            profilePhotoUrl = try await uploadProfilePhoto(userId: userId, image: profileImage)
            print("✅ Profile photo uploaded: \(profilePhotoUrl ?? "nil")")
        }

        // Upload gallery photos
        var galleryPhotoUrls: [String] = []
        for (index, image) in galleryImages.enumerated() {
            let url = try await uploadGalleryPhoto(userId: userId, index: index, image: image)
            galleryPhotoUrls.append(url)
            print("✅ Gallery photo \(index + 1) uploaded: \(url)")
        }

        // Create user object
        let user = User(
            id: userId,
            email: email,
            username: email, // Using email as username
            displayName: displayName,
            bio: nil,
            profilePhotoKey: nil,
            profilePhotoUrl: profilePhotoUrl,
            galleryPhotoUrls: galleryPhotoUrls.isEmpty ? nil : galleryPhotoUrls,
            birthDate: Date(), // TODO: Collect during sign-up
            gender: gender,
            interestedIn: interestedIn,
            jobTitle: jobTitle?.isEmpty == false ? jobTitle : nil,
            religiousAffiliation: religiousAffiliation?.isEmpty == false ? religiousAffiliation : nil,
            locationPrivacy: .public_,
            notificationPreferences: NotificationPreferences(),
            lastActiveAt: Date(),
            createdAt: Date(),
            updatedAt: Date()
        )

        // Save to UserDefaults for now (TODO: Replace with DynamoDB/GraphQL)
        try saveUserToLocalStorage(user)
        print("✅ User profile created and saved")

        return user
    }

    func getUserProfile(userId: String) async throws -> User? {
        print("🔍 Fetching user profile for: \(userId)")

        // For now, load from UserDefaults (TODO: Replace with DynamoDB/GraphQL query)
        if let user = loadUserFromLocalStorage() {
            print("✅ User profile loaded from storage")
            return user
        }

        print("⚠️ No user profile found in storage")
        return nil
    }

    func updateUserProfile(
        userId: String,
        displayName: String?,
        bio: String?,
        gender: User.Gender?,
        interestedIn: User.Gender?,
        jobTitle: String?,
        religiousAffiliation: String?
    ) async throws {
        print("📝 Updating user profile for: \(userId)")

        guard var user = loadUserFromLocalStorage() else {
            throw NSError(domain: "ProfileService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No user profile found"])
        }

        // Update fields
        if let displayName = displayName { user.displayName = displayName }
        if let bio = bio { user.bio = bio }
        if let gender = gender { user.gender = gender }
        if let interestedIn = interestedIn { user.interestedIn = interestedIn }
        if let jobTitle = jobTitle { user.jobTitle = jobTitle.isEmpty ? nil : jobTitle }
        if let religiousAffiliation = religiousAffiliation {
            user.religiousAffiliation = religiousAffiliation.isEmpty ? nil : religiousAffiliation
        }
        user.updatedAt = Date()

        // Save to UserDefaults (TODO: Replace with DynamoDB/GraphQL mutation)
        try saveUserToLocalStorage(user)
        print("✅ User profile updated")

        // Update the shared instance
        AuthenticationService.shared.currentUser = user
    }

    // MARK: - Image Upload (S3)

    private func uploadProfilePhoto(userId: String, image: UIImage) async throws -> String {
        let key = "profiles/\(userId)/profile.jpg"
        return try await uploadImage(image: image, key: key)
    }

    private func uploadGalleryPhoto(userId: String, index: Int, image: UIImage) async throws -> String {
        let key = "profiles/\(userId)/gallery/\(index).jpg"
        return try await uploadImage(image: image, key: key)
    }

    private func uploadImage(image: UIImage, key: String) async throws -> String {
        // Compress image
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ProfileService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
        }

        print("📤 Uploading image to S3: \(key) (\(imageData.count) bytes)")

        // Upload to S3 via Amplify Storage
        let uploadTask = Amplify.Storage.uploadData(
            key: key,
            data: imageData,
            options: .init(
                metadata: ["contentType": "image/jpeg"],
                contentType: "image/jpeg"
            )
        )

        let result = try await uploadTask.value
        print("✅ Image uploaded: \(result)")

        // Get public URL
        let urlResult = try await Amplify.Storage.getURL(key: key)
        let url = urlResult.absoluteString
        print("✅ Image URL: \(url)")

        return url
    }

    // MARK: - Local Storage (Temporary until GraphQL is set up)

    private func saveUserToLocalStorage(_ user: User) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(user)
        UserDefaults.standard.set(data, forKey: "currentUserProfile")
        print("💾 Saved user profile to UserDefaults")
    }

    private func loadUserFromLocalStorage() -> User? {
        guard let data = UserDefaults.standard.data(forKey: "currentUserProfile") else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let user = try decoder.decode(User.self, from: data)
            print("💾 Loaded user profile from UserDefaults")
            return user
        } catch {
            print("❌ Failed to decode user profile: \(error)")
            return nil
        }
    }

    func clearLocalStorage() {
        UserDefaults.standard.removeObject(forKey: "currentUserProfile")
        print("🗑️ Cleared user profile from UserDefaults")
    }
}
