//
//  NodeNavigationViewController.swift
//  V2EX
//
//  Created by darker on 2017/4/6.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit

class NodeNavigationViewController: UITableViewController {

    var navigationItems: [(name: String, content: String)] = []
    
    class func show(from navigationController: UINavigationController, items: [(name: String, content: String)]) {
        let controller = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: NodeNavigationViewController.segueId) as! NodeNavigationViewController
        controller.navigationItems = items
        navigationController.pushViewController(controller, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "节点导航"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension NodeNavigationViewController {
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return navigationItems.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return navigationItems[section].name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NodeNavigationViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.content = navigationItems[indexPath.section].content
        cell.linkTap = {type in
            switch type {
            case let .node(info):
                guard let nav = self.navigationController else { return  }
                NodeTopicsViewController.show(from: nav, node: info)
            default:
                break
            }
        }
        return cell
    }
}
