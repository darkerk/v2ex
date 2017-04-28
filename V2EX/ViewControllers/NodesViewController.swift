//
//  NodesViewController.swift
//  V2EX
//
//  Created by darker on 2017/3/3.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NodesViewController: UITableViewController {
    
    var nodeItems: [Node] = []
    var nodesNavigation: [(name: String, content: String)] = []
    let selectedItem = Variable<Node?>(nil)

    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = AppStyle.shared.theme.tableBackgroundColor
        tableView.separatorColor = AppStyle.shared.theme.separatorColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension NodesViewController {
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? nodeItems.count : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NodeListViewCell = tableView.dequeueReusableCell(for: indexPath)
        if indexPath.section == 0 {
            cell.node = nodeItems[indexPath.row]
        }else {
            cell.textLabel?.text = "更多节点"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            self.selectedItem.value = nodeItems[indexPath.row]
            self.dismiss(animated: true, completion: nil)
        }else {
            if let navigationController = drawerViewController?.centerViewController as? UINavigationController {
                dismiss(animated: true, completion: nil)
                NodeNavigationViewController.show(from: navigationController, items: nodesNavigation)
            }
        }
    }
}
