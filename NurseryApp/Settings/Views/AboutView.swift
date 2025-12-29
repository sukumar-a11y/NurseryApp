//
//  AboutView.swift
//  NurseryApp
//
//  Created by Sumit Kumar on 29/10/25.
//

import SwiftUI

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

#Preview {
    AboutView()
}
