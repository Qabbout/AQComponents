//
//  Array+Extensions.swift
//
//
//  Created by Abdulrahman Qabbout on 02/04/2024.
//

import Foundation

public extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
    
    // Safely lookup an index that might be out of bounds,
    // returning nil if it does not exist
    func get(index: Int) -> Element? {
        if 0 <= index && index < count {
            return self[index]
        } else {
            return nil
        }
    }
    
    func addRandom(_ elements: [Element], afterEvery n: Int) -> [Element] {
        if !elements.isEmpty {
            guard n > 0 else { fatalError("afterEvery value must be greater than 0") }
            let newcount = count + count / n
            return (0 ..< newcount).map { (i: Int) -> Element in
                (i + 1) % (n + 1) == 0 ? (elements.randomElement() ?? elements[0]) as Element : self[i - i / (n + 1)]
            }
        } else {
            return []
        }
    }
}

public extension Array where Element: Equatable {
    
    mutating func removeEqualItems(item: Element) {
        self = self.filter { (currentItem: Element) -> Bool in
            return currentItem != item
        }
    }
    
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        return result
    }
    /// Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else { return }
        remove(at: index)
    }
}

public extension Array where Element == String {
    func separateArrayWithCommasAndAnd() -> String {
        switch self.count {
        case 0:
            return ""
        case 1:
            return self[0]
        case 2:
            return "\(self[0]) and \(self[1])"
        default:
            let last = self.last!
            let rest = Array(self.dropLast())
            let joined = rest.joined(separator: ", ")
            return "\(joined) and \(last)"
        }
    }
}



public extension Collection where Element: Hashable {
    
    subscript (exist index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
}


public extension Array where Element: Equatable {
    func equalContents(to other: [Element]) -> Bool {
        guard self.count == other.count else {return false}
        for e in self{
            guard self.filter({ $0 == e }).count == other.filter({ $0 == e }).count else {
                return false
            }
        }
        return true
    }
}

public extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}
