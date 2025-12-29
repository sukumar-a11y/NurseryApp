//
//  EditProfileView.swift
//  NurseryApp
//
//  Created by Sumit Kumar on 29/10/25.
//

import SwiftUI

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
    EditProfileView()
}
