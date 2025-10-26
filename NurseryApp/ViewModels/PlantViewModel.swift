//  PlantViewModel.swift
//  NurseryApp
//
//  Created by Sumit Kumar on 2025/10/24.
//  Copyright © 2025 YourCompany. All rights reserved.

import Foundation

final class PlantViewModel: ObservableObject {
    @Published private(set) var plants: [Plant] = []

    init(sampleData: Bool = true) {
        // Load persisted plants from Core Data (synchronous snapshot from viewContext)
        plants = CoreDataManager.shared.fetchPlants()

        // If no persisted plants and sampleData requested, seed a few sample entries.
        if plants.isEmpty && sampleData {
            seedSampleData()
        }

        // Optionally, listen for container.viewContext changes and refresh automatically.
        // The CoreDataManager configures `automaticallyMergesChangesFromParent` so
        // background saves are merged into viewContext, but we still refresh our
        // plain-array representation when the context changes.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contextDidChange(_:)),
                                               name: .NSManagedObjectContextObjectsDidChange,
                                               object: CoreDataManager.shared.viewContext)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func contextDidChange(_ note: Notification) {
        // Refresh the simple array model on main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.plants = CoreDataManager.shared.fetchPlants()
        }
    }

    func add(_ plant: Plant) {
        // Persist asynchronously and refresh when done
        CoreDataManager.shared.addPlant(plant) { [weak self] _ in
            DispatchQueue.main.async {
                self?.plants = CoreDataManager.shared.fetchPlants()
            }
        }
    }

    func remove(at offsets: IndexSet) {
        // Remove from persistent store for each selected index
        let idsToRemove = offsets.compactMap { plants[$0].id }
        let group = DispatchGroup()
        for id in idsToRemove {
            group.enter()
            CoreDataManager.shared.removePlant(withId: id) { _ in
                group.leave()
            }
        }
        group.notify(queue: .main) { [weak self] in
            self?.plants = CoreDataManager.shared.fetchPlants()
        }
    }

    func remove(plant: Plant) {
        CoreDataManager.shared.removePlant(withId: plant.id) { [weak self] _ in
            DispatchQueue.main.async {
                self?.plants = CoreDataManager.shared.fetchPlants()
            }
        }
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
        // Persist the change and refresh when done
        CoreDataManager.shared.updateFavorite(forId: plant.id, to: plants[idx].isFavorite) { [weak self] _ in
            DispatchQueue.main.async {
                self?.plants = CoreDataManager.shared.fetchPlants()
            }
        }
    }

    // MARK: - Sample data seeding
    private func seedSampleData() {
        let samples: [Plant] = [
            Plant(name: "Monstera", species: "Monstera deliciosa", description: "Swiss cheese vine", emoji: "🪴"),
            Plant(name: "Snake Plant", species: "Sansevieria", description: "Tough indoor plant", emoji: "🌿"),
            Plant(name: "Fiddle Leaf Fig", species: "Ficus lyrata", description: "Large-leaf indoor tree", emoji: "🌳")
        ]

        let group = DispatchGroup()
        for p in samples {
            group.enter()
            CoreDataManager.shared.addPlant(p) { _ in
                group.leave()
            }
        }
        group.notify(queue: .main) { [weak self] in
            self?.plants = CoreDataManager.shared.fetchPlants()
        }
    }
}
