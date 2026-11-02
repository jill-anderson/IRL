//
//  SignUpView.swift
//  IRL
//
//  Created by Jill Anderson on 2/11/26.
//

import SwiftUI
import PhotosUI
import Amplify

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss

    @State private var currentStep: SignUpStep = .accountInfo
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var displayName = ""
    @State private var confirmationCode = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    // Profile Setup fields
    @State private var profileImage: UIImage?
    @State private var showingImagePicker = false
    @State private var gender: User.Gender = .preferNotToSay
    @State private var interestedIn: User.Gender = .female
    @State private var jobTitle = ""
    @State private var religiousAffiliation = ""
    @State private var galleryImages: [UIImage] = []
    @State private var showingGalleryPicker = false

    enum SignUpStep {
        case accountInfo
        case emailVerification
        case profileSetup
    }

    var body: some View {
        let _ = print("📱 SignUpView body rendered - currentStep: \(currentStep)")

        NavigationView {
            VStack {
                if currentStep == .accountInfo {
                    let _ = print("📱 Showing accountInfoView")
                    accountInfoView
                } else if currentStep == .emailVerification {
                    let _ = print("📱 Showing emailVerificationView")
                    emailVerificationView
                } else {
                    let _ = print("📱 Showing profileSetupView")
                    profileSetupView
                }
            }
            .navigationTitle(
                currentStep == .accountInfo ? "Create Account" :
                currentStep == .emailVerification ? "Verify Email" :
                "Complete Profile"
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel") {
                if currentStep == .profileSetup {
                    currentStep = .emailVerification
                } else if currentStep == .emailVerification {
                    currentStep = .accountInfo
                } else {
                    dismiss()
                }
            })
            .interactiveDismissDisabled(currentStep != .accountInfo || isLoading)
            .sheet(isPresented: $showingImagePicker) {
                ImagePickerView(image: $profileImage)
            }
            .sheet(isPresented: $showingGalleryPicker) {
                ImagePickerView(image: Binding(
                    get: { nil },
                    set: { newImage in
                        if let image = newImage, galleryImages.count < 6 {
                            galleryImages.append(image)
                        }
                    }
                ))
            }
            .onChange(of: currentStep) { oldValue, newValue in
                print("🔄 currentStep changed from \(oldValue) to \(newValue)")
            }
            .onAppear {
                print("👁️ SignUpView appeared")
            }
            .onDisappear {
                print("👋 SignUpView disappeared")
            }
        }
    }

    var accountInfoView: some View {
        let _ = print("📝 accountInfoView computed property called")

        return ScrollView {
            VStack(spacing: 20) {
                Text("Create your account")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                VStack(spacing: 16) {
                    TextField("Display Name", text: $displayName)
                        .textContentType(.name)
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

                    Text("Password must be at least 8 characters")
                        .font(.caption)
                        .foregroundColor(.gray)

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }

                    Button(action: handleSignUp) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Sign Up")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isValidForm ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(isLoading || !isValidForm)
                }
                .padding(.horizontal, 30)
            }
        }
    }

    var emailVerificationView: some View {
        let _ = print("📧 emailVerificationView computed property called")

        return VStack(spacing: 30) {
            Spacer()

            Image(systemName: "envelope.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)

            VStack(spacing: 10) {
                Text("Check your email")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("We sent a verification code to")
                    .foregroundColor(.gray)

                Text(email)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }

            VStack(spacing: 16) {
                TextField("Enter 6-digit code", text: $confirmationCode)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.title3)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .frame(maxWidth: 200)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Button(action: handleConfirmation) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Verify & Continue")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(confirmationCode.count == 6 ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isLoading || confirmationCode.count != 6)
                .padding(.horizontal, 30)

                Button(action: resendCode) {
                    Text("Resend Code")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding(.top, 10)
            }

            Spacer()
            Spacer()
        }
        .padding()
    }

    var profileSetupView: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 30) {
                    Text("Complete your profile")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 20)

                // Profile Photo (Required)
                VStack(spacing: 16) {
                    Text("Profile Photo (Required)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let image = profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.blue, lineWidth: 3))
                    } else {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 150))
                            .foregroundColor(.gray)
                    }

                    Button(action: { showingImagePicker = true }) {
                        Text(profileImage == nil ? "Add Photo" : "Change Photo")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 30)

                // Gender
                VStack(alignment: .leading, spacing: 12) {
                    Text("I am")
                        .font(.headline)
                    Picker("Gender", selection: $gender) {
                        Text("Male").tag(User.Gender.male)
                        Text("Female").tag(User.Gender.female)
                        Text("Non-binary").tag(User.Gender.nonBinary)
                        Text("Prefer not to say").tag(User.Gender.preferNotToSay)
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal, 30)

                // Interested In
                VStack(alignment: .leading, spacing: 12) {
                    Text("Looking for")
                        .font(.headline)
                    Picker("Interested In", selection: $interestedIn) {
                        Text("Men").tag(User.Gender.male)
                        Text("Women").tag(User.Gender.female)
                        Text("Everyone").tag(User.Gender.nonBinary)
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal, 30)

                // Optional Info
                VStack(spacing: 16) {
                    Text("Optional Information")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    TextField("Job Title (Optional)", text: $jobTitle)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    TextField("Religious Affiliation (Optional)", text: $religiousAffiliation)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)

                // Gallery Photos
                VStack(spacing: 16) {
                    Text("Gallery Photos (Optional, up to 6)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(0..<6, id: \.self) { index in
                            if index < galleryImages.count {
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: galleryImages[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))

                                    Button(action: {
                                        galleryImages.remove(at: index)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .background(Circle().fill(Color.black.opacity(0.6)))
                                            .padding(4)
                                    }
                                }
                            } else {
                                Button(action: { showingGalleryPicker = true }) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.systemGray6))
                                        .frame(width: 100, height: 100)
                                        .overlay(
                                            Image(systemName: "plus")
                                                .font(.title)
                                                .foregroundColor(.gray)
                                        )
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 30)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                Button(action: completeProfileSetup) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Complete Sign Up")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(profileImage != nil ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isLoading || profileImage == nil)
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
            }
            .frame(minHeight: geometry.size.height)
        }
        }
    }

    private var isValidForm: Bool {
        !displayName.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 8
    }

    private func handleSignUp() {
        print("🟢 handleSignUp called")
        errorMessage = nil

        guard password == confirmPassword else {
            errorMessage = "Passwords don't match"
            print("❌ Password mismatch")
            return
        }

        guard password.count >= 8 else {
            errorMessage = "Password must be at least 8 characters"
            print("❌ Password too short")
            return
        }

        print("🟢 About to call authService.signUp for email: \(email)")

        isLoading = true

        Task {
            do {
                print("🔵 Inside Task, about to call Amplify signUp")
                try await AuthenticationService.shared.signUp(
                    email: email,
                    password: password,
                    username: displayName
                )
                print("✅ Sign up successful! About to update state on MainActor")

                await MainActor.run {
                    print("🔵 On MainActor, setting currentStep to emailVerification")
                    withAnimation {
                        currentStep = .emailVerification
                    }
                    print("✅ Moved to step: \(currentStep)")
                    isLoading = false
                }
            } catch {
                print("❌ Sign up error: \(error)")
                print("❌ Error details: \(error.localizedDescription)")
                await MainActor.run {
                    errorMessage = "Sign up failed: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }

    private func handleConfirmation() {
        errorMessage = nil

        Task { @MainActor in
            isLoading = true

            do {
                try await AuthenticationService.shared.confirmSignUp(email: email, code: confirmationCode)
                // After successful confirmation, move to profile setup
                currentStep = .profileSetup
                isLoading = false
            } catch {
                errorMessage = "Invalid code. Please try again."
                print("❌ Confirmation error: \(error)")
                isLoading = false
            }
        }
    }

    private func completeProfileSetup() {
        errorMessage = nil

        guard profileImage != nil else {
            errorMessage = "Please add a profile photo"
            return
        }

        Task { @MainActor in
            isLoading = true

            do {
                // Sign in first to get the user ID
                try await AuthenticationService.shared.signIn(email: email, password: password)

                // Get the current user ID
                let authUser = try await Amplify.Auth.getCurrentUser()
                print("✅ Signed in, now creating profile for user: \(authUser.userId)")

                // Create and save the user profile
                let user = try await ProfileService.shared.createUserProfile(
                    userId: authUser.userId,
                    email: email,
                    displayName: displayName,
                    gender: gender,
                    interestedIn: interestedIn,
                    jobTitle: jobTitle,
                    religiousAffiliation: religiousAffiliation,
                    profileImage: profileImage,
                    galleryImages: galleryImages
                )

                // Update the auth service with the new user profile
                AuthenticationService.shared.currentUser = user
                AuthenticationService.shared.isAuthenticated = true

                print("✅ Profile setup complete!")
                dismiss()
            } catch {
                errorMessage = "Failed to complete profile: \(error.localizedDescription)"
                print("❌ Profile setup error: \(error)")
                isLoading = false
            }
        }
    }

    private func resendCode() {
        Task {
            do {
                // TODO: Implement resend code via Amplify.Auth.resendSignUpCode()
                errorMessage = "Code resent! Check your email."
            } catch {
                errorMessage = "Failed to resend code"
            }
        }
    }
}

// MARK: - Image Picker Component

fileprivate struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType = .photoLibrary

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView

        init(_ parent: ImagePickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    SignUpView()
}
