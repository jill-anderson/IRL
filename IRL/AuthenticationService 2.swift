//
//  AuthenticationService.swift
//  IRL
//
//  Created by Jill Anderson on 2/11/26.
//

import Foundation
import Amplify
import Combine

@MainActor
class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()

    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false

    private init() {
        Task {
            await checkAuthStatus()
        }
    }

    func checkAuthStatus() async {
        print("🔍 Checking auth status...")

        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            print("🔍 Session isSignedIn: \(session.isSignedIn)")

            if session.isSignedIn {
                // Fetch user details
                let authUser = try await Amplify.Auth.getCurrentUser()
                print("✅ Current user: \(authUser.username) (ID: \(authUser.userId))")

                // Fetch email from user attributes
                var email = authUser.username
                do {
                    let userAttributes = try await Amplify.Auth.fetchUserAttributes()
                    if let emailAttr = userAttributes.first(where: { $0.key == .email }) {
                        email = emailAttr.value
                        print("✅ User email from attributes: \(email)")
                    } else {
                        print("⚠️ No email attribute found, using username: \(email)")
                    }
                } catch {
                    print("⚠️ Failed to fetch user attributes: \(error), using username: \(email)")
                }

                // Fetch user profile from ProfileService
                if let user = try await ProfileService.shared.getUserProfile(userId: authUser.userId) {
                    currentUser = user
                    print("✅ User profile loaded: \(user.displayName)")
                } else {
                    // No profile found - user might have signed up before profile persistence was implemented
                    // Create a basic user object
                    print("⚠️ No saved profile found, creating default user with email: \(email)")
                    currentUser = User(
                        id: authUser.userId,
                        email: email,
                        username: email,
                        displayName: email,
                        bio: nil,
                        profilePhotoKey: nil,
                        profilePhotoUrl: nil,
                        galleryPhotoUrls: nil,
                        birthDate: Date(),
                        gender: .preferNotToSay,
                        interestedIn: nil,
                        jobTitle: nil,
                        religiousAffiliation: nil,
                        locationPrivacy: .public_,
                        notificationPreferences: NotificationPreferences(),
                        lastActiveAt: Date(),
                        createdAt: Date(),
                        updatedAt: Date()
                    )
                }
                isAuthenticated = true
                print("✅ Auth state updated: authenticated")
            } else {
                print("⚠️ No active session")
                currentUser = nil
                isAuthenticated = false
            }
        } catch {
            print("❌ Auth check failed: \(error)")
            currentUser = nil
            isAuthenticated = false
        }
    }

    func signUp(email: String, password: String, username: String) async throws {
        let userAttributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)

        let result = try await Amplify.Auth.signUp(
            username: email,
            password: password,
            options: options
        )

        if case .confirmUser = result.nextStep {
            // User needs to confirm their email
            print("✅ Sign up successful. Please check email for confirmation code.")
        }
    }

    func confirmSignUp(email: String, code: String) async throws {
        let result = try await Amplify.Auth.confirmSignUp(
            for: email,
            confirmationCode: code
        )

        if result.isSignUpComplete {
            print("✅ Sign up confirmed")
        }
    }

    func signIn(email: String, password: String) async throws {
        print("🔐 Attempting sign in for: \(email)")

        let result = try await Amplify.Auth.signIn(
            username: email,
            password: password
        )

        print("🔐 Sign in result - isSignedIn: \(result.isSignedIn)")
        print("🔐 Sign in next step: \(result.nextStep)")

        if result.isSignedIn {
            print("✅ Sign in successful!")
            await checkAuthStatus()
        } else {
            print("⚠️ Sign in requires additional steps: \(result.nextStep)")
            // Throw error if sign in didn't complete
            throw NSError(
                domain: "AuthenticationService",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Sign in requires additional steps: \(result.nextStep)"]
            )
        }
    }

    func signOut() async throws {
        try await Amplify.Auth.signOut()
        ProfileService.shared.clearLocalStorage()
        currentUser = nil
        isAuthenticated = false
    }
}
