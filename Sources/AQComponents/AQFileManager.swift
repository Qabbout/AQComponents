//
//  AQFileManager.swift
//
//
//  Created by Abdulrahman Qabbout on 16/04/2024.
//

import Foundation

public class AQFileManager: NSObject {
    
    public static let shared = AQFileManager()
    let fileManager = FileManager.default
    
    // MARK: - Utility Properties
    private var documentsURL: URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private override init() {
        super.init()
    }
    
    // MARK: - File Operations
    public func createFile(atPath path: String, contents: Data? = nil) -> Bool {
        let fileURL = documentsURL.appendingPathComponent(path)
        return fileManager.createFile(atPath: fileURL.path, contents: contents, attributes: nil)
    }
    
    public func readFile(atPath path: String) -> Data? {
        let fileURL = documentsURL.appendingPathComponent(path)
        return fileManager.contents(atPath: fileURL.path)
    }
    
    public func updateFile(atPath path: String, newData: Data) -> Bool {
        let fileURL = documentsURL.appendingPathComponent(path)
        do {
            try newData.write(to: fileURL)
            return true
        } catch {
            dump("Error updating file: \(error)")
            return false
        }
    }
    
    public func deleteFile(atPath path: String) -> Bool {
        let fileURL = documentsURL.appendingPathComponent(path)
        do {
            try fileManager.removeItem(at: fileURL)
            return true
        } catch {
            dump("Error deleting file: \(error)")
            return false
        }
    }

    // MARK: - Directory Operations
    public func createDirectory(atPath path: String) -> Bool {
        let dirURL = documentsURL.appendingPathComponent(path)
        do {
            try fileManager.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            dump("Error creating directory: \(error)")
            return false
        }
    }
    
    public func listContentsOfDirectory(atPath path: String) -> [String]? {
        let dirURL = documentsURL.appendingPathComponent(path)
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: dirURL.path)
            return contents
        } catch {
            dump("Error listing directory contents: \(error)")
            return nil
        }
    }
    
    public func deleteDirectory(atPath path: String) -> Bool {
        let dirURL = documentsURL.appendingPathComponent(path)
        do {
            try fileManager.removeItem(at: dirURL)
            return true
        } catch {
            dump("Error deleting directory: \(error)")
            return false
        }
    }
}

