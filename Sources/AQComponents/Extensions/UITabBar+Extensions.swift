//
//  UITabBar+Extensions.swift
//
//
//  Created by Abdulrahman Qabbout on 02/04/2024.
//

import UIKit

public extension UITabBar {
    func showBadge(on itemIndex: Int, color: UIColor? = .systemRed) {
        removeBadge(on: itemIndex)
        // Constants for badge size and position
        let badgeSize: CGFloat = 10
        let badgeOffset: CGFloat = 2 // Vertical offset from the top of the image
        
        // Calculate the index of the tab bar item
        let tabBarItemIndex = itemIndex
        
        // Create the badge view
        let badgeView = UIView()
        badgeView.tag = itemIndex + 8989899238
        badgeView.layer.cornerRadius = badgeSize / 2
        badgeView.backgroundColor = color
        badgeView.frame = CGRect(x: 0, y: 0, width: badgeSize, height: badgeSize)
        
        // Remove any existing badge
        viewWithTag(itemIndex + 8989899238)?.removeFromSuperview()
        
        // Access the UITabBar and UITabBarItem views
        if
            let tabBarButtons = subviews.filter({ $0 is UIControl }) as? [UIControl],
            tabBarItemIndex < tabBarButtons.count
        {
            let tabBarItemView = tabBarButtons[tabBarItemIndex]
            
            // Find the UIImageView in the UITabBarItem view
            if let imageView = tabBarItemView.subviews.first(where: { $0 is UIImageView }) {
                // Calculate badge position based on layout direction
                let badgeXPos = imageView.frame.midX + (imageView.frame.width / 2) - (badgeSize / 2)
                let badgeYPos = imageView.frame.minY - badgeOffset
                
                badgeView.frame = CGRect(x: badgeXPos, y: badgeYPos, width: badgeSize, height: badgeSize)
                tabBarItemView.addSubview(badgeView)
            }
        }
    }
    
    func hideBadge(on itemIndex: Int) {
        removeBadge(on: itemIndex)
    }
    
    private func removeBadge(on itemIndex: Int) {
        _ = subviews.map {
            if $0.tag == itemIndex + 8989899238 {
                $0.removeFromSuperview()
            }
        }
    }
}
