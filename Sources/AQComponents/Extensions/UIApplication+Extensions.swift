//
//  UIApplication+Extensions.swift
//
//
//  Created by Abdulrahman Qabbout on 02/04/2024.
//
import UIKit

extension UIApplication {
    ///   Get Reference of TopViewController
    static func topViewController(controller: UIViewController? = AQUtils.getKeyWindowSceneView()?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
