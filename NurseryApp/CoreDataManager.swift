// CoreDataManager.swift
// NurseryApp
//
// Created by Sumit Kumar on 2025/10/24.
// Module: NurseryApp

import Foundation
import CoreData

/// A lightweight programmatic Core Data stack for the NurseryApp.
/// Creates a model at runtime with a single entity `PlantEntity` and attributes
/// matching the `Plant` struct.
final class CoreDataManager {
    static let shared = CoreDataManager()

    let container: NSPersistentContainer
    var context: NSManagedObjectContext { container.viewContext }

    private init(inMemory: Bool = false) {
        let model = CoreDataManager.makeModel()
        container = NSPersistentContainer(name: "NurseryAppModel", managedObjectModel: model)

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }

        // Keep context changes pushed to disk quicker
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    // Build model programmatically so we don't need an .xcdatamodeld file
    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // Attributes for PlantEntity
        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .UUIDAttributeType
        id.isOptional = false

        let name = NSAttributeDescription()
        name.name = "name"
        name.attributeType = .stringAttributeType
        name.isOptional = false

        let species = NSAttributeDescription()
        species.name = "species"
        species.attributeType = .stringAttributeType
        species.isOptional = true

        let plantDescription = NSAttributeDescription()
        plantDescription.name = "plantDescription"
        plantDescription.attributeType = .stringAttributeType
        plantDescription.isOptional = true

        let emoji = NSAttributeDescription()
        emoji.name = "emoji"
        emoji.attributeType = .stringAttributeType
        emoji.isOptional = true

        let isFavorite = NSAttributeDescription()
        isFavorite.name = "isFavorite"
        isFavorite.attributeType = .booleanAttributeType
        isFavorite.isOptional = false
        isFavorite.defaultValue = false

        let entity = NSEntityDescription()
        entity.name = "PlantEntity"
        entity.managedObjectClassName = "NSManagedObject"
        entity.properties = [id, name, species, plantDescription, emoji, isFavorite]

        model.entities = [entity]
        return model
    }

    // MARK: - CRUD helpers

    func fetchPlants() -> [Plant] {
        let req = NSFetchRequest<NSManagedObject>(entityName: "PlantEntity")
        req.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            let results = try context.fetch(req)
            return results.compactMap { obj in
                guard let id = obj.value(forKey: "id") as? UUID,
                      let name = obj.value(forKey: "name") as? String else { return nil }
                let species = obj.value(forKey: "species") as? String
                let desc = obj.value(forKey: "plantDescription") as? String
                let emoji = obj.value(forKey: "emoji") as? String
                let fav = obj.value(forKey: "isFavorite") as? Bool ?? false
                return Plant(id: id, name: name, species: species, description: desc, emoji: emoji, isFavorite: fav)
            }
        } catch {
            print("CoreData fetch error: \(error)")
            return []
        }
    }

    func addPlant(_ plant: Plant) {
        let entity = NSEntityDescription.entity(forEntityName: "PlantEntity", in: context)!
        let obj = NSManagedObject(entity: entity, insertInto: context)
        obj.setValue(plant.id, forKey: "id")
        obj.setValue(plant.name, forKey: "name")
        obj.setValue(plant.species, forKey: "species")
        obj.setValue(plant.description, forKey: "plantDescription")
        obj.setValue(plant.emoji, forKey: "emoji")
        obj.setValue(plant.isFavorite, forKey: "isFavorite")
        saveContext()
    }

    func removePlant(withId id: UUID) {
        let req = NSFetchRequest<NSManagedObject>(entityName: "PlantEntity")
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            let results = try context.fetch(req)
            for obj in results { context.delete(obj) }
            saveContext()
        } catch {
            print("CoreData remove error: \(error)")
        }
    }

    func updateFavorite(forId id: UUID, to isFavorite: Bool) {
        let req = NSFetchRequest<NSManagedObject>(entityName: "PlantEntity")
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            if let obj = try context.fetch(req).first {
                obj.setValue(isFavorite, forKey: "isFavorite")
                saveContext()
            }
        } catch {
            print("CoreData update error: \(error)")
        }
    }

    func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("CoreData save error: \(error)")
        }
    }

    // For debugging/testing
    func deleteAllPlants() {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PlantEntity")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            try container.persistentStoreCoordinator.execute(request, with: context)
            saveContext()
        } catch {
            print("CoreData delete all error: \(error)")
        }
    }
}
