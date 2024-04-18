//
//  UIFont+Extensions.swift
//
//
//  Created by Abdulrahman Qabbout on 18/04/2024.
//

import UIKit

public extension UIFont {
     func withSize(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: self.fontName, size: fontSize)!
    }

     func withSizeScaled(_ scale: CGFloat) -> UIFont {
        return UIFont(name: self.fontName, size: floor(self.pointSize * scale))!
    }

     static func listAvailableFonts() {
        for family in UIFont.familyNames {
            print("\(family)")

            for names in UIFont.fontNames(forFamilyName: family) {
                print("== \(names)")
            }
        }
    }
}
