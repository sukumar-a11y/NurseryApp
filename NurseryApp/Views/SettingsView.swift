//  SettingsView.swift
//  NurseryApp
//
//  Created by Sumit Kumar on 2025/10/24.
//  Copyright © 2025 YourCompany. All rights reserved.

import SwiftUI

struct SettingsView: View {
    @AppStorage("username") private var username: String = "Your name"
    @AppStorage("userEmail") private var userEmail: String = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    // Using ShareLink to share a simple message / app URL
                    if let url = URL(string: "https://example.com/nurseryapp") {
                        ShareLink(item: url, subject: Text("Check out NurseryApp"), message: Text("I'm using NurseryApp to track my plants — give it a try!")) {
                            Label("Share App", systemImage: "square.and.arrow.up")
                        }
                    } else {
                        Button {
                            // Fallback: do nothing
                        } label: {
                            Label("Share App", systemImage: "square.and.arrow.up")
                        }
                    }
                }

                Section(header: Text("Account")) {
                    NavigationLink(value: Destination.editProfile) {
                        Label("Edit Profile", systemImage: "person.crop.circle")
                    }
                }

                Section(header: Text("About")) {
                    NavigationLink(value: Destination.about) {
                        Label("About Us", systemImage: "info.circle")
                    }
                }
            }
            .navigationDestination(for: Destination.self) { dest in
                switch dest {
                case .about:
                    AboutView()
                case .editProfile:
                    EditProfileView()
                }
            }
            .navigationTitle("Settings")
            .listStyle(.insetGrouped)
        }
    }

    enum Destination: Hashable {
        case about
        case editProfile
    }
}

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("NurseryApp")
                    .font(.largeTitle)
                    .bold()

                Text("Version 1.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("About us")
                    .font(.headline)

                Text("NurseryApp helps you keep track of your houseplants, watering schedules, and plant notes. Built with love.")
                    .font(.body)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("About Us")
    }
}

struct EditProfileView: View {
    @AppStorage("username") private var username: String = "Your name"
    @AppStorage("userEmail") private var userEmail: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section(header: Text("Name")) {
                TextField("Name", text: $username)
            }

            Section(header: Text("Email")) {
                TextField("Email", text: $userEmail)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
            }

            Section {
                Button(action: {
                    // Changes are already persisted to AppStorage; just dismiss
                    dismiss()
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("Edit Profile")
    }
}

#Preview {
    SettingsView()
}
