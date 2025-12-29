//  PlantViewModel.swift
//  NurseryApp
//
//  Created by Sumit Kumar on 2025/10/24.
//  Copyright © 2025 YourCompany. All rights reserved.

import Foundation

final class PlantViewModel: ObservableObject {
    @Published private(set) var plants: [Plant] = []
    private let coreData: CoreDataManager

    init(coreDataManager: CoreDataManager = CoreDataManager.shared, sampleData: Bool = true) {
        self.coreData = coreDataManager

        // Load persisted plants from Core Data (synchronous snapshot from viewContext)
        plants = coreData.fetchPlants()

        // If no persisted plants and sampleData requested, seed a few sample entries.
        if plants.isEmpty && sampleData {
            seedSampleData()
        }

        // Listen for container.viewContext changes and refresh automatically.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contextDidChange(_:)),
                                               name: .NSManagedObjectContextObjectsDidChange,
                                               object: coreData.viewContext)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func contextDidChange(_ note: Notification) {
        // Refresh the simple array model on main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.plants = self.coreData.fetchPlants()
        }
    }

    func add(_ plant: Plant, completion: (() -> Void)? = nil) {
        // Optimistically insert locally so UI/tests see the new plant immediately
        DispatchQueue.main.async { [weak self] in
            self?.plants.append(plant)
        }

        // Persist asynchronously and refresh when done
        coreData.addPlant(plant) { [weak self] _ in
            DispatchQueue.main.async {
                self?.plants = self?.coreData.fetchPlants() ?? []
                completion?()
            }
        }
    }

    func remove(at offsets: IndexSet, completion: (() -> Void)? = nil) {
        // Capture IDs to remove and perform optimistic local deletion on main thread
        let idsToRemove = offsets.compactMap { plants[$0].id }
        DispatchQueue.main.async { [weak self] in
            self?.plants.remove(atOffsets: offsets)
        }

        let group = DispatchGroup()
        for id in idsToRemove {
            group.enter()
            coreData.removePlant(withId: id) { _ in
                group.leave()
            }
        }
        group.notify(queue: .main) { [weak self] in
            // Refresh from Core Data to ensure consistency
            self?.plants = self?.coreData.fetchPlants() ?? []
            completion?()
        }
    }

    func remove(plant: Plant, completion: (() -> Void)? = nil) {
        // Optimistic local remove
        DispatchQueue.main.async { [weak self] in
            self?.plants.removeAll(where: { $0.id == plant.id })
        }

        coreData.removePlant(withId: plant.id) { [weak self] _ in
            DispatchQueue.main.async {
                self?.plants = self?.coreData.fetchPlants() ?? []
                completion?()
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
    func toggleFavorite(plant: Plant, completion: (() -> Void)? = nil) {
        guard let idx = plants.firstIndex(where: { $0.id == plant.id }) else { return }
        plants[idx].isFavorite.toggle()
        // Persist the change and refresh when done
        coreData.updateFavorite(forId: plant.id, to: plants[idx].isFavorite) { [weak self] _ in
            DispatchQueue.main.async {
                self?.plants = self?.coreData.fetchPlants() ?? []
                completion?()
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
            coreData.addPlant(p) { _ in
                group.leave()
            }
        }
        group.notify(queue: .main) { [weak self] in
            self?.plants = self?.coreData.fetchPlants() ?? []
        }
    }
}
