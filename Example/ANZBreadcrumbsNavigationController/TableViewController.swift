//
//  TableViewController.swift
//  ANZBreadcrumbsNavigationController_Example
//
//  Created by anzfactory on 2018/02/27.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

import ANZBreadcrumbsNavigationController

class TableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Table \(self.navigationController?.viewControllers.count ?? 0)"
        
        if let navicationController = self.navigationController as? ANZBreadcrumbsNavigationController, let root = navicationController.viewControllers.first {
            if root == self {
                let barButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(type(of: self).back))
                navigationItem.leftBarButtonItems = [barButton]
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(type(of: self).didShowBreadcrumbsViewNotified(_:)), name: .ANZBreadcrumbsDidShowBreadcrumbsView, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(type(of: self).didHideBreadcrumbsViewNotified(_:)), name: .ANZBreadcrumbsDidHideBreadcrumbsView, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
        cell.textLabel?.text = "Row \(indexPath.row)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TableViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

// MARK: - Notification
@objc extension TableViewController {
    
    private func didShowBreadcrumbsViewNotified(_ notification: Notification) {
        
        guard let config = notification.object as? ANZBreadcrumbsNavigationConfig else {
            return
        }
        
        if #available(iOS 11.0, *) { } else {
            var inset = self.tableView.contentInset
            var top = UIApplication.shared.statusBarFrame.height + config.height
            if let navigationBar = self.navigationController?.navigationBar {
                top += navigationBar.frame.height
            }
            inset.top = top
            self.tableView.contentInset = inset
        }
    }
    
    private func didHideBreadcrumbsViewNotified(_ notification: Notification) {
        
        if #available(iOS 11.0, *) { } else {
            var inset = self.tableView.contentInset
            var top = UIApplication.shared.statusBarFrame.height
            if let navigationBar = self.navigationController?.navigationBar {
                top += navigationBar.frame.height
            }
            inset.top = top
            self.tableView.contentInset = inset
        }
    }
    
}
