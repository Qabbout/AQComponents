//
//  UIViewController+Extensions.swift
//
//
//  Created by Abdulrahman Qabbout on 02/04/2024.
//

import UIKit

extension UIViewController: UIGestureRecognizerDelegate {
    
    ///   Hide keyboard when tapped anywhere outside keyboard's view.
    public func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    @objc public func dismissKeyboard() {
        view.endEditing(true)
    }
    
    public var presenter: UIViewController {
        get {
            return self.tabBarController ?? self
        }
    }
}
