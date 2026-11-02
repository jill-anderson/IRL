//
//  MainTabView.swift
//  IRL
//
//  Created by Jill Anderson on 2/11/26.
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject var authService = AuthenticationService.shared

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
                    // Profile Photo
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 120))
                        .foregroundColor(.gray)
                        .padding(.top, 20)

                    if let user = authService.currentUser {
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

                        // Gallery Photos
                        if let galleryUrls = user.galleryPhotoUrls, !galleryUrls.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Photos")
                                    .font(.headline)
                                    .padding(.horizontal, 30)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(galleryUrls, id: \.self) { _ in
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color(.systemGray5))
                                                .frame(width: 100, height: 100)
                                                .overlay(
                                                    Image(systemName: "photo")
                                                        .foregroundColor(.gray)
                                                )
                                        }
                                    }
                                    .padding(.horizontal, 30)
                                }
                            }
                            .padding(.top, 10)
                        }

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
                            InfoRow(label: "Location Privacy", value: user.locationPrivacy.displayName)
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
    @State private var locationPrivacy: User.LocationPrivacy = .public_

    var body: some View {
        NavigationView {
            Form {
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

                Section("Privacy Settings") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Location Privacy")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Picker("Location Privacy", selection: $locationPrivacy) {
                            ForEach([User.LocationPrivacy.public_, .friendsOnly, .privateLocation], id: \.self) { privacy in
                                Text(privacy.displayName).tag(privacy)
                            }
                        }
                        .pickerStyle(.segmented)

                        Text(locationPrivacy.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                    .padding(.vertical, 8)
                }

                Section {
                    Button("Save Changes") {
                        saveProfile()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() }
            )
            .onAppear {
                if let user = authService.currentUser {
                    displayName = user.displayName
                    bio = user.bio ?? ""
                    gender = user.gender
                    interestedIn = user.interestedIn ?? .female
                    jobTitle = user.jobTitle ?? ""
                    religiousAffiliation = user.religiousAffiliation ?? ""
                    locationPrivacy = user.locationPrivacy
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

        Task {
            do {
                try await ProfileService.shared.updateUserProfile(
                    userId: userId,
                    displayName: displayName,
                    bio: bio.isEmpty ? nil : bio,
                    gender: gender,
                    interestedIn: interestedIn,
                    jobTitle: jobTitle,
                    religiousAffiliation: religiousAffiliation,
                    locationPrivacy: locationPrivacy
                )
                print("✅ Profile saved successfully")
                dismiss()
            } catch {
                print("❌ Failed to save profile: \(error)")
                // TODO: Show error alert to user
                dismiss()
            }
        }
    }
}

#Preview {
    MainTabView()
}
