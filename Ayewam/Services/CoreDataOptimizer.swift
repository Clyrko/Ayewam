//
//  CoreDataOptimizer.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import Foundation
import CoreData

/// Helper class for optimizing Core Data operations
class CoreDataOptimizer {
    
    // MARK: - Batch Operations
    
    /// Perform batch update operation for improved performance
    static func batchUpdate(in context: NSManagedObjectContext, entityName: String, propertiesToUpdate: [String: Any], predicate: NSPredicate) throws -> Int {
        let batchUpdateRequest = NSBatchUpdateRequest(entityName: entityName)
        batchUpdateRequest.propertiesToUpdate = propertiesToUpdate
        batchUpdateRequest.predicate = predicate
        batchUpdateRequest.resultType = .updatedObjectIDsResultType
        
        let result = try context.execute(batchUpdateRequest) as? NSBatchUpdateResult
        guard let objectIDs = result?.result as? [NSManagedObjectID] else {
            return 0
        }
        
        // Notify contexts about changes
        let changes = [NSUpdatedObjectsKey: objectIDs]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
        
        return objectIDs.count
    }
    
    /// Perform batch delete operation for improved performance
    static func batchDelete(in context: NSManagedObjectContext, entityName: String, predicate: NSPredicate) throws -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = predicate
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
        guard let objectIDs = result?.result as? [NSManagedObjectID] else {
            return 0
        }
        
        // Notify contexts about changes
        let changes = [NSDeletedObjectsKey: objectIDs]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
        
        return objectIDs.count
    }
    
    // MARK: - Fetch Request Optimizations
    
    /// Create an optimized fetch request for a given entity
    static func optimizedFetchRequest<T: NSManagedObject>(for entity: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, limit: Int? = nil) -> NSFetchRequest<T> {
        let request = T.fetchRequest() as! NSFetchRequest<T>
        
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        if let limit = limit {
            request.fetchLimit = limit
        }
        
        // Optimization flags
        request.returnsObjectsAsFaults = true
        request.includesPropertyValues = true
        
        return request
    }
    
    /// Create a count request for efficiently counting entities
    static func countRequest<T: NSManagedObject>(for entity: T.Type, predicate: NSPredicate? = nil) -> NSFetchRequest<T> {
        let request = T.fetchRequest() as! NSFetchRequest<T>
        request.predicate = predicate
        
        // Optimization for counting
        request.resultType = .countResultType
        request.includesPropertyValues = false
        request.includesSubentities = false
        
        return request
    }
    
    // MARK: - Pagination Support
    
    /// Create a paginated fetch request
    static func paginatedFetchRequest<T: NSManagedObject>(for entity: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor], pageSize: Int, pageNumber: Int = 0) -> NSFetchRequest<T> {
        let request = optimizedFetchRequest(for: entity, predicate: predicate, sortDescriptors: sortDescriptors)
        
        // Set pagination
        request.fetchLimit = pageSize
        request.fetchOffset = pageSize * pageNumber
        
        return request
    }
    
    // MARK: - Performance Helpers
    
    /// Perform work in a background context
    static func performInBackground<T>(with persistenceController: PersistenceController, operation: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            let context = persistenceController.container.newBackgroundContext()
            context.perform {
                do {
                    let result = try operation(context)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Save context safely with error handling
    static func saveContext(_ context: NSManagedObjectContext) throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                ErrorHandler.shared.logError(error, identifier: "CoreDataOptimizer.saveContext")
                throw AyewamError.failedToSaveData
            }
        }
    }
}
