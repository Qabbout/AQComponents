//
//  UIScrollView+Extensions.swift
//
//
//  Created by Abdulrahman Qabbout on 02/04/2024.
//

import UIKit

public extension UIScrollView {
    
    var scrollIndicators: (horizontal: UIView?, vertical: UIView?) {
        guard self.subviews.count >= 2 else {
            return (horizontal: nil, vertical: nil)
        }
        
        func viewCanBeScrollIndicator(view: UIView) -> Bool {
            let viewClassName = NSStringFromClass(type(of: view))
            if viewClassName == "_UIScrollViewScrollIndicator" || viewClassName == "UIImageView" {
                return true
            }
            return false
        }
        
        let horizontalScrollViewIndicatorPosition = self.subviews.count - 2
        let verticalScrollViewIndicatorPosition = self.subviews.count - 1
        
        var horizontalScrollIndicator: UIView?
        var verticalScrollIndicator: UIView?
        
        let viewForHorizontalScrollViewIndicator = self.subviews[horizontalScrollViewIndicatorPosition]
        if viewCanBeScrollIndicator(view: viewForHorizontalScrollViewIndicator) {
            horizontalScrollIndicator = viewForHorizontalScrollViewIndicator
        }
        
        let viewForVerticalScrollViewIndicator = self.subviews[verticalScrollViewIndicatorPosition]
        if viewCanBeScrollIndicator(view: viewForVerticalScrollViewIndicator) {
            verticalScrollIndicator = viewForVerticalScrollViewIndicator
        }
        return (horizontal: horizontalScrollIndicator, vertical: verticalScrollIndicator)
    }
    
    ///    Scroll so `rect` is just visible (nearest edges). Does nothing if rect completely visible.
    ///    If `rect` is larger than available bounds, then it scrolls so the top edge stays visible.
    func scrollTopRectToVisible(_ rect: CGRect, animated: Bool) {
        let visibleRect = self.bounds
        let diff = rect.height - visibleRect.height
        if diff < 0 {
            scrollRectToVisible(rect, animated: true)
            return
        }

        let diffY = rect.minY - visibleRect.minY
        var offset = contentOffset
        offset.y += diffY
        setContentOffset(offset, animated: animated)
    }
}
