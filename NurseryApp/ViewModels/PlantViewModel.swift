//  PlantViewModel.swift
//  NurseryApp
//
//  Created by Sumit Kumar on 2025/10/24.
//  Copyright © 2025 YourCompany. All rights reserved.

import Foundation

final class PlantViewModel: ObservableObject {
    @Published private(set) var plants: [Plant] = []

    init(sampleData: Bool = true) {
        // Load persisted plants from Core Data
        plants = CoreDataManager.shared.fetchPlants()
    }

    func add(_ plant: Plant) {
        // Persist
        CoreDataManager.shared.addPlant(plant)
        // Refresh local list
        plants = CoreDataManager.shared.fetchPlants()
    }

    func remove(at offsets: IndexSet) {
        // Remove from in-memory array and persistent store
        let idsToRemove = offsets.compactMap { plants[$0].id }
        for id in idsToRemove {
            CoreDataManager.shared.removePlant(withId: id)
        }
        plants = CoreDataManager.shared.fetchPlants()
    }

    func remove(plant: Plant) {
        // Persist deletion
        CoreDataManager.shared.removePlant(withId: plant.id)
        // Refresh local list
        plants = CoreDataManager.shared.fetchPlants()
    }

    func move(from source: IndexSet, to destination: Int) {
        // Movement is purely UI-ordering; persist order if needed later
        plants.move(fromOffsets: source, toOffset: destination)
    }

    func plant(withId id: UUID) -> Plant? {
        plants.first { $0.id == id }
    }

    // Toggle favorite state for a specific plant
    func toggleFavorite(plant: Plant) {
        guard let idx = plants.firstIndex(where: { $0.id == plant.id }) else { return }
        plants[idx].isFavorite.toggle()
        // Persist the change
        CoreDataManager.shared.updateFavorite(forId: plant.id, to: plants[idx].isFavorite)
    }
}
