//
//  UIStackView+Extensions.swift
//
//
//  Created by Abdulrahman Qabbout on 18/04/2024.
//
import UIKit

extension UIStackView {
    func removeAllSubviews() {
        for v in arrangedSubviews {
            removeArrangedSubview(v)
            v.removeFromSuperview()
        }
    }
}
