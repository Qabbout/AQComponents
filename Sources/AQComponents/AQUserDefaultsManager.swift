//
//  AQUserDefaultsManager.swift
//
//
//  Created by Abdulrahman Qabbout on 16/04/2024.
//

import Foundation

public final class AQUserDefaultsManager: NSObject {
    
    public static let shared = AQUserDefaultsManager()
    
    private override init() {
        super.init()
    }
    
    // MARK: - Save Data
    public func save<T>(value: T, forKey key: String) where T: Encodable {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(value) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    // MARK: - Retrieve Data
    public func getValue<T>(forKey key: String, type: T.Type) -> T? where T: Decodable {
        if let data = UserDefaults.standard.data(forKey: key) {
            let decoder = JSONDecoder()
            return try? decoder.decode(T.self, from: data)
        }
        return nil
    }
    
    // MARK: - Set Simple Values
    public func set(value: Any?, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    // MARK: - Get Simple Values
    public func get(forKey key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }
    
    // MARK: - Remove Value
    public func remove(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

