//
//  Persistence.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Seed preview data
        let recipeSeeder = RecipeSeeder(context: viewContext)
        recipeSeeder.seedDefaultRecipesIfNeeded()
        
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Ayewam")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application, although it may be useful during development.
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        setupContexts()
        
        if !inMemory {
            let recipeSeeder = RecipeSeeder(context: container.viewContext)
            recipeSeeder.seedDefaultRecipesIfNeeded()
        }
    }
    
    // MARK: - Setup Methods
    
    private func setupContexts() {
        // Main context optimization
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Performance optimizations
        container.viewContext.shouldDeleteInaccessibleFaults = true
        container.viewContext.name = "ViewContext"
        
        // Set fetch batch size
        container.viewContext.stalenessInterval = 0.0 // Always refetch
    }
    
    // MARK: - Context Creation
    
    /// Creates a new background context for performing operations
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.shouldDeleteInaccessibleFaults = true
        return context
    }
    
    /// Performs work in a background context and returns the result
    func performBackgroundTask<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            let context = newBackgroundContext()
            context.perform {
                do {
                    let result = try block(context)
                    
                    if context.hasChanges {
                        do {
                            try context.save()
                        } catch {
                            continuation.resume(throwing: error)
                            return
                        }
                    }
                    
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
