//
//  UITableView+Extensions.swift
//
//
//  Created by Abdulrahman Qabbout on 02/04/2024.
//

import UIKit

public extension UITableView {
    ///   Reload TableView  without Scroll
    func reloadDataWithoutScroll() {
        let offset = contentOffset
        reloadData()
        layoutIfNeeded()
        setContentOffset(offset, animated: false)
    }
    
    func register(name: String) {
        register(
            UINib(nibName: name, bundle: .main),
            forCellReuseIdentifier: name
        )
    }
    
    /// center point of content size
    var centerPoint: CGPoint {
        CGPoint(x: center.x + contentOffset.x, y: center.y + contentOffset.y)
    }
    
    /// center indexPath
    var centerCellIndexPath: IndexPath? {
        if let centerIndexPath: IndexPath = indexPathForRow(at: centerPoint) {
            return centerIndexPath
        }
        return nil
    }
    
    
    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        indexPath.section < numberOfSections && indexPath.row < numberOfRows(inSection: indexPath.section)
    }
    
    func scrollToTop(animated: Bool) {
        let indexPath = IndexPath(row: 0, section: 0)
        if hasRowAtIndexPath(indexPath: indexPath) {
            scrollToRow(at: indexPath, at: .top, animated: animated)
        }
    }
    
    func scrollToBottom(animated: Bool) {
        let section = numberOfSections
        if section > 0 {
            let row = numberOfRows(inSection: section - 1)
            if row > 0 {
                scrollToRow(at: IndexPath(row: row - 1, section: section - 1), at: .bottom, animated: animated)
            }
        }
    }
    func indexPathForView(_ view: UIView) -> IndexPath? {
        let point = view.convert(CGPoint.zero, to: self)
        return indexPathForRow(at: point)
    }
    
    func reloadWithoutAnimation(){
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        self.reloadData()
        CATransaction.commit()
    }
}
