//
//  ANZBreadcrumbsNavigationConfig.swift
//  ANZBreadcrumbsNavigationController
//
//  Created by anzfactory on 2018/02/27.
//

import Foundation

@objc public class ANZBreadcrumbsNavigationConfig: NSObject {
    @objc public dynamic var height: CGFloat = 32.0
    @objc public dynamic var backgroundColor: UIColor = .darkGray
    @objc public dynamic var padding: CGFloat = 4.0
    @objc public dynamic var spacing: CGFloat = 4.0
    @objc public dynamic var separator: String = ">"
    @objc public dynamic var maxWidth: CGFloat = 320.0
    @objc public dynamic var itemStyle: ItemStyle = ItemStyle()
    
    @objc public class ItemStyle: NSObject {
        @objc public dynamic var fontSize: CGFloat = 12.0
        @objc public dynamic var textColor: UIColor = .white
    }
}
