//
//  IRLApp.swift
//  IRL
//
//  Created by Jill Anderson on 2/9/26.
//

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin
import AWSS3StoragePlugin

@main
struct IRLApp: App {
    @StateObject private var authService = AuthenticationService.shared

    init() {
        print("🚀🚀🚀 APP STARTING 🚀🚀🚀")
        configureAmplify()
        print("🚀🚀🚀 APP INIT COMPLETE 🚀🚀🚀")
    }

    var body: some Scene {
        let _ = print("🏛️ IRLApp body rendered - isLoading: \(authService.isLoading), isAuthenticated: \(authService.isAuthenticated)")

        return WindowGroup {
            // Only show loading spinner on initial app launch, not during sign-up flow
            if authService.isAuthenticated {
                let _ = print("🏛️ Showing MainTabView")
                // User is logged in, show main app
                MainTabView()
            } else {
                let _ = print("🏛️ Showing LoginView")
                // User is not logged in, show login
                LoginView()
            }
        }
    }

    private func configureAmplify() {
        do {
            // Add plugins
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSAPIPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())

            // Configure Amplify
            try Amplify.configure()

            print("✅ Amplify configured successfully")
        } catch {
            print("❌ Failed to configure Amplify: \(error)")
        }
    }
}
