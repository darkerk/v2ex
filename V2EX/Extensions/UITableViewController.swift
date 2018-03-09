//
//  UITableViewController.swift
//  V2EX
//
//  Created by wgh on 2017/4/27.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit

protocol ThemeUpdating {
    func updateTheme()
}

extension UIViewController: ThemeUpdating {
    func updateTheme() {
        
    }
    
    func showLoginAlert(isPopBack: Bool = false) {
        let alert = UIAlertController(title: "需要您登录V2EX", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: {_ in
            if isPopBack {
                self.navigationController?.popViewController(animated: true)
            }
        }))
        alert.addAction(UIAlertAction(title: "登录", style: .default, handler: {_ in
            self.drawerViewController?.performSegue(withIdentifier: LoginViewController.segueId, sender: nil)
        }))
        present(alert, animated: true, completion: nil)
        
    }
}

extension UITableViewController {
    override func updateTheme() {
        switch tableView.style {
        case .plain:
            tableView.backgroundColor = AppStyle.shared.theme.tableBackgroundColor
        case .grouped:
            tableView.backgroundColor = AppStyle.shared.theme.tableGroupBackgroundColor
        }
        tableView.separatorColor = AppStyle.shared.theme.separatorColor
    }
}
