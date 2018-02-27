//
//  ANZBreadcrumbsListItemView.swift
//  ANZBreadcrumbsNavigationController
//
//  Created by anzfactory on 2018/02/27.
//

import Foundation

class ANZBreadcrumbsListItemView: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .clear
        self.contentView.addSubview(self.titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel.frame = CGRect(origin: .zero, size: self.contentView.bounds.size)
    }
    
    func configure(title: String, font: UIFont, color: UIColor) {
        self.titleLabel.font = font
        self.titleLabel.textColor = color
        self.titleLabel.text = title
    }
    
}
