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

extension UITableViewController: ThemeUpdating {
    func updateTheme() {
        switch tableView.style {
        case .plain:
            tableView.backgroundColor = AppStyle.shared.theme.tableBackgroundColor
        case .grouped:
            tableView.backgroundColor = AppStyle.shared.theme.tableGroupBackgroundColor
        }
        tableView.separatorColor = AppStyle.shared.theme.separatorColor
    }
}
