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
    
    let container: NSPersistentCloudKitContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Ayewam")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Configure CloudKit
            guard let description = container.persistentStoreDescriptions.first else {
                fatalError("Failed to retrieve a persistent store description.")
            }
            
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            
            let options = NSPersistentCloudKitContainerOptions(
                containerIdentifier: "iCloud.ByteGenius.Ayewam"
            )
            
            // Use development environment for initial schema creation
#if DEBUG || true  // Disable CloudKit for V1 release
    // CloudKit disabled - all data stays local
    description.cloudKitContainerOptions = nil
#else
    description.cloudKitContainerOptions = options
#endif
        }
        
        let containerRef = container
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                ErrorHandler.shared.logError(error, identifier: "PersistenceController.loadPersistentStores")
                print("Core Data error: \(error), \(error.userInfo)")
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
            DispatchQueue.main.async {
                containerRef.viewContext.automaticallyMergesChangesFromParent = true
                containerRef.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                containerRef.viewContext.shouldDeleteInaccessibleFaults = true
                containerRef.viewContext.name = "ViewContext"
                containerRef.viewContext.stalenessInterval = 0.0
                
                // Seed recipes
                if !inMemory {
                    let recipeSeeder = RecipeSeeder(context: containerRef.viewContext)
                    recipeSeeder.seedDefaultRecipesIfNeeded()
                }
            }
        })
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
