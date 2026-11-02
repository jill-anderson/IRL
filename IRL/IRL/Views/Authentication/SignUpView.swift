//
//  SignUpView.swift
//  IRL
//
//  Created by Jill Anderson on 2/11/26.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authService = AuthenticationService.shared

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    @State private var errorMessage: String?
    @State private var showingConfirmation = false
    @State private var confirmationCode = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 20)

                    VStack(spacing: 16) {
                        TextField("Username", text: $username)
                            .textContentType(.username)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)

                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)

                        SecureField("Password", text: $password)
                            .textContentType(.newPassword)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)

                        SecureField("Confirm Password", text: $confirmPassword)
                            .textContentType(.newPassword)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)

                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }

                        Button(action: handleSignUp) {
                            if authService.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign Up")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(authService.isLoading || !isValidForm)
                    }
                    .padding(.horizontal, 30)
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") { dismiss() })
            .alert("Confirm Email", isPresented: $showingConfirmation) {
                TextField("Confirmation Code", text: $confirmationCode)
                    .keyboardType(.numberPad)
                Button("Confirm") {
                    handleConfirmation()
                }
                Button("Cancel", role: .cancel) {
                    showingConfirmation = false
                }
            } message: {
                Text("Please enter the confirmation code sent to your email.")
            }
        }
    }

    private var isValidForm: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        !username.isEmpty &&
        password == confirmPassword &&
        password.count >= 8
    }

    private func handleSignUp() {
        errorMessage = nil

        guard password == confirmPassword else {
            errorMessage = "Passwords don't match"
            return
        }

        guard password.count >= 8 else {
            errorMessage = "Password must be at least 8 characters"
            return
        }

        Task {
            do {
                try await authService.signUp(
                    email: email,
                    password: password,
                    username: username
                )
                showingConfirmation = true
            } catch {
                errorMessage = "Sign up failed. Please try again."
                print("❌ Sign up error: \(error)")
            }
        }
    }

    private func handleConfirmation() {
        Task {
            do {
                try await authService.confirmSignUp(email: email, code: confirmationCode)
                // After confirmation, try to sign in
                try await authService.signIn(email: email, password: password)
                dismiss()
            } catch {
                errorMessage = "Confirmation failed. Please try again."
                print("❌ Confirmation error: \(error)")
            }
        }
    }
}

#Preview {
    SignUpView()
}
