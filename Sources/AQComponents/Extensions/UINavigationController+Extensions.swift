//
//  UINavigationController+Extensions.swift
//
//
//  Created by Abdulrahman Qabbout on 02/04/2024.
//

import UIKit

extension UINavigationController {
    /// Given the kind of a (UIViewController subclass),
    /// removes any matching instances from self's
    /// viewControllers array.
    @discardableResult public func removeAnyViewControllers(ofKind kind: AnyClass) -> UIViewController? {
        viewControllers = viewControllers.filter { !$0.isKind(of: kind) }
        return visibleViewController
    }

    // Given the kind of a (UIViewController subclass),
    // returns true if self's viewControllers array contains at
    // least one matching instance.

    public func containsViewController(ofKind kind: AnyClass) -> Bool {
        viewControllers.contains(where: { $0.isKind(of: kind) })
    }
}
