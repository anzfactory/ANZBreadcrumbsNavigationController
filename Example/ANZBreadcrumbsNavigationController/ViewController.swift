//
//  ViewController.swift
//  ANZBreadcrumbsNavigationController
//
//  Created by anzfactory on 02/27/2018.
//  Copyright (c) 2018 anzfactory. All rights reserved.
//

import UIKit

import ANZBreadcrumbsNavigationController

class ViewController: UIViewController {
    
    var needBackButton: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ViewController \(self.navigationController?.viewControllers.count ?? 0)"
        
        if self.needBackButton, let navicationController = self.navigationController, let root = navicationController.viewControllers.first {
            if root == self {
                let barButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(type(of: self).back))
                navigationItem.leftBarButtonItems = [barButton]
            }
        }
    }

    @IBAction func tapPushMe(_ sender: UIButton) {
        self.navigationController?.pushViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController"), animated: true)
    }
    
    @IBAction func tapManual(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController")
        (vc as? ViewController)?.needBackButton = true
        let nav = ANZBreadcrumbsNavigationController(rootViewController: vc)
        let config = ANZBreadcrumbsNavigationConfig()
        config.height = 44.0
        config.backgroundColor = .lightGray
        config.separator = ">>"
        config.spacing = 8.0
        config.itemStyle.fontSize = 18
        config.itemStyle.textColor = .black
        config.isRootDisplayed = true
        nav.config = config
        
        self.present(nav, animated: true, completion: nil)
    }
    
    @IBAction func tapRntime(_ sender: Any) {
        self.present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NavigationViewController"), animated: true, completion: nil)
    }
    
    @IBAction func tapSwitchConfig(_ sender: Any) {
        
        let config = ANZBreadcrumbsNavigationConfig()
        config.height = 52.0
        config.backgroundColor = .blue
        config.separator = "->"
        config.padding = 16.0
        config.itemStyle.fontSize = 18
        config.itemStyle.textColor = .white
        config.showsHorizontalScrollIndicator = true
        config.isRootDisplayed = true
        
        if let breadcrumbsNav = self.navigationController as? ANZBreadcrumbsNavigationController {
            breadcrumbsNav.config = config
        }
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
}

