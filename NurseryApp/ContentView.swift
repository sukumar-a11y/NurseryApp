//
//  ContentView.swift
//  NurseryApp
//
//  Created by Sumit Kumar on 21/10/25.
//

import SwiftUI

// Top-level ContentView is now a TabView with two tabs: Plants and Settings
struct ContentView: View {
    var body: some View {
        TabView {
            PlantListView()
                .tabItem {
                    Label("Plants", systemImage: "leaf")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

// The original ContentView became PlantListView (keeps the same behavior)
struct PlantListView: View {
    @StateObject private var viewModel = PlantViewModel()
    @State private var showingAdd = false

    // Namespace & selected plant for matched geometry animation
    @Namespace private var namespace
    @State private var selectedPlant: Plant? = nil

    private let columns = [GridItem(.adaptive(minimum: 140), spacing: 16)]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text("My Garden")
                                .font(.largeTitle)
                                .bold()
                            Text("All your plants in one place")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top)

                        if viewModel.plants.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "leaf.circle.fill")
                                    .font(.system(size: 72))
                                    .foregroundStyle(Color.green)
                                Text("No plants yet")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                Text("Tap + to add your first plant.")
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        } else {
                            // Calculate fixed square cell size to ensure every cell is identical
                            let horizontalPadding: CGFloat = 24
                            let spacing: CGFloat = 16
                            let desiredCell: CGFloat = 160 // you can tweak this to change cell size

                            // Screen width based calculation (keeps it simple and avoids GeometryReader in ScrollView)
                            let totalWidth = UIScreen.main.bounds.width - horizontalPadding * 2
                            let columnsCount = max(1, Int((totalWidth + spacing) / (desiredCell + spacing)))
                            let cellSize = (totalWidth - CGFloat(columnsCount - 1) * spacing) / CGFloat(columnsCount)
                            let gridItems = Array(repeating: GridItem(.fixed(cellSize), spacing: spacing), count: columnsCount)

                            LazyVGrid(columns: gridItems, spacing: spacing) {
                                ForEach(viewModel.plants) { plant in
                                    PlantCardView(plant: plant, namespace: namespace)
                                        .frame(width: cellSize, height: cellSize)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                viewModel.remove(plant: plant)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                        .onTapGesture {
                                            withAnimation(.interactiveSpring(response: 0.45, dampingFraction: 0.8, blendDuration: 0.25)) {
                                                selectedPlant = plant
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal, horizontalPadding)
                        }

                        Spacer(minLength: 24)
                    }
                }

                // Overlay detail when a plant is selected
                if let plant = selectedPlant {
                    ZStack {
                        // Dimmed background
                        Color.black.opacity(0.35)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selectedPlant = nil
                                }
                            }

                        // Place the detail view using the same namespace so matchedGeometryEffect works
                        PlantDetailView(plant: plant, namespace: namespace) {
                            withAnimation(.spring()) { selectedPlant = nil }
                        }
                        .zIndex(1)
                        .padding(.horizontal, 12)
                        .transition(.opacity.combined(with: .scale))
                    }
                    .animation(.spring(), value: selectedPlant)
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // nothing here to keep header clean, but could add filters
                    EmptyView()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddPlantView { plant in
                    viewModel.add(plant)
                }
            }
            .navigationDestination(for: Plant.self) { plant in
                // keep existing navigation path for deep-linking; if using zoom overlay the regular nav is still available
                PlantDetailView(plant: plant, namespace: namespace) {}
            }
        }
    }
}

// Small card view used in the grid
private struct PlantCardView: View {
    let plant: Plant
    var namespace: Namespace.ID

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(plant.emoji ?? "🪴")
                    .font(.system(size: 40))
                    .matchedGeometryEffect(id: "emoji-\(plant.id.uuidString)", in: namespace)
                Spacer()
            }

            Text(plant.name)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
                .matchedGeometryEffect(id: "title-\(plant.id.uuidString)", in: namespace)

            if let species = plant.species {
                Text(species)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .matchedGeometryEffect(id: "species-\(plant.id.uuidString)", in: namespace)
            }

            Spacer() // push content to top so card height remains consistent
        }
        .padding()
        .aspectRatio(1, contentMode: .fit) // make each cell square: height equals its width
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(LinearGradient(colors: [Color.green.opacity(0.18), Color.green.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .matchedGeometryEffect(id: "card-\(plant.id.uuidString)", in: namespace)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.green.opacity(0.18), lineWidth: 0.5)
                .matchedGeometryEffect(id: "cardstroke-\(plant.id.uuidString)", in: namespace)
        )
    }
}

// Standard previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
