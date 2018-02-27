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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ViewController \(self.navigationController?.viewControllers.count ?? 0)"
    }

    @IBAction func tapPushMe(_ sender: UIButton) {
        self.navigationController?.pushViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController"), animated: true)
    }
    
    @IBAction func tapManual(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController")
        
        let nav = ANZBreadcrumbsNavigationController(rootViewController: vc)
        let config = ANZBreadcrumbsNavigationConfig()
        config.height = 44.0
        config.backgroundColor = .lightGray
        config.separator = ">>"
        config.spacing = 8.0
        config.itemStyle.fontSize = 18
        config.itemStyle.textColor = .black
        nav.config = config
        
        self.present(nav, animated: true, completion: nil)
    }
    
    @IBAction func tapRntime(_ sender: Any) {
        self.present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NavigationViewController"), animated: true, completion: nil)
    }
}

