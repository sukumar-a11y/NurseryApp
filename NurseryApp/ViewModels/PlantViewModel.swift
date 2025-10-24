//  PlantViewModel.swift
//  NurseryApp
//
//  Created by Sumit Kumar on 2025/10/24.
//  Copyright © 2025 YourCompany. All rights reserved.

import Foundation

final class PlantViewModel: ObservableObject {
    @Published private(set) var plants: [Plant] = []

    init(sampleData: Bool = true) {
        if sampleData {
            plants = [
                Plant(name: "Monstera Deliciosa", species: "Monstera deliciosa", description: "Popular houseplant with split leaves.", emoji: "🪴"),
                Plant(name: "Snake Plant", species: "Sansevieria trifasciata", description: "Very tolerant, great for beginners.", emoji: "🌿"),
                Plant(name: "Peace Lily", species: "Spathiphyllum", description: "Produces white flowers; likes humidity.", emoji: "🌸"),
                Plant(name: "Fiddle Leaf Fig", species: "Ficus lyrata", description: "Large glossy leaves, likes bright light.", emoji: "🎋"),
                Plant(name: "Pothos", species: "Epipremnum aureum", description: "Trailing vine, very easy to care for.", emoji: "🍃"),
                Plant(name: "ZZ Plant", species: "Zamioculcas zamiifolia", description: "Low light tolerant, slow grower.", emoji: "🌱"),
                Plant(name: "Aloe Vera", species: "Aloe barbadensis miller", description: "Succulent used for skin remedies.", emoji: "🌵"),
                Plant(name: "Succulent Mix", species: nil, description: "Small pot with assorted succulents.", emoji: "🪴"),
                Plant(name: "Spider Plant", species: "Chlorophytum comosum", description: "Easy hanging plant with pups.", emoji: "🕸️"),
            ]
        }
    }

    func add(_ plant: Plant) {
        plants.append(plant)
    }

    func remove(at offsets: IndexSet) {
        plants.remove(atOffsets: offsets)
    }

    func remove(plant: Plant) {
        if let idx = plants.firstIndex(where: { $0.id == plant.id }) {
            plants.remove(at: idx)
        }
    }

    func move(from source: IndexSet, to destination: Int) {
        plants.move(fromOffsets: source, toOffset: destination)
    }

    func plant(withId id: UUID) -> Plant? {
        plants.first { $0.id == id }
    }
}
