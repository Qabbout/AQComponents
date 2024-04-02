import UIKit

final class AQUtils {
    
    public static func setScrollViewWillEndDraggingToVerticalPaging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>, layout: UICollectionViewFlowLayout) {
        
        let cellHeightIncludingSpacing = layout.itemSize.height + layout.minimumLineSpacing
        let proposedContentOffsetY = targetContentOffset.pointee.y
        let rawIndex = (proposedContentOffsetY + scrollView.contentInset.top) / cellHeightIncludingSpacing

        let velocityThreshold: CGFloat = 0.1 // Adjust this value as needed
        let isSwipeDown = velocity.y > 0
        let isSwipeUp = velocity.y < 0

        let index: CGFloat = if (isSwipeDown && velocity.y > velocityThreshold) || (isSwipeUp && velocity.y < -velocityThreshold) {
            // Use ceil or floor depending on swipe direction to determine the index
            isSwipeDown ? ceil(rawIndex) : floor(rawIndex)
        } else {
            // Use rounding for small or no velocity
            round(rawIndex)
        }

        // Adjust the targetContentOffset to snap to the nearest cell
        targetContentOffset.pointee.y = index * cellHeightIncludingSpacing - scrollView.contentInset.top
        
    }
}
