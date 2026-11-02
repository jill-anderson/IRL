//
//  MainTabView.swift
//  IRL
//
//  Created by Jill Anderson on 2/11/26.
//

import SwiftUI
import Amplify

struct MainTabView: View {
    @StateObject private var authService = AuthenticationService.shared

    var body: some View {
        TabView {
            // Nearby Locations Tab
            NearbyView()
                .tabItem {
                    Label("Nearby", systemImage: "location.fill")
                }

            // Check-ins Tab
            CheckInsView()
                .tabItem {
                    Label("Check-ins", systemImage: "checkmark.circle.fill")
                }

            // Messages Tab
            MessagesView()
                .tabItem {
                    Label("Messages", systemImage: "message.fill")
                }

            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

// Placeholder views for each tab
struct NearbyView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "location.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .padding()
                Text("Nearby Locations")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Discover bars and restaurants near you")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .navigationTitle("Nearby")
        }
    }
}

struct CheckInsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .padding()
                Text("Your Check-ins")
                    .font(.title)
                    .fontWeight(.bold)
                Text("View your recent check-ins")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .navigationTitle("Check-ins")
        }
    }
}

struct MessagesView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "message.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)
                    .padding()
                Text("Messages")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Chat with people you've met")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .navigationTitle("Messages")
        }
    }
}

struct ProfileView: View {
    @ObservedObject var authService = AuthenticationService.shared
    @State private var showingEditProfile = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let user = authService.currentUser {
                        // Profile Photo (clickable to edit)
                        Button(action: { showingEditProfile = true }) {
                            if let profilePhotoUrl = user.profilePhotoUrl,
                               let url = URL(string: profilePhotoUrl) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 120, height: 120)
                                }
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 120))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top, 20)

                        // Display Name
                        Text(user.displayName.isEmpty ? "Set your name" : user.displayName)
                            .font(.title)
                            .fontWeight(.bold)

                        // Email
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        // Bio
                        if let bio = user.bio, !bio.isEmpty {
                            Text(bio)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                                .padding(.top, 5)
                        }

                        // Edit Profile Button
                        Button(action: { showingEditProfile = true }) {
                            Text("Edit Profile")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 10)

                        // Dating Profile Info
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Dating Profile")
                                .font(.headline)
                                .padding(.horizontal, 30)

                            InfoRow(label: "Gender", value: user.gender.displayName)
                            if let interestedIn = user.interestedIn {
                                InfoRow(label: "Looking for", value: interestedIn.displayName)
                            }
                            if let jobTitle = user.jobTitle, !jobTitle.isEmpty {
                                InfoRow(label: "Job Title", value: jobTitle)
                            }
                            if let religious = user.religiousAffiliation, !religious.isEmpty {
                                InfoRow(label: "Religion", value: religious)
                            }
                        }
                        .padding(.top, 20)

                        // Account Info Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Account Info")
                                .font(.headline)
                                .padding(.horizontal, 30)

                            InfoRow(label: "Username", value: user.username)
                        }
                        .padding(.top, 20)
                    }

                    Spacer()

                    // Sign Out Button
                    Button(action: handleSignOut) {
                        Text("Sign Out")
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 30)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .onAppear {
                refreshProfile()
            }
        }
    }

    private func refreshProfile() {
        guard let userId = authService.currentUser?.id else { return }

        Task {
            do {
                if let user = try await ProfileService.shared.getUserProfile(userId: userId) {
                    authService.currentUser = user
                    print("✅ Profile refreshed: \(user.displayName)")
                }
            } catch {
                print("❌ Failed to refresh profile: \(error)")
            }
        }
    }

    private func handleSignOut() {
        Task {
            do {
                try await authService.signOut()
            } catch {
                print("❌ Sign out error: \(error)")
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 30)
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var authService = AuthenticationService.shared

    @State private var displayName = ""
    @State private var bio = ""
    @State private var gender: User.Gender = .preferNotToSay
    @State private var interestedIn: User.Gender = .female
    @State private var jobTitle = ""
    @State private var religiousAffiliation = ""
    @State private var showingImagePicker = false
    @State private var showingGalleryPicker = false
    @State private var profileImage: UIImage?
    @State private var galleryImages: [UIImage] = []
    @State private var isUploading = false

    var body: some View {
        NavigationView {
            Form {
                Section("Profile Photo") {
                    Button(action: { showingImagePicker = true }) {
                        HStack {
                            if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Text("Change Photo")
                                .foregroundColor(.blue)
                        }
                    }
                }

                Section("Gallery Photos") {
                    Button(action: { showingGalleryPicker = true }) {
                        HStack {
                            Text("Add Photos")
                            Spacer()
                            Text("\(galleryImages.count) selected")
                                .foregroundColor(.gray)
                        }
                    }

                    if !galleryImages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(galleryImages.indices, id: \.self) { index in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: galleryImages[index])
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))

                                        Button(action: {
                                            galleryImages.remove(at: index)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.white)
                                                .background(Color.black.opacity(0.6))
                                                .clipShape(Circle())
                                        }
                                        .padding(4)
                                    }
                                }
                            }
                        }
                    }
                }

                Section("Basic Information") {
                    TextField("Display Name", text: $displayName)
                    TextField("Bio", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Dating Profile") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("I am")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Picker("Gender", selection: $gender) {
                            Text("Male").tag(User.Gender.male)
                            Text("Female").tag(User.Gender.female)
                            Text("Non-binary").tag(User.Gender.nonBinary)
                            Text("Prefer not to say").tag(User.Gender.preferNotToSay)
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.vertical, 8)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Looking for")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Picker("Interested In", selection: $interestedIn) {
                            Text("Men").tag(User.Gender.male)
                            Text("Women").tag(User.Gender.female)
                            Text("Everyone").tag(User.Gender.nonBinary)
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.vertical, 8)

                    TextField("Job Title", text: $jobTitle)
                    TextField("Religious Affiliation", text: $religiousAffiliation)
                }

                Section {
                    Button(action: { saveProfile() }) {
                        if isUploading {
                            HStack {
                                ProgressView()
                                Text("Saving...")
                            }
                        } else {
                            Text("Save Changes")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(isUploading)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() }
            )
            .sheet(isPresented: $showingImagePicker) {
                ImagePickerView(image: $profileImage, sourceType: .photoLibrary)
            }
            .sheet(isPresented: $showingGalleryPicker) {
                MultiImagePickerView(images: $galleryImages)
            }
            .onAppear {
                if let user = authService.currentUser {
                    displayName = user.displayName
                    bio = user.bio ?? ""
                    gender = user.gender
                    interestedIn = user.interestedIn ?? .female
                    jobTitle = user.jobTitle ?? ""
                    religiousAffiliation = user.religiousAffiliation ?? ""
                }
            }
        }
    }

    private func saveProfile() {
        guard let userId = authService.currentUser?.id else {
            print("❌ No user ID found")
            dismiss()
            return
        }

        isUploading = true

        Task {
            do {
                // Upload profile photo if changed
                var profilePhotoUrl: String? = authService.currentUser?.profilePhotoUrl
                if let profileImage = profileImage {
                    profilePhotoUrl = try await uploadProfilePhoto(userId: userId, image: profileImage)
                }

                // Upload gallery photos if any
                var galleryPhotoUrls: [String] = authService.currentUser?.galleryPhotoUrls ?? []
                if !galleryImages.isEmpty {
                    for (index, image) in galleryImages.enumerated() {
                        let url = try await uploadGalleryPhoto(userId: userId, index: galleryPhotoUrls.count + index, image: image)
                        galleryPhotoUrls.append(url)
                    }
                }

                try await ProfileService.shared.updateUserProfile(
                    userId: userId,
                    displayName: displayName,
                    bio: bio.isEmpty ? nil : bio,
                    gender: gender,
                    interestedIn: interestedIn,
                    jobTitle: jobTitle,
                    religiousAffiliation: religiousAffiliation,
                    locationPrivacy: nil,
                    profilePhotoUrl: profilePhotoUrl,
                    galleryPhotoUrls: galleryPhotoUrls.isEmpty ? nil : galleryPhotoUrls
                )

                print("✅ Profile saved successfully")
                isUploading = false
                dismiss()
            } catch {
                print("❌ Failed to save profile: \(error)")
                isUploading = false
                dismiss()
            }
        }
    }

    private func uploadProfilePhoto(userId: String, image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ProfileService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
        }

        let key = "profiles/\(userId)/profile.jpg"
        print("📤 Uploading profile photo to S3: \(key)")

        let uploadTask = Amplify.Storage.uploadData(
            key: key,
            data: imageData,
            options: .init(contentType: "image/jpeg")
        )

        _ = try await uploadTask.value
        let urlResult = try await Amplify.Storage.getURL(key: key)
        return urlResult.absoluteString
    }

    private func uploadGalleryPhoto(userId: String, index: Int, image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ProfileService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
        }

        let key = "profiles/\(userId)/gallery/\(index).jpg"
        print("📤 Uploading gallery photo to S3: \(key)")

        let uploadTask = Amplify.Storage.uploadData(
            key: key,
            data: imageData,
            options: .init(contentType: "image/jpeg")
        )

        _ = try await uploadTask.value
        let urlResult = try await Amplify.Storage.getURL(key: key)
        return urlResult.absoluteString
    }
}

// MARK: - Image Picker Components

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

fileprivate struct MultiImagePickerView: UIViewControllerRepresentable {
    @Binding var images: [UIImage]

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: MultiImagePickerView

        init(_ parent: MultiImagePickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.images.append(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    MainTabView()
}
