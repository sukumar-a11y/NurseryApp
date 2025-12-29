// CoreDataManager.swift
// NurseryApp
//
// Created by Sumit Kumar on 2025/10/24.
// Module: NurseryApp

import Foundation
import CoreData

/// A lightweight programmatic Core Data stack for the NurseryApp.
/// Provides concurrent-safe CRUD helpers and enables lightweight migration.
final class CoreDataManager {
    static let shared = CoreDataManager()
    private let isInMemory: Bool

    /// Create an isolated in-memory CoreDataManager (useful for tests)
    static func makeInMemoryManager() -> CoreDataManager {
        let mgr = CoreDataManager(inMemory: true)
        // Wait for the in-memory store to finish loading before returning
        let sem = DispatchSemaphore(value: 0)
        mgr.container.loadPersistentStores { _, error in
            if let error = error {
                print("CoreData in-memory load error: \(error)")
            }
            sem.signal()
        }
        _ = sem.wait(timeout: .now() + 5)
        return mgr
    }

    let container: NSPersistentContainer
    var viewContext: NSManagedObjectContext { container.viewContext }

    private init(inMemory: Bool = false) {
        let model = CoreDataManager.makeModel()
        container = NSPersistentContainer(name: "NurseryAppModel", managedObjectModel: model)
        self.isInMemory = inMemory

        // Ensure there's at least one persistent store description and apply migration options
        if container.persistentStoreDescriptions.isEmpty {
            let desc = NSPersistentStoreDescription()
            container.persistentStoreDescriptions = [desc]
        }

        // Determine a stable store URL (Application Support) for SQLite stores
        let storeURL: URL? = {
            guard !inMemory else { return nil }
            let fm = FileManager.default
            do {
                let appSupport = try fm.url(for: .applicationSupportDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: true)
                let dir = appSupport.appendingPathComponent("NurseryApp", isDirectory: true)
                if !fm.fileExists(atPath: dir.path) {
                    try fm.createDirectory(at: dir, withIntermediateDirectories: true)
                }
                return dir.appendingPathComponent("NurseryAppModel.sqlite")
            } catch {
                // Fallback: use default container location (do nothing)
                print("CoreData: failed to create Application Support directory: \(error)")
                return nil
            }
        }()

        // Apply migration and store options on all descriptions
        for storeDescription in container.persistentStoreDescriptions {
            // Prefer explicit SQLite store type for persistent stores
            storeDescription.type = inMemory ? NSInMemoryStoreType : NSSQLiteStoreType

            if let storeURL = storeURL, !inMemory {
                storeDescription.url = storeURL
            } else if inMemory {
                storeDescription.url = URL(fileURLWithPath: "/dev/null")
            }

            storeDescription.shouldMigrateStoreAutomatically = true
            storeDescription.shouldInferMappingModelAutomatically = true

            // Set explicit options for older runtimes using setOption(_:forKey:)
            // Use NSNumber for boolean values to be explicit
            storeDescription.setOption(NSNumber(value: true), forKey: NSMigratePersistentStoresAutomaticallyOption)
            storeDescription.setOption(NSNumber(value: true), forKey: NSInferMappingModelAutomaticallyOption)
            if #available(iOS 10.0, macOS 10.13, tvOS 10.0, watchOS 3.0, *) {
                storeDescription.setOption(NSNumber(value: true), forKey: NSPersistentHistoryTrackingKey)
            }
        }

        // Load stores with a safe single retry fallback: if the store is corrupt or incompatible,
        // remove the sqlite files and retry (destructive migration). This is guarded and only
        // used as a last resort during development; remove destructive fallback in production.
        // Synchronously load persistent stores so the container is ready before init returns.
        // This avoids race conditions where callers run fetch/add before the store is available.
        var loadError: Error? = nil
        var didAttemptRecovery = false
        let loadGroup = DispatchGroup()
        loadGroup.enter()

        func configureViewContext(_ ctx: NSManagedObjectContext?) {
            ctx?.automaticallyMergesChangesFromParent = true
            ctx?.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            ctx?.undoManager = nil
        }

        container.loadPersistentStores { [weak self] storeDesc, error in
            if let error = error {
                print("CoreData: initial load failed: \(error)")

                // Attempt a destructive fallback by removing the sqlite files and retrying once
                guard !inMemory, !didAttemptRecovery, let url = storeDesc.url else {
                    loadError = error
                    loadGroup.leave()
                    return
                }

                didAttemptRecovery = true
                print("CoreData: attempting destructive recovery by removing store at \(url.path)")
                let fm = FileManager.default
                let shm = URL(fileURLWithPath: url.path + "-shm")
                let wal = URL(fileURLWithPath: url.path + "-wal")
                do {
                    if fm.fileExists(atPath: url.path) { try fm.removeItem(at: url) }
                    if fm.fileExists(atPath: shm.path) { try fm.removeItem(at: shm) }
                    if fm.fileExists(atPath: wal.path) { try fm.removeItem(at: wal) }
                } catch {
                    print("CoreData: failed to remove store files during recovery: \(error)")
                    loadError = error
                    loadGroup.leave()
                    return
                }

                // Retry loading the persistent stores once
                self?.container.loadPersistentStores { desc2, error2 in
                    if let error2 = error2 {
                        print("CoreData: failed after recovery attempt: \(error2)")
                        loadError = error2
                        loadGroup.leave()
                        return
                    }

                    // Configure viewContext after successful load
                    configureViewContext(self?.container.viewContext)
                    loadGroup.leave()
                }

                return
            }

            // Configure viewContext for main-thread usage
            configureViewContext(self?.container.viewContext)
            loadGroup.leave()
        }

        // Wait with timeout to avoid deadlocks in test environments
        let waitResult = loadGroup.wait(timeout: .now() + 10)
        if waitResult == .timedOut {
            print("CoreData: timed out waiting for persistent store to load")
            if let err = loadError {
                print("CoreData: load error: \(err)")
            }
        }

         // Keep container configured: prefer object-trumping for view context (UI-side wins),
         // background contexts will use a store-trumping policy when saving to avoid clobbering remote changes.
         container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // Provide a configured background context for writes
    private func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
        context.undoManager = nil
        return context
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

    // MARK: - Core Data Basics (Fetch)

    /// Fetch current plants from the view context (main thread). Returns model `Plant` array.
    func fetchPlants() -> [Plant] {
        var plants: [Plant] = []
        let req = NSFetchRequest<NSManagedObject>(entityName: "PlantEntity")
        req.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        viewContext.performAndWait {
            do {
                let results = try viewContext.fetch(req)
                plants = results.compactMap { obj in
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
                plants = []
            }
        }
        return plants
    }

    /// Async fetch variant that performs the fetch on a background context and returns results on main thread
    func fetchPlantsAsync(completion: @escaping (Result<[Plant], Error>) -> Void) {
        let context = newBackgroundContext()
        context.perform {
            let req = NSFetchRequest<NSManagedObject>(entityName: "PlantEntity")
            req.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            do {
                let results = try context.fetch(req)
                let plants = results.compactMap { obj -> Plant? in
                    guard let id = obj.value(forKey: "id") as? UUID,
                          let name = obj.value(forKey: "name") as? String else { return nil }
                    let species = obj.value(forKey: "species") as? String
                    let desc = obj.value(forKey: "plantDescription") as? String
                    let emoji = obj.value(forKey: "emoji") as? String
                    let fav = obj.value(forKey: "isFavorite") as? Bool ?? false
                    return Plant(id: id, name: name, species: species, description: desc, emoji: emoji, isFavorite: fav)
                }
                DispatchQueue.main.async { completion(.success(plants)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    // MARK: - Core Data Concurrency (Write on background contexts)

    /// Add a plant using a background context. Calls completion with Result on main thread.
    func addPlant(_ plant: Plant, completion: ((Result<Void, Error>) -> Void)? = nil) {
        let context = newBackgroundContext()
        context.perform { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion?(.failure(NSError(domain: "CoreDataManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "self deallocated"]))) }
                return
            }
            let entity = NSEntityDescription.entity(forEntityName: "PlantEntity", in: context)!
            let obj = NSManagedObject(entity: entity, insertInto: context)
            obj.setValue(plant.id, forKey: "id")
            obj.setValue(plant.name, forKey: "name")
            obj.setValue(plant.species, forKey: "species")
            obj.setValue(plant.description, forKey: "plantDescription")
            obj.setValue(plant.emoji, forKey: "emoji")
            obj.setValue(plant.isFavorite, forKey: "isFavorite")
            do {
                try context.save()
                // Ensure viewContext processes the save/merges before we call completion so fetchPlants() sees new data
                self.container.viewContext.performAndWait { }
                DispatchQueue.main.async { completion?(.success(())) }
            } catch {
                print("CoreData addPlant save error: \(error)")
                DispatchQueue.main.async { completion?(.failure(error)) }
            }
        }
    }

    /// Remove a plant by UUID on a background context
    func removePlant(withId id: UUID, completion: ((Result<Void, Error>) -> Void)? = nil) {
        let context = newBackgroundContext()
        context.perform { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion?(.failure(NSError(domain: "CoreDataManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "self deallocated"]))) }
                return
            }
            let req = NSFetchRequest<NSManagedObject>(entityName: "PlantEntity")
            req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            do {
                let results = try context.fetch(req)
                for obj in results { context.delete(obj) }
                try context.save()
                // Ensure viewContext merges changes
                self.container.viewContext.performAndWait { }
                DispatchQueue.main.async { completion?(.success(())) }
            } catch {
                print("CoreData remove error: \(error)")
                DispatchQueue.main.async { completion?(.failure(error)) }
            }
        }
    }

    /// Update favorite flag for a plant on a background context
    func updateFavorite(forId id: UUID, to isFavorite: Bool, completion: ((Result<Void, Error>) -> Void)? = nil) {
        let context = newBackgroundContext()
        context.perform { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion?(.failure(NSError(domain: "CoreDataManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "self deallocated"]))) }
                return
            }
            let req = NSFetchRequest<NSManagedObject>(entityName: "PlantEntity")
            req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            do {
                if let obj = try context.fetch(req).first {
                    obj.setValue(isFavorite, forKey: "isFavorite")
                    try context.save()
                }
                // Ensure viewContext merges changes before completing
                self.container.viewContext.performAndWait { }
                DispatchQueue.main.async { completion?(.success(())) }
            } catch {
                print("CoreData update error: \(error)")
                DispatchQueue.main.async { completion?(.failure(error)) }
            }
        }
    }

    /// Generic save if you use viewContext directly
    func saveViewContext() {
        viewContext.performAndWait {
            guard viewContext.hasChanges else { return }
            do {
                try viewContext.save()
            } catch {
                print("CoreData viewContext save error: \(error)")
            }
        }
    }

    // MARK: - Batch / Utilities

    /// Delete all plants using a background context and batch delete request
    func deleteAllPlants(completion: ((Result<Void, Error>) -> Void)? = nil) {
        let context = newBackgroundContext()
        context.perform { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion?(.failure(NSError(domain: "CoreDataManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "self deallocated"]))) }
                return
            }
            // Batch deletes are not supported by the in-memory store. Use a fetch-and-delete fallback there.
            if self.isInMemory {
                do {
                    let fetchReq = NSFetchRequest<NSManagedObject>(entityName: "PlantEntity")
                    let objs = try context.fetch(fetchReq)
                    for obj in objs { context.delete(obj) }
                    if context.hasChanges { try context.save() }
                    // Ensure viewContext processes merge
                    self.container.viewContext.performAndWait { }
                    DispatchQueue.main.async { completion?(.success(())) }
                } catch {
                    print("CoreData delete all (in-memory) error: \(error)")
                    DispatchQueue.main.async { completion?(.failure(error)) }
                }
                return
            }

            // For SQLite stores use NSBatchDeleteRequest for efficiency
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PlantEntity")
            let request = NSBatchDeleteRequest(fetchRequest: fetch)
            request.resultType = .resultTypeObjectIDs
            do {
                let result = try context.execute(request) as? NSBatchDeleteResult
                if let objectIDs = result?.result as? [NSManagedObjectID], !objectIDs.isEmpty {
                    let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: objectIDs]
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.container.viewContext])
                }
                if context.hasChanges { try context.save() }
                self.container.viewContext.performAndWait { }
                DispatchQueue.main.async { completion?(.success(())) }
            } catch {
                print("CoreData delete all error: \(error)")
                DispatchQueue.main.async { completion?(.failure(error)) }
            }
        }
    }
}
