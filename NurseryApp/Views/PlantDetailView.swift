//  PlantDetailView.swift
//  NurseryApp
//
//  Created by Sumit Kumar on 2025/10/24.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import SwiftUI

struct PlantDetailView: View {
    let plant: Plant
    var namespace: Namespace.ID
    var onClose: (() -> Void)? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(LinearGradient(colors: [Color.green.opacity(0.15), Color.green.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 220)
                        .matchedGeometryEffect(id: "card-\(plant.id.uuidString)", in: namespace)

                    HStack(spacing: 16) {
                        Text(plant.emoji ?? "🪴")
                            .font(.system(size: 72))
                            .matchedGeometryEffect(id: "emoji-\(plant.id.uuidString)", in: namespace)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(plant.name)
                                .font(.title)
                                .bold()
                                .matchedGeometryEffect(id: "title-\(plant.id.uuidString)", in: namespace)

                            if let species = plant.species {
                                Text(species)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .matchedGeometryEffect(id: "species-\(plant.id.uuidString)", in: namespace)
                            }
                        }
                        Spacer()
                    }
                    .padding()

                    // Close button
                    Button(action: {
                        onClose?()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.black.opacity(0.6))
                            .padding(8)
                    }
                    .buttonStyle(.plain)
                    .padding(8)
                }
                .padding(.horizontal)

                if let description = plant.description, !description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.headline)
                        Text(description)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.top)
        }
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(edges: .bottom)
        .navigationTitle(plant.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Replace #Preview macro with a standard PreviewProvider to supply a Namespace for matchedGeometryEffect
struct PlantDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }

    struct PreviewWrapper: View {
        @Namespace private var ns
        var body: some View {
            PlantDetailView(
                plant: Plant(name: "Monstera", species: "Monstera deliciosa", description: "Sample description about the Monstera plant. It likes bright, indirect light.", emoji: "🪴"),
                namespace: ns
            ) {
                // preview close
            }
        }
    }
}
