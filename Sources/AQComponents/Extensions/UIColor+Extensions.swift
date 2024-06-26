//
//  UIColor+Extensions.swift
//
//
//  Created by Abdulrahman Qabbout on 02/04/2024.
//

import UIKit

extension UIColor {
    public convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var cString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        guard cString.count != 6 else { return nil }
        
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
        return
    }
}
