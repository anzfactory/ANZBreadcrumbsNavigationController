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
            
            if #available(iOS 11.0, *) { } else {
                var inset = self.tableView.contentInset
                inset.top += navicationController.listViewHeight
                self.tableView.contentInset = inset
            }
        }
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
