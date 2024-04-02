//
//  NSObject+Extensions.swift
//
//
//  Created by Abdulrahman Qabbout on 02/04/2024.
//

import Foundation


extension NSObject {
    public var className: String {
        String(describing: type(of: self))
    }
}
