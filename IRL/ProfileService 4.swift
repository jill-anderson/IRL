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
        print("📝 Display name: \(displayName)")

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
            username: email,
            displayName: displayName,
            bio: nil,
            profilePhotoKey: nil,
            profilePhotoUrl: profilePhotoUrl,
            galleryPhotoUrls: galleryPhotoUrls.isEmpty ? nil : galleryPhotoUrls,
            birthDate: Date(),
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

        // Save to GraphQL/DynamoDB
        try await saveUserToBackend(user)

        // Also save to UserDefaults as cache
        try saveUserToLocalStorage(user)

        print("✅ User profile created and saved to backend")
        print("✅ User profile displayName saved as: \(user.displayName)")

        return user
    }

    func getUserProfile(userId: String) async throws -> User? {
        print("🔍 Fetching user profile for: \(userId)")

        // Try loading from backend first
        do {
            if let user = try await loadUserFromBackend(userId: userId) {
                print("✅ User profile loaded from backend: \(user.displayName)")
                // Cache locally
                try? saveUserToLocalStorage(user)
                return user
            }
        } catch {
            print("⚠️ Failed to load from backend: \(error), falling back to local storage")
        }

        // Fallback to local storage
        if let user = loadUserFromLocalStorage() {
            print("✅ User profile loaded from local storage: \(user.displayName)")
            return user
        }

        print("⚠️ No user profile found")
        return nil
    }

    func updateUserProfile(
        userId: String,
        displayName: String?,
        bio: String?,
        gender: User.Gender?,
        interestedIn: User.Gender?,
        jobTitle: String?,
        religiousAffiliation: String?,
        locationPrivacy: User.LocationPrivacy?,
        profilePhotoUrl: String? = nil,
        galleryPhotoUrls: [String]? = nil
    ) async throws {
        print("📝 Updating user profile for: \(userId)")

        // Load existing profile, or get from AuthenticationService if not found
        var user: User
        if let existingUser = try await getUserProfile(userId: userId) {
            user = existingUser
            print("📝 Found existing profile")
        } else if let currentUser = AuthenticationService.shared.currentUser {
            user = currentUser
            print("📝 Using current user from AuthenticationService")
        } else {
            throw NSError(domain: "ProfileService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No user found"])
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
        if let locationPrivacy = locationPrivacy { user.locationPrivacy = locationPrivacy }
        if let profilePhotoUrl = profilePhotoUrl { user.profilePhotoUrl = profilePhotoUrl }
        if let galleryPhotoUrls = galleryPhotoUrls { user.galleryPhotoUrls = galleryPhotoUrls }
        user.updatedAt = Date()

        // Check if profile exists in backend
        let profileExists = try? await loadUserFromBackend(userId: userId) != nil

        if profileExists == true {
            // Update existing profile
            try await updateUserInBackend(user)
            print("📝 Updated profile in backend")
        } else {
            // Create new profile
            try await saveUserToBackend(user)
            print("📝 Created new profile in backend")
        }

        // Save to local storage
        try saveUserToLocalStorage(user)

        print("✅ User profile saved")

        // Update the shared instance
        AuthenticationService.shared.currentUser = user
    }

    // MARK: - Backend Operations (GraphQL)

    private func saveUserToBackend(_ user: User) async throws {
        print("💾 Saving user to backend via GraphQL: \(user.id)")

        let dateFormatter = ISO8601DateFormatter()

        let mutation = """
        mutation CreateUser($input: CreateUserInput!) {
          createUser(input: $input) {
            id
            email
            username
            displayName
            gender
            locationPrivacy
            birthDate
            createdAt
            updatedAt
          }
        }
        """

        var input: [String: Any] = [
            "id": user.id,
            "email": user.email,
            "username": user.username,
            "displayName": user.displayName,
            "gender": mapGenderToGraphQL(user.gender),
            "locationPrivacy": mapLocationPrivacyToGraphQL(user.locationPrivacy),
            "birthDate": dateFormatter.string(from: user.birthDate)
        ]

        if let interestedIn = user.interestedIn {
            input["interestedIn"] = mapGenderToGraphQL(interestedIn)
        }
        if let jobTitle = user.jobTitle {
            input["jobTitle"] = jobTitle
        }
        if let religiousAffiliation = user.religiousAffiliation {
            input["religiousAffiliation"] = religiousAffiliation
        }
        if let profilePhotoUrl = user.profilePhotoUrl {
            input["profilePhotoUrl"] = profilePhotoUrl
        }
        if let galleryPhotoUrls = user.galleryPhotoUrls {
            input["galleryPhotoUrls"] = galleryPhotoUrls
        }

        let request = GraphQLRequest<String>(
            document: mutation,
            variables: ["input": input],
            responseType: String.self
        )

        do {
            let result = try await Amplify.API.mutate(request: request)
            switch result {
            case .success(let data):
                print("✅ User saved to backend successfully: \(data)")
            case .failure(let error):
                print("❌ GraphQL mutation failed: \(error)")
                throw error
            }
        } catch {
            print("❌ Failed to save user to backend: \(error)")
            throw error
        }
    }

    private func loadUserFromBackend(userId: String) async throws -> User? {
        print("🔍 Loading user from backend via GraphQL: \(userId)")

        let query = """
        query GetUser($id: ID!) {
          getUser(id: $id) {
            id
            email
            username
            displayName
            bio
            profilePhotoUrl
            galleryPhotoUrls
            birthDate
            gender
            interestedIn
            jobTitle
            religiousAffiliation
            locationPrivacy
            lastActiveAt
            createdAt
            updatedAt
          }
        }
        """

        let request = GraphQLRequest<String>(
            document: query,
            variables: ["id": userId],
            responseType: String.self
        )

        do {
            let result = try await Amplify.API.query(request: request)
            switch result {
            case .success(let jsonString):
                // Parse JSON string
                guard let jsonData = jsonString.data(using: .utf8),
                      let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                      let userData = json["getUser"] as? [String: Any] else {
                    print("⚠️ No user found in backend")
                    return nil
                }
                return try parseUserFromGraphQL(userData)
            case .failure(let error):
                print("❌ GraphQL query failed: \(error)")
                throw error
            }
        } catch {
            print("❌ Failed to load user from backend: \(error)")
            throw error
        }
    }

    private func updateUserInBackend(_ user: User) async throws {
        print("💾 Updating user in backend via GraphQL: \(user.id)")

        let mutation = """
        mutation UpdateUser($input: UpdateUserInput!) {
          updateUser(input: $input) {
            id
            displayName
            bio
            gender
            interestedIn
            jobTitle
            religiousAffiliation
            locationPrivacy
            profilePhotoUrl
            galleryPhotoUrls
            updatedAt
          }
        }
        """

        var input: [String: Any] = [
            "id": user.id
        ]

        if !user.displayName.isEmpty {
            input["displayName"] = user.displayName
        }
        if let bio = user.bio {
            input["bio"] = bio
        }
        input["gender"] = mapGenderToGraphQL(user.gender)
        if let interestedIn = user.interestedIn {
            input["interestedIn"] = mapGenderToGraphQL(interestedIn)
        }
        if let jobTitle = user.jobTitle {
            input["jobTitle"] = jobTitle
        }
        if let religiousAffiliation = user.religiousAffiliation {
            input["religiousAffiliation"] = religiousAffiliation
        }
        input["locationPrivacy"] = mapLocationPrivacyToGraphQL(user.locationPrivacy)
        if let profilePhotoUrl = user.profilePhotoUrl {
            input["profilePhotoUrl"] = profilePhotoUrl
        }
        if let galleryPhotoUrls = user.galleryPhotoUrls {
            input["galleryPhotoUrls"] = galleryPhotoUrls
        }

        let request = GraphQLRequest<String>(
            document: mutation,
            variables: ["input": input],
            responseType: String.self
        )

        do {
            let result = try await Amplify.API.mutate(request: request)
            switch result {
            case .success(let data):
                print("✅ User updated in backend successfully: \(data)")
            case .failure(let error):
                print("❌ GraphQL mutation failed: \(error)")
                throw error
            }
        } catch {
            print("❌ Failed to update user in backend: \(error)")
            throw error
        }
    }

    private func parseUserFromGraphQL(_ data: [String: Any]) throws -> User {
        guard let id = data["id"] as? String,
              let email = data["email"] as? String,
              let username = data["username"] as? String,
              let displayName = data["displayName"] as? String,
              let genderString = data["gender"] as? String,
              let locationPrivacyString = data["locationPrivacy"] as? String,
              let birthDateString = data["birthDate"] as? String,
              let createdAtString = data["createdAt"] as? String,
              let updatedAtString = data["updatedAt"] as? String else {
            throw NSError(domain: "ProfileService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid GraphQL response structure"])
        }

        let gender = parseGenderFromGraphQL(genderString)
        let locationPrivacy = parseLocationPrivacyFromGraphQL(locationPrivacyString)

        let bio = data["bio"] as? String
        let profilePhotoUrl = data["profilePhotoUrl"] as? String
        let galleryPhotoUrls = data["galleryPhotoUrls"] as? [String]
        let interestedIn = (data["interestedIn"] as? String).flatMap { parseGenderFromGraphQL($0) }
        let jobTitle = data["jobTitle"] as? String
        let religiousAffiliation = data["religiousAffiliation"] as? String

        // Parse dates with flexible formatter (handles both with and without fractional seconds)
        guard let birthDate = parseISO8601Date(birthDateString),
              let createdAt = parseISO8601Date(createdAtString),
              let updatedAt = parseISO8601Date(updatedAtString) else {
            throw NSError(domain: "ProfileService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Invalid date format in GraphQL response"])
        }

        let lastActiveAt = (data["lastActiveAt"] as? String).flatMap { parseISO8601Date($0) } ?? Date()

        return User(
            id: id,
            email: email,
            username: username,
            displayName: displayName,
            bio: bio,
            profilePhotoKey: nil,
            profilePhotoUrl: profilePhotoUrl,
            galleryPhotoUrls: galleryPhotoUrls,
            birthDate: birthDate,
            gender: gender,
            interestedIn: interestedIn,
            jobTitle: jobTitle,
            religiousAffiliation: religiousAffiliation,
            locationPrivacy: locationPrivacy,
            notificationPreferences: NotificationPreferences(),
            lastActiveAt: lastActiveAt,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    // MARK: - Helper Functions

    private func parseISO8601Date(_ dateString: String) -> Date? {
        // Try with fractional seconds first (e.g., "2026-02-18T23:13:48.424Z")
        let formatterWithFractional = ISO8601DateFormatter()
        formatterWithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatterWithFractional.date(from: dateString) {
            return date
        }

        // Fallback to without fractional seconds (e.g., "2026-02-18T23:02:59Z")
        let formatterWithoutFractional = ISO8601DateFormatter()
        formatterWithoutFractional.formatOptions = [.withInternetDateTime]
        return formatterWithoutFractional.date(from: dateString)
    }

    private func mapGenderToGraphQL(_ gender: User.Gender) -> String {
        switch gender {
        case .male: return "MALE"
        case .female: return "FEMALE"
        case .nonBinary: return "NON_BINARY"
        case .preferNotToSay: return "PREFER_NOT_TO_SAY"
        case .other: return "OTHER"
        }
    }

    private func parseGenderFromGraphQL(_ string: String) -> User.Gender {
        switch string.uppercased() {
        case "MALE": return .male
        case "FEMALE": return .female
        case "NON_BINARY": return .nonBinary
        case "PREFER_NOT_TO_SAY": return .preferNotToSay
        case "OTHER": return .other
        default: return .preferNotToSay
        }
    }

    private func mapLocationPrivacyToGraphQL(_ privacy: User.LocationPrivacy) -> String {
        switch privacy {
        case .public_, .publicLocation: return "PUBLIC"
        case .friendsOnly, .friends_only: return "FRIENDS_ONLY"
        case .privateLocation, .hidden: return "PRIVATE"
        }
    }

    private func parseLocationPrivacyFromGraphQL(_ string: String) -> User.LocationPrivacy {
        switch string.uppercased() {
        case "PUBLIC": return .public_
        case "FRIENDS_ONLY": return .friendsOnly
        case "PRIVATE": return .privateLocation
        default: return .public_
        }
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
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ProfileService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
        }

        print("📤 Uploading image to S3: \(key) (\(imageData.count) bytes)")

        let uploadTask = Amplify.Storage.uploadData(
            key: key,
            data: imageData,
            options: .init(
                contentType: "image/jpeg"
            )
        )

        let result = try await uploadTask.value
        print("✅ Image uploaded: \(result)")

        let urlResult = try await Amplify.Storage.getURL(key: key)
        let url = urlResult.absoluteString
        print("✅ Image URL: \(url)")

        return url
    }

    // MARK: - Local Storage (Cache)

    private func saveUserToLocalStorage(_ user: User) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(user)
        UserDefaults.standard.set(data, forKey: "currentUserProfile")
        print("💾 Cached user profile to UserDefaults")
        print("💾 Cached displayName: \(user.displayName)")
    }

    private func loadUserFromLocalStorage() -> User? {
        guard let data = UserDefaults.standard.data(forKey: "currentUserProfile") else {
            print("⚠️ No data found in UserDefaults")
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let user = try decoder.decode(User.self, from: data)
            print("💾 Loaded user profile from UserDefaults cache")
            print("💾 Loaded displayName: \(user.displayName)")
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
