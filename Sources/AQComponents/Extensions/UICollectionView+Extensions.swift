//
//  UICollectionView+Extensions.swift
//
//
//  Created by Abdulrahman Qabbout on 02/04/2024.
//

import UIKit

public extension UICollectionView {
    
    func register(name: String) {
        register(
            UINib(nibName: name, bundle: .main),
            forCellWithReuseIdentifier: name
        )
    }
    
    func scrollToEnd(animated: Bool) {
        if numberOfItems(inSection: 0) > 0 {
            let indexPath = NSIndexPath(item: 0, section: 0)
            scrollToItem(at: indexPath as IndexPath, at: .left, animated: animated)
        }
    }
    
    func centerItemsInCollectionView(cellWidth: Double, numberOfItems: Double, spaceBetweenCell: Double) -> UIEdgeInsets {
        let totalWidth = cellWidth * numberOfItems
        let totalSpacingWidth = spaceBetweenCell * (numberOfItems - 1)
        let leftInset = (self.frame.width - CGFloat(totalWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
    
    func isCellAtIndexPathFullyVisible(_ indexPath: IndexPath) -> Bool {
        guard let layoutAttribute = layoutAttributesForItem(at: indexPath) else {
            return false
        }
        let cellFrame = layoutAttribute.frame
        return self.bounds.contains(cellFrame)
    }
    
    func indexPathsForFullyVisibleItems() -> [IndexPath] {
        let visibleIndexPaths = indexPathsForVisibleItems
        return visibleIndexPaths.filter { indexPath in
            return isCellAtIndexPathFullyVisible(indexPath)
        }
    }
    
    
}
