//
//  AQKeychainManager.swift
//
//
//  Created by Abdulrahman Qabbout on 16/04/2024.
//

import Foundation
import Security

public final class AQKeychainManager: NSObject {
    
    public static let shared = AQKeychainManager()

    private override init() {
        super.init()
    }

    /// Save data to the Keychain
    public func saveData(key: String, data: Data) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,  // Define the item class as a generic password.
            kSecAttrAccount as String: key,                 // Define the account name as the unique identifier.
            kSecValueData as String: data,                  // Define the data to store.
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked // Define when the data is accessible.
        ]
        
        // Delete any existing items with the same key to avoid duplicates.
        SecItemDelete(query as CFDictionary)
        
        // Add new item to the keychain.
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// Retrieve data from the Keychain
    public func retrieveData(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,  // Specify the class of item to search for.
            kSecAttrAccount as String: key,                 // Use the account name as the search key.
            kSecMatchLimit as String: kSecMatchLimitOne,    // Limit search results to one match.
            kSecReturnData as String: kCFBooleanTrue!       // Specify that the data should be returned.
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess, let data = item as? Data {
            return data
        }
        
        return nil
    }

    /// Delete data from the Keychain
    public func deleteData(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,  // Specify the class of item to delete.
            kSecAttrAccount as String: key                  // Use the account name as the delete key.
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}
