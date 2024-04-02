//
//  Int+Extensions.swift
//
//
//  Created by Abdulrahman Qabbout on 02/04/2024.
//

import Foundation

public extension Int {
    var roundedWithAbbreviations: String {
        let number = Double(self)
        let thousand = number / 1000
        let million = number / 1000000
        let billion = number / 1000000000
        if billion >= 1.0 {
            return "\(round(billion * 10) / 10)b"
        }
        if million >= 1.0 {
            return "\(round(million * 10) / 10)m"
        } else if thousand >= 1.0 {
            return "\(round(thousand * 10) / 10)k"
        } else {
            return "\(self)"
        }
    }
}
