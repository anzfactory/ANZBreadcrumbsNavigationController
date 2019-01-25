//
//  ANZBreadcrumbsNavigationController.swift
//  ANZBreadcrumbsNavigationController
//
//  Created by anzfactory on 2018/02/27.
//

import UIKit

public class ANZBreadcrumbsNavigationController: UINavigationController {
    
    private enum Event {
        case insert, update, delete
    }
    
    private static let CELL_ID: String = "Item-Cell"
    private static let HEADER_ID: String = "Header-View"
    
    public var breadcrumbsTitles: [String] {
        return self.viewControllers.map {
            $0.title ?? ""
        }
    }
    
    public var listViewHeight: CGFloat {
        return config.height
    }
    
    @objc public dynamic var config: ANZBreadcrumbsNavigationConfig = ANZBreadcrumbsNavigationConfig() {
        didSet {
            self.updateUI(config: self.config)
            self.reloadListView()
        }
    }
    
    private var listView: ANZBreadcrumbsListView?
    private var containerView: UIView?
    private var containerViewHeightConstraint: NSLayoutConstraint?
    
    private var inTransition: Bool = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.delegate = self
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 11.0, *) {
            self.additionalSafeAreaInsets = UIEdgeInsets(top: self.config.height, left: 0, bottom: 0, right: 0)
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.reloadListView()
    }
    
    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        
        guard let root = self.viewControllers.first, root != viewController else {
            return
        }
        
        viewController.addObserver(self, forKeyPath: #keyPath(UIViewController.title), options: [.new], context: nil)
        
        self.update(event: .insert)
    }
    
    public override func popViewController(animated: Bool) -> UIViewController? {
                guard self.viewControllers.count > 1 else {
            return nil
        }
        
        let prevVC = self.viewControllers[self.viewControllers.count - 2]
        _ = self.popToViewController(prevVC, animated: animated)
        
        return prevVC
    }
    
    public override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        
        if self.inTransition {
            return nil
        }
        
        guard let vcList = super.popToViewController(viewController, animated: animated) else {
            self.inTransition = false
            self.reloadListView()
            return nil
        }
        
        if let gesture = self.interactivePopGestureRecognizer, gesture.state == .began {
            return vcList
        }
        
        self.inTransition = true
        
        // Detect viewController transition animation end (Ref. issue #1)
        DispatchQueue.main.asyncAfter(deadline: .now() + (animated ? 0.5 : 0.1)) {
            self.inTransition = false
        }
        
        for vc in vcList {
            vc.removeObserver(self, forKeyPath: #keyPath(UIViewController.title))
        }
        
        self.update(event: .delete)
        
        return vcList
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard object is UIViewController else {
            return
        }
        
        self.update(event: .update)
    }
}

// MARK: - UI
extension ANZBreadcrumbsNavigationController {
    
    private func setupUI() {
        
        if #available(iOS 11.0, *) {
            self.additionalSafeAreaInsets = UIEdgeInsets(top: self.config.height, left: 0, bottom: 0, right: 0)
        }
        
        let container = UIView(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height + self.navigationBar.frame.height, width: self.view.bounds.width, height: self.config.height))
        container.backgroundColor = self.config.backgroundColor
        container.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(container)
        let heightConstraint = container.heightAnchor.constraint(equalToConstant: self.config.height)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                self.view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                container.topAnchor.constraint(equalTo: self.view.topAnchor, constant: container.frame.origin.y),
                heightConstraint
            ])
        } else {
            NSLayoutConstraint.activate([
                self.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                self.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                container.topAnchor.constraint(equalTo: self.view.topAnchor, constant: container.frame.origin.y),
                heightConstraint
            ])
        }
        self.containerView = container
        self.containerViewHeightConstraint = heightConstraint
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let listView = ANZBreadcrumbsListView(layout: layout)
        listView.setup()
        listView.frame = CGRect(origin: .zero, size: container.frame.size)
        listView.dataSource = self
        listView.delegate = self
        listView.register(ANZBreadcrumbsListItemView.self, forCellWithReuseIdentifier: type(of: self).CELL_ID)
        listView.register(ANZBreadcrumbsListSeparatorView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: type(of: self).HEADER_ID)
        container.addSubview(listView)
        NSLayoutConstraint.activate([
            listView.topAnchor.constraint(equalTo: container.topAnchor),
            listView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            listView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            listView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        self.listView = listView
    }
    
    private func updateUI(config: ANZBreadcrumbsNavigationConfig) {
        
        if #available(iOS 11.0, *) {
            self.additionalSafeAreaInsets = UIEdgeInsets(top: config.height, left: 0, bottom: 0, right: 0)
        }
        
        self.containerView?.backgroundColor = config.backgroundColor
        self.containerViewHeightConstraint?.constant = config.height
        self.containerViewHeightConstraint?.isActive = true
        
        self.listView?.showsHorizontalScrollIndicator = self.config.showsHorizontalScrollIndicator
        
        self.view.setNeedsLayout()
    }
}

// MARK: - Manage list view
extension ANZBreadcrumbsNavigationController {
    
    private func reloadListView() {
        self.listView?.reloadData()
    }
    
    private func update(event: Event) {
        
        self.listView?.reloadData()
        
        switch event {
        case .update:
            break
        case .insert, .delete:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let listView = self.listView, listView.contentSize.width > listView.frame.width {
                    let point = CGPoint(x: listView.contentSize.width - listView.frame.width, y: 0)
                    listView.setContentOffset(point, animated: true)
                }
            }
        }
    }
}

// MARK: - UICollectionViewDatasource
extension ANZBreadcrumbsNavigationController: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if !self.config.isRootDisplayed && self.viewControllers.count == 1 {
            return 0
        }
        
        return self.viewControllers.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader, let separatorView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: type(of: self).HEADER_ID, for: indexPath) as? ANZBreadcrumbsListSeparatorView {
            
            separatorView.configure(
                title: self.config.separator,
                font: .systemFont(ofSize: self.config.itemStyle.fontSize),
                color: self.config.itemStyle.textColor
            )
            return separatorView
        } else {
            assert(false)
            return UICollectionReusableView()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: type(of: self).CELL_ID, for: indexPath) as! ANZBreadcrumbsListItemView
        
        let style = self.config.itemStyle
        let title: String
        if let vcTitle = viewControllers[indexPath.section].title {
            title = vcTitle
        } else {
            title = ""
        }
        
        let font: UIFont
        if indexPath.section == viewControllers.count - 1 {
            font = .boldSystemFont(ofSize: style.fontSize)
        } else {
            font = .systemFont(ofSize: style.fontSize)
        }
        cell.configure(title: title, font: font, color: style.textColor)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ANZBreadcrumbsNavigationController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        _ = self.popToViewController(self.viewControllers[indexPath.section], animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ANZBreadcrumbsNavigationController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return self.config.spacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.config.spacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: self.config.padding, bottom: 0.0, right: self.config.padding)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        guard section > 0 else {
            return .zero
        }
        
        let font: UIFont = .boldSystemFont(ofSize: self.config.itemStyle.fontSize)
        let size = NSString(string: self.config.separator)
            .boundingRect(
                with: CGSize(width: self.config.maxWidth, height: collectionView.bounds.height),
                options: [.usesLineFragmentOrigin],
                attributes: [.font: font],
                context: nil
            )
            .size
        
        return CGSize(width: size.width, height: collectionView.bounds.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let title = self.viewControllers[indexPath.section].title else {
            return .zero
        }
        
        let font: UIFont = .boldSystemFont(ofSize: self.config.itemStyle.fontSize)
        let size = NSString(string: title)
            .boundingRect(
                with: CGSize(width: self.config.maxWidth, height: collectionView.bounds.height),
                options: [.usesLineFragmentOrigin],
                attributes: [.font: font],
                context: nil
            )
            .size
        
        return CGSize(width: size.width, height: collectionView.bounds.height)
    }
}

// MARK: - UINavigationControllerDelegate
extension ANZBreadcrumbsNavigationController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        func finTransition(context: UIViewControllerTransitionCoordinatorContext) {
            
            context.viewController(forKey: UITransitionContextViewControllerKey.from)?.removeObserver(self, forKeyPath: #keyPath(UIViewController.title))
            self.update(event: .delete)
        }
        
        if #available(iOS 10.0, *) {
            viewController.transitionCoordinator?.notifyWhenInteractionChanges { context in
                
                guard !context.isCancelled else {
                    return
                }
                
                finTransition(context: context)
            }
        } else {
            viewController.transitionCoordinator?.notifyWhenInteractionEnds { context in
                
                guard !context.isCancelled else {
                    return
                }
                
                finTransition(context: context)
            }
        }
        
    }
}
