//
//  UIView+Extensions.swift
//
//
//  Created by Abdulrahman Qabbout on 02/04/2024.
//

import UIKit

public extension UIView {
    
    @discardableResult
    func fromNib<T: UIView>(named name: String? = nil) -> T? {
        let unwrappedName = name ?? String(describing: type(of: self))
        guard
            let contentView = Bundle(for: type(of: self))
                .loadNibNamed(unwrappedName, owner: self, options: nil)?.first as? T
        else {
            return nil
        }
        
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layoutAttach(to: self)
        return contentView
    }
    
    func layoutAttach(to parentView: UIView, height: CGFloat? = nil, inset: CGFloat = 0) {
        self.translatesAutoresizingMaskIntoConstraints = false
        parentView.topAnchor.constraint(equalTo: self.topAnchor, constant: inset).isActive = true
        parentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: inset).isActive = true
        parentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -inset).isActive = true
        parentView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -inset).isActive = true
        
        guard let height = height else { return }
        let heightConstraint = heightAnchor.constraint(greaterThanOrEqualToConstant: height)
        heightConstraint.priority = UILayoutPriority(rawValue: 900)
        heightConstraint.isActive = true
    }
    
    var instanceFromNib: Self {
        Bundle(for: Self.self)
            .loadNibNamed(String(describing: Self.self), owner: nil, options: nil)?.first as! Self
    }
    
    
    func rounded(withBorder width: CGFloat, andBorderColor color: UIColor) {
        DispatchQueue.main.async {
            self.layer.cornerRadius = self.frame.size.height / 2
            self.layer.borderColor = color.cgColor
            self.layer.borderWidth = width
        }
    }
    
    var safeAreaHeight: CGFloat {
        safeAreaLayoutGuide.layoutFrame.size.height
    }
    
    enum AQOrientation {
        case horizontal
        case vertical
    }
    
    func colorWithGradient(
        colors: [CGColor],
        angle: Float
    ) {
        DispatchQueue.main.async {
            let gradient = CAGradientLayer()
            gradient.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
            gradient.colors = colors
            self.layer.insertSublayer(gradient, at: 0)
            
            let x = angle / 360
            let a = pow(sinf(Float(2 * Double.pi) * ((x + 0.75) / 2)), 2)
            let b = pow(sinf(Float(2 * Double.pi) * ((x + 0.0) / 2)), 2)
            let c = pow(sinf(Float(2 * Double.pi) * ((x + 0.25) / 2)), 2)
            let d = pow(sinf(Float(2 * Double.pi) * ((x + 0.5) / 2)), 2)
            
            gradient.startPoint = CGPoint(x: Double(a), y: Double(b))
            gradient.endPoint = CGPoint(x: Double(c), y: Double(d))
            self.setNeedsDisplay()
        }
    }
    
    func colorWithGradient(
        colors: [CGColor],
        type: CAGradientLayerType,
        orientation: AQOrientation,
        cornerRadius: CGFloat? = nil
    ) {
        DispatchQueue.main.async {
            // gradient
            let gradient = CAGradientLayer()
            
            gradient.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
            gradient.colors = colors
            gradient.locations = [0, 0.5, 1.0]
            gradient.name = "gradient"
            
            switch orientation {
            case .horizontal:
                gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
                gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
            case .vertical:
                gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
                gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
            }
            gradient.type = type
            if let cornerRadius {
                gradient.cornerRadius = cornerRadius
            }
            self.layer.insertSublayer(gradient, at: 0)
            self.setNeedsDisplay()
        }
    }
    
    func strokeColorWithGradient(
        colors: [CGColor],
        type: CAGradientLayerType,
        lineWidth: CGFloat
    ) {
        DispatchQueue.main.async {
            // gradient
            let gradient = CAGradientLayer()
            gradient.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
            gradient.colors = colors
            gradient.locations = [0, 1]
            gradient.type = type
            // shape
            let shape = CAShapeLayer()
            shape.lineWidth = lineWidth
            shape.strokeColor = UIColor.black.cgColor
            shape.fillColor = UIColor.clear.cgColor
            shape.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
            gradient.mask = shape
            // add sub layer
            self.layer.addSublayer(gradient)
            self.setNeedsDisplay()
        }
    }
    
    func addShadow(
        color: UIColor,
        radious: CGFloat,
        opacity: Float,
        offset: CGSize
    ) {
        layer.masksToBounds = false
        layer.name = "shadow"
        layer.shadowRadius = radious
        layer.shadowOpacity = opacity
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
    }
    
    
}
