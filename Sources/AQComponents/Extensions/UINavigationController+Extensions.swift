//
//  UINavigationController+Extensions.swift
//
//
//  Created by Abdulrahman Qabbout on 02/04/2024.
//

import UIKit

public extension UINavigationController {
    
    /// Given the kind of a (UIViewController subclass),
    /// removes any matching instances from self's
    /// viewControllers array.
    @discardableResult func removeAnyViewControllers(ofKind kind: AnyClass) -> UIViewController? {
        viewControllers = viewControllers.filter { !$0.isKind(of: kind) }
        return visibleViewController
    }
    
    /// Given the kind of a (UIViewController subclass),
    /// returns true if self's viewControllers array contains at
    /// least one matching instance.
    func containsViewController(ofKind kind: AnyClass) -> Bool {
        viewControllers.contains(where: { $0.isKind(of: kind) })
    }
    
    func popToRootViewController(animated: Bool = true, completion: ((UIViewController?) -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setCompletionBlock({completion?(self.viewControllers.first)})
        popToRootViewController(animated: animated)
        CATransaction.commit()
    }
    
    func popViewController(completion: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popViewController(animated: true)
        CATransaction.commit()
    }
}
