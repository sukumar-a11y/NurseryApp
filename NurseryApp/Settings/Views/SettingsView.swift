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

#Preview {
    SettingsView()
}
