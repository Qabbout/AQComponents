//
//  AQDiskCacheManager.swift
//  
//
//  Created by Abdulrahman Qabbout on 27/06/2023.
//

import Foundation

/// The main objective of this class is to persist data to the cahce folder on the device as json files
final public class AQDiskCacheManager<T: Codable> {
    
    private let fileManager = FileManager.default
    private let directoryURL: URL
    private let fileURL: URL
    
    private struct CacheEntry: Codable {
        let creationDate: Date
        let value: T
    }
    
    /// The constructor of the disk manager
    /// - Parameters:
    ///   - fileName: the name of the file to work with, for example; userCache.json
    ///   - maxAge: the lifetime of the cache
    public init(fileName: String) {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        directoryURL = urls[0]
        fileURL = directoryURL.appendingPathComponent(fileName)
    }
    
    public func save(_ object: T) {
        let entry = CacheEntry(creationDate: Date(), value: object)
        let data = try? JSONEncoder().encode(entry)
        try? data?.write(to: fileURL, options: .atomic)
    }
    
    public func load(maxAge: TimeInterval) -> T? {
        if let data = try? Data(contentsOf: fileURL),
           let decodedEntry = try? JSONDecoder().decode(CacheEntry.self, from: data),
           Date().timeIntervalSince(decodedEntry.creationDate) <= maxAge {
            return decodedEntry.value
        }
        
        return nil
    }
    
    public func removeCache(completion: ((Result<String, Error>) -> ())? = nil) {
        do {
            try fileManager.removeItem(at: fileURL)
            completion?(.success(fileURL.absoluteString))
        } catch {
            completion?(.failure(error))
        }
    }
}

final public class AQDiskCacheManagerExperiment {
    
    private let fileManager = FileManager.default
    private let directoryURL: URL
    public static let shared: AQDiskCacheManagerExperiment = AQDiskCacheManagerExperiment()
    
    private struct CacheEntry<T: Codable>: Codable {
        let creationDate: Date
        let value: T
    }
    private init() {
        directoryURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
  
    public func save<T: Codable>(data: T, fileName: String) {
        let fileURL = directoryURL.appendingPathComponent(fileName)
        let entry = CacheEntry(creationDate: Date(), value: data)
        let data = try? JSONEncoder().encode(entry)
        try? data?.write(to: fileURL, options: .atomic)
    }
    
     public func load<T: Codable>(maxAge: TimeInterval, fileName: String) -> T? {
        let fileURL = directoryURL.appendingPathComponent(fileName)
        if let data = try? Data(contentsOf: fileURL),
           let decodedEntry = try? JSONDecoder().decode(CacheEntry<T>.self, from: data),
           Date().timeIntervalSince(decodedEntry.creationDate) <= maxAge {
            return decodedEntry.value
        }
        
        return nil
    }
    
    public func removeCache(fileName: String,completion: ((Result<String, Error>) -> ())? = nil) {
        let fileURL = directoryURL.appendingPathComponent(fileName)
        do {
            try fileManager.removeItem(at: fileURL)
            completion?(.success(fileURL.absoluteString))
        } catch {
            completion?(.failure(error))
        }
    }
}


// Example
//struct User: Codable {
//    let username: String
//}
//
//let userCacheManager = AQDiskCacheManager<User>(fileName: "userCache.json")
//
//userCacheManager.save(User(username: "qabbout"))
//
//if let user = userCacheManager.load(maxAge: 60*60*24) {
//    print(user.username)
//}



