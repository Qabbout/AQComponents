//
//  AQSelfSizingCollectionView.swift
//  
//
//  Created by Abdulrahman Qabbout on 27/06/2023.
//

import UIKit

final public class AQSelfSizingCollectionView: UICollectionView {
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        isScrollEnabled = false
    }

    public override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    public override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }

    public override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return contentSize
    }
}
