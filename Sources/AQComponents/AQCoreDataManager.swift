//
//  AQCoreDataManager.swift
//
//
//  Created by Abdulrahman Qabbout on 16/04/2024.
//

import CoreData
import Foundation

public final class AQCoreDataManager {
    
    public static var shared: AQCoreDataManager?
    
    let persistentContainer: NSPersistentContainer
    
    
    // Background context for asynchronous operations
     var backgroundContext: NSManagedObjectContext {
         return persistentContainer.newBackgroundContext()
     }
     
    
    // Private initializer to force using setup function
    private init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                dump("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    // Setup the Core Data manager
    public static func setup(modelName: String) {
        shared = AQCoreDataManager(modelName: modelName)
    }

    // Save context
    public func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                dump("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // Save context asynchronously
    public func saveContextInBackground(completion: @escaping (Error?) -> Void) {
        let context = backgroundContext
        context.perform {
            if context.hasChanges {
                do {
                    try context.save()
                    completion(nil)
                } catch {
                    completion(error)
                }
            }
        }
    }
    
    // Fetch data
    public func fetchData<Entity: NSManagedObject>(entity: Entity.Type, completion: @escaping ([Entity]?) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Entity>(entityName: String(describing: entity))
        
        do {
            let results = try context.fetch(fetchRequest)
            completion(results)
        } catch {
            dump("Failed to fetch \(entity): \(error)")
            completion(nil)
        }
    }
    // Fetch data with filters and sorts
    public func fetchData<Entity: NSManagedObject>(entity: Entity.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, completion: @escaping ([Entity]?) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Entity>(entityName: String(describing: entity))
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        context.perform {
            do {
                let results = try context.fetch(fetchRequest)
                completion(results)
            } catch {
                dump("Failed to fetch \(entity): \(error)")
                completion(nil)
            }
        }
    }


    // Delete object
    public func delete(object: NSManagedObject) {
        persistentContainer.viewContext.delete(object)
        saveContext()
    }
}

//EXAMPLE:
// In your App Delegate or similar setup file
//AQCoreDataManager.setup(modelName: "MyModel")
//
// To save data
//AQCoreDataManager.shared?.saveContext()
//
// To fetch data
//AQCoreDataManager.shared?.fetchData(entity: User.self) { users in
//    // Process users
//}

