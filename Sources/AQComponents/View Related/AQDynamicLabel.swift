//
//  AQDynamicLabel.swift
//
//
//  Created by Abdulrahman Qabbout on 18/04/2024.
//

import UIKit

/// Auto scale the label to its maximal needed size based on its content view.
public class AQDynamicLabel: UILabel {

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    func commonInit() {
        setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .vertical)

        setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .vertical)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        if preferredMaxLayoutWidth != frame.size.width {
            preferredMaxLayoutWidth = frame.size.width
            setNeedsUpdateConstraints()
        }
    }

    public override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height += 1.0
        return size
    }
}
