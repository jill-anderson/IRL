//
//  LoginView.swift
//  IRL
//
//  Created by Jill Anderson on 2/11/26.
//

import SwiftUI
import Amplify

struct LoginView: View {
    @StateObject private var authService = AuthenticationService.shared
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    @State private var errorMessage: String?
    @State private var showingErrorAlert = false
    @State private var diagnosticMessage = "Tap to check Amplify config"
    @State private var isLoggingIn = false
    @State private var debugLog: [String] = []

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Logo/Title
                VStack(spacing: 8) {
                    Text("IRL - TEST VERSION")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.blue)
                    Text("Meet people in real life")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 60)

                Spacer()

                // Login Form
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    Button(action: handleLogin) {
                        if isLoggingIn {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Log In")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(isLoggingIn || email.isEmpty || password.isEmpty)
                }
                .padding(.horizontal, 30)

                // Diagnostic button - BIG ORANGE BUTTON
                Button(action: checkAmplifyConfig) {
                    Text(diagnosticMessage)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                .padding(.top, 20)

                // Debug log display
                if !debugLog.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Debug Log:")
                            .font(.caption)
                            .fontWeight(.bold)
                        ForEach(debugLog.indices, id: \.self) { index in
                            Text(debugLog[index])
                                .font(.system(size: 10))
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color.black)
                    .cornerRadius(8)
                    .padding(.horizontal)
                }

                // Auth status display
                VStack {
                    Text("isAuthenticated: \(authService.isAuthenticated ? "YES" : "NO")")
                        .font(.caption)
                        .foregroundColor(.purple)
                    Text("isLoading: \(authService.isLoading ? "YES" : "NO")")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
                .padding(.top, 10)

                Spacer()

                // Sign Up Button
                Button(action: { showingSignUp = true }) {
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.gray)
                        Text("Sign Up")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSignUp) {
                SignUpView()
            }
            .alert("Login Error", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) {
                    showingErrorAlert = false
                }
            } message: {
                Text(errorMessage ?? "An unknown error occurred")
            }
        }
    }

    private func checkAmplifyConfig() {
        // Always show alert to test if alerts work
        errorMessage = "TEST ALERT - If you see this, alerts are working!"
        showingErrorAlert = true
        diagnosticMessage = "Tapped!"
    }

    private func handleLogin() {
        debugLog = []  // Clear previous log
        errorMessage = nil
        showingErrorAlert = false
        isLoggingIn = true

        debugLog.append("1️⃣ Login started")

        Task { @MainActor in
            defer {
                isLoggingIn = false
                debugLog.append("8️⃣ isLoggingIn set to false")
            }

            debugLog.append("2️⃣ About to call signIn")

            do {
                try await authService.signIn(email: email, password: password)

                debugLog.append("3️⃣ signIn completed without error")
                debugLog.append("4️⃣ isAuthenticated=\(authService.isAuthenticated)")

                // If we get here, sign in succeeded!
                errorMessage = "✅ SUCCESS! isAuth=\(authService.isAuthenticated)"
                showingErrorAlert = true

                debugLog.append("5️⃣ Set showingErrorAlert=true")

                // Wait a bit to see if alert shows
                try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1 seconds
                debugLog.append("6️⃣ After sleep, alert should be visible")

            } catch let error as AuthError {
                debugLog.append("7️⃣ AuthError caught: \(error.errorDescription ?? "no description")")
                errorMessage = error.errorDescription ?? "Login failed: \(error.localizedDescription)"
                showingErrorAlert = true
            } catch {
                debugLog.append("7️⃣ Generic error caught: \(error.localizedDescription)")
                errorMessage = "Login failed: \(error.localizedDescription)"
                showingErrorAlert = true
            }
        }
    }
}

#Preview {
    LoginView()
}
