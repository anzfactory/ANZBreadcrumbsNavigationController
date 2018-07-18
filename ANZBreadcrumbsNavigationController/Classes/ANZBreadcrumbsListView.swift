//
//  ANZBreadcrumbsListView.swift
//  ANZBreadcrumbsNavigationController
//
//  Created by anzfactory on 2018/02/27.
//

import UIKit

class ANZBreadcrumbsListView: UICollectionView {
    init(layout: UICollectionViewFlowLayout) {
        super.init(frame: .zero, collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.showsHorizontalScrollIndicator = false
        self.allowsMultipleSelection = false
        self.alwaysBounceVertical = false
        self.alwaysBounceHorizontal = false
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
    }
}
