//
//  ANZBreadcrumbsListSeparatorView.swift
//  ANZBreadcrumbsNavigationController
//
//  Created by sasato on 2018/07/18.
//

import UIKit

class ANZBreadcrumbsListSeparatorView: UICollectionReusableView {
    
    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.addSubview(self.titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleLabel.frame = CGRect(origin: .zero, size: self.bounds.size)
    }
}

extension ANZBreadcrumbsListSeparatorView {
    
    func configure(title: String, font: UIFont, color: UIColor) {
        self.titleLabel.font = font
        self.titleLabel.textColor = color
        self.titleLabel.text = title
    }
}
