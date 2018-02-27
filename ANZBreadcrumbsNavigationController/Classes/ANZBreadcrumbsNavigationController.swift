//
//  ANZBreadcrumbsNavigationController.swift
//  ANZBreadcrumbsNavigationController
//
//  Created by anzfactory on 2018/02/27.
//

import UIKit

public class ANZBreadcrumbsNavigationController: UINavigationController {
    
    private enum Event {
        case insert(indexPaths: [IndexPath]), update, delete(indexPaths: [IndexPath])
    }
    
    private enum Item {
        case label(text: String), separator(text: String)
        
        var text: String {
            switch self {
            case .label(let text):
                return text
            case .separator(let text):
                return text
            }
        }
    }
    
    private enum State {
        case idle, runing
    }
    
    private static let CELL_ID: String = "Item-Cell"
    
    public var breadcrumbsTitles: [String] {
        return self.items.map {
            switch $0 {
            case .label(let text):
                return text
            case .separator:
                return nil
            }
            }.flatMap { $0 }
    }
    
    @objc public dynamic var config: ANZBreadcrumbsNavigationConfig = ANZBreadcrumbsNavigationConfig() {
        didSet {
            self.clearUI()
            self.setupUI()
        }
    }
    
    private var events: [Event] = [] {
        didSet {
            self.updateListView()
        }
    }
    
    private var items: [Item] = [] {
        didSet {
            if self.items.count == oldValue.count {
                self.events.append(.update)
            } else if self.items.count > oldValue.count {
                let start = self.items.count - (self.items.count - oldValue.count)
                let indexPaths = Array(start..<self.items.count).map { IndexPath(row: $0, section: 0) }
                self.events.append(.insert(indexPaths: indexPaths))
            } else {
                let indexPaths = Array(self.items.count..<oldValue.count).map { IndexPath(row: $0, section: 0) }
                self.events.append(.delete(indexPaths: indexPaths))
            }
        }
    }
    
    private var listView: ANZBreadcrumbsListView?
    private var containerView: UIView?
    
    private var state: State = .idle
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.additionalSafeAreaInsets = UIEdgeInsets(top: self.config.height, left: 0, bottom: 0, right: 0)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
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
        
        var newItems: [Item] = []
        if self.items.count == 0 {
            newItems.append(.label(text: root.title ?? "Root"))
        }
        
        newItems.append(.separator(text: self.config.separator))
        
        viewController.addObserver(self, forKeyPath: #keyPath(UIViewController.title), options: [.new], context: nil)
        newItems.append(.label(text: viewController.title ?? ""))
        self.items.append(contentsOf: newItems)
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
        guard let vcList = super.popToViewController(viewController, animated: animated) else {
            return nil
        }
        var tmp = self.items
        for vc in vcList {
            vc.removeObserver(self, forKeyPath: #keyPath(UIViewController.title))
            tmp.removeLast(2)
        }
        if tmp.count == 1 { // Rootだけの場合表示しないので消す
            tmp.removeAll()
        }
        self.items = tmp
        return vcList
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let vc = object as? UIViewController, let index = self.itemIndex(viewController: vc) else {
            return
        }
        
        if let title = change?[.newKey] as? String {
            self.items[index] = .label(text: title)
        }
    }
    
    private func setupUI() {
        
        self.additionalSafeAreaInsets = UIEdgeInsets(top: self.config.height, left: 0, bottom: 0, right: 0)
        
        let container = UIView(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height + self.navigationBar.frame.height, width: self.view.bounds.width, height: self.config.height))
        container.backgroundColor = self.config.backgroundColor
        self.view.addSubview(container)
        NSLayoutConstraint.activate([
            self.view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            container.topAnchor.constraint(equalTo: self.view.topAnchor, constant: container.frame.origin.y),
            container.heightAnchor.constraint(equalToConstant: self.config.height)
            ])
        self.containerView = container
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = self.config.spacing
        layout.minimumInteritemSpacing = self.config.spacing
        layout.sectionInset = UIEdgeInsets(top: 0.0, left: self.config.padding, bottom: 0.0, right: self.config.padding)
        let listView = ANZBreadcrumbsListView(layout: layout)
        listView.frame = CGRect(origin: .zero, size: container.frame.size)
        listView.translatesAutoresizingMaskIntoConstraints = false
        listView.backgroundColor = .clear
        listView.dataSource = self
        listView.delegate = self
        listView.register(ANZBreadcrumbsListItemView.self, forCellWithReuseIdentifier: ANZBreadcrumbsNavigationController.CELL_ID)
        container.addSubview(listView)
        NSLayoutConstraint.activate([
            listView.topAnchor.constraint(equalTo: container.topAnchor),
            listView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            listView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            listView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        self.listView = listView
    }
    
    private func clearUI() {
        self.listView?.removeFromSuperview()
        self.containerView?.removeFromSuperview()
        self.listView = nil
        self.containerView = nil
    }
    
    private func itemIndex(viewController: UIViewController) -> Int? {
        guard let index = self.viewControllers.index(of: viewController) else {
            return nil
        }
        
        return index * 2
    }
    
    private func vcIndex(indexPath: IndexPath) -> Int? {
        switch self.items[indexPath.row] {
        case .label:
            return indexPath.row / 2
        case .separator:
            return nil
        }
    }
}

// MARK: - Manage list view
extension ANZBreadcrumbsNavigationController {
    
    private func reloadListView() {
        self.listView?.reloadData()
    }
    
    private func updateListView() {
        
        if self.state == .runing {
            return
        }
        self.state = .runing
        
        if let event = self.events.popLast() {
            self.update(event: event)
        } else {
            self.state = .idle
        }
    }
    
    private func update(event: Event) {
        self.listView?.performBatchUpdates({
            switch event {
            case .insert(let indexPaths):
                // 前のcurrent状態を解除するためにreloadさせる
                if let first = indexPaths.first, first.row > 0 {
                    self.listView?.reloadItems(at: [IndexPath(row: first.row - 1, section: 0)])
                }
                self.listView?.insertItems(at: indexPaths)
            case .update:
                self.listView?.reloadItems(at: [IndexPath(row: self.items.count - 1, section: 0)])
            case .delete(let indexPaths):
                self.listView?.deleteItems(at: indexPaths)
                // 現在最後尾をcurrent状態にするためにreloadさせる
                if self.items.count > 0 {
                    self.listView?.reloadItems(at: [IndexPath(row: self.items.count - 1, section: 0)])
                }
            }
        }) { _ in
            if let event = self.events.popLast() {
                self.update(event: event)
            } else {
                if let listView = self.listView, listView.contentSize.width > listView.frame.width {
                    let point = CGPoint(x: listView.contentSize.width - listView.frame.width, y: 0)
                    listView.setContentOffset(point, animated: true)
                }
                self.state = .idle
            }
        }
    }
    
}

// MARK: - UICollectionViewDatasource
extension ANZBreadcrumbsNavigationController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ANZBreadcrumbsNavigationController.CELL_ID, for: indexPath) as! ANZBreadcrumbsListItemView
        let style = self.config.itemStyle
        if indexPath.row == self.items.count - 1 {
            cell.configure(title: self.items[indexPath.row].text, font: .boldSystemFont(ofSize: style.fontSize), color: style.textColor)
        } else {
            cell.configure(title: self.items[indexPath.row].text, font: .systemFont(ofSize: style.fontSize), color: style.textColor)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ANZBreadcrumbsNavigationController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let index = self.vcIndex(indexPath: indexPath) else {
            return
        }
        _ = self.popToViewController(self.viewControllers[index], animated: true)
    }
    
}

// MARK: -
extension ANZBreadcrumbsNavigationController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let font: UIFont
        if indexPath.row == self.items.count - 1 {
            font = .boldSystemFont(ofSize: self.config.itemStyle.fontSize)
        } else {
            font = .systemFont(ofSize: self.config.itemStyle.fontSize)
        }
        let size = NSString(string: self.items[indexPath.row].text)
            .boundingRect(
                with: CGSize(width: self.config.maxWidth, height: self.config.height),
                options: [.usesLineFragmentOrigin],
                attributes: [.font: font],
                context: nil
            )
            .size
        
        return CGSize(width: size.width, height: self.config.height)
    }
}
