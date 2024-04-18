//
//  Decimal+Extensions.swift
//  
//
//  Created by Abdulrahman Qabbout on 18/04/2024.
//

import Foundation

public extension Decimal {
    var floored: Decimal {
        return Decimal(
            floor((self as NSDecimalNumber).doubleValue)
        )
    }

    var ceiled: Decimal {
        return Decimal(
            ceil((self as NSDecimalNumber).doubleValue)
        )
    }
    
    var doubleValue:Double {
        return NSDecimalNumber(decimal:self).doubleValue
    }
}
