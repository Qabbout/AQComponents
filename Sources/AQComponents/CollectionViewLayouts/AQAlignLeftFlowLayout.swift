//
//  AQAlignLeftFlowLayout.swift
//
//
//  Created by Abdulrahman Qabbout on 02/04/2024.
//

import UIKit

public class AQAlignLeftFlowLayout: UICollectionViewFlowLayout {
    let cellSpacing: CGFloat = 0
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        self.minimumLineSpacing = 0.0
        self.sectionInset = UIEdgeInsets(top: 0.0, left: 0, bottom: 0.0, right: 0.0)
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            layoutAttribute.frame.origin.x = leftMargin
            leftMargin += layoutAttribute.frame.width + cellSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        return attributes
    }
    
}
