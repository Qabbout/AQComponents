//
//  AQMessenger.swift
//
//
//  Created by Abdulrahman Qabbout on 16/04/2024.
//

import UIKit

public final class AQMessenger: NSObject {
    
    public static let shared = AQMessenger()

    private override init() {
        super.init()
    }

    public func showToast(message: String, duration: TimeInterval = 3.0, backgroundColor: UIColor, textColor: UIColor, on viewController: UIViewController? = nil) {
        guard let vc = viewController ?? UIApplication.shared.topViewController() else {
            dump("No viewController")
            return
        }
        guard let window = vc.view.window else {
            dump("No window found for the view controller")
            return
        }
        let toastLabel = UILabel(frame: CGRect(x: 0, y: 0, width: vc.view.frame.size.width - 40, height: 44))
        toastLabel.backgroundColor = backgroundColor
        toastLabel.textColor = textColor
        toastLabel.textAlignment = .center;
        toastLabel.font = .systemFont(ofSize: 16)
        toastLabel.text = message
        toastLabel.alpha = 0.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 0
        
        window.addSubview(toastLabel)
        
        // Positioning the toast at the top
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toastLabel.topAnchor.constraint(equalTo: window.topAnchor, constant: 44),
            toastLabel.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            toastLabel.widthAnchor.constraint(equalTo: window.widthAnchor, constant: -40)
        ])

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            toastLabel.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseIn, animations: {
                toastLabel.alpha = 0.0
            }, completion: {_ in
                toastLabel.removeFromSuperview()
            })
        })
    }
}

