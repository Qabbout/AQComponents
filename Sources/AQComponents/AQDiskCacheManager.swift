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
    private var maxAge: TimeInterval
    
    private struct CacheEntry: Codable {
        let creationDate: Date
        let value: T
    }
    
    /// The constructor of the disk manager
    /// - Parameters:
    ///   - fileName: the name of the file to work with, for example; userCache.json
    ///   - maxAge: the lifetime of the cache
    public init(fileName: CacheFile, maxAge: TimeInterval) {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        directoryURL = urls[0]
        fileURL = directoryURL.appendingPathComponent(fileName.rawValue)
        self.maxAge = maxAge
    }
    
    public func save(_ object: T) {
        let entry = CacheEntry(creationDate: Date(), value: object)
        let data = try? JSONEncoder().encode(entry)
        try? data?.write(to: fileURL, options: .atomic)
    }
    
    public func load() -> T? {
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

public enum CacheFile: String {
    case userCache = "userCache.json"
    // Add more cases as needed
}


// Example
//struct User: Codable {
//    let username: String
//}
//
//let userCacheManager = AQDiskCacheManager<User>(fileName: .userCache, maxAge: 60*60*24)
//
//userCacheManager.save(User(username: "qabbout"))
//
//if let user = userCacheManager.load() {
//    print(user.username)
//}



