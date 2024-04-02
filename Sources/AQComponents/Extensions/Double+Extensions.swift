//
//  Double+Extensions.swift
//
//
//  Created by Abdulrahman Qabbout on 02/04/2024.
//

import Foundation

public extension Double {
    
    func removeTrailingZeroFromDouble() -> String {
        let value = String(format: "%g", self)
        if self == 0 {
            return "0"
        }
        return value
    }
    
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func isValidDouble() -> Bool {
        return !self.isNaN && !self.isInfinite
    }
}
