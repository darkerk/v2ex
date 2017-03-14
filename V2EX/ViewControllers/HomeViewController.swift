//
//  HomeViewController.swift
//  V2EX
//
//  Created by wgh on 2017/3/2.
//  Copyright © 2017年 yitop. All rights reserved.
//

import UIKit
import Kanna
import RxSwift
import RxCocoa

class HomeViewController: UITableViewController {
    
    private lazy var viewModel = TopicViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        tableView.delegate = nil
        tableView.dataSource = nil
        
        viewModel.defaultNodes.asObservable().subscribe(onNext: {[weak self] nodes in
            guard let strongSelf = self else { return }
            if let currentNode = nodes.filter({$0.isCurrent}).first {
                strongSelf.navigationItem.rightBarButtonItem?.title = currentNode.name
            }else {
                strongSelf.navigationItem.rightBarButtonItem?.title = nil
            }
        }).addDisposableTo(disposeBag)
        
        viewModel.topicItems.asObservable().bindTo(tableView.rx.items) { (tableView, row, item) in
            let cell: TopicViewCell = tableView.dequeueReusableCell()
            cell.topic = item
            return cell
        }.addDisposableTo(disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: {[weak self] indexPath in
            guard let strongSelf = self else { return }
            strongSelf.tableView.deselectRow(at: indexPath, animated: true)
        }).addDisposableTo(disposeBag)

    }
    
    @IBAction func leftBarItemAction(_ sender: Any) {
        guard let drawerViewController = drawerViewController else { return }
        drawerViewController.isOpenDrawer = !drawerViewController.isOpenDrawer
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is NodesViewController:
            let controller = segue.destination as! NodesViewController
            controller.preferredContentSize = CGSize(width: 150, height: UIScreen.main.bounds.height * 0.65)
            controller.popoverPresentationController?.delegate = self
            controller.viewModel.nodeItems = viewModel.defaultNodes
            controller.selectedItem.asObservable().subscribe(onNext: { node in
                if let node = node {
                    if self.navigationItem.rightBarButtonItem?.title != node.name {
                        self.navigationItem.rightBarButtonItem?.title = node.name
                        let defaultNodes = self.viewModel.defaultNodes.value.map({item -> Node in
                            var newNode = item
                            newNode.isCurrent = (item.name == node.name)
                            return newNode
                        })
                        self.viewModel.defaultNodes.value = defaultNodes
                        self.viewModel.fetchTopics(nodeHref: node.href)
                    }
                }
            }).addDisposableTo(disposeBag)
        case is TopicDetailsViewController:
            guard let cell = sender as? TopicViewCell, let indexPath = tableView.indexPath(for: cell) else {
                return
            }
            let topic = viewModel.topicItems.value[indexPath.row]
            let controller = segue.destination as! TopicDetailsViewController
            controller.viewModel = TopicDetailsViewModel(topic: topic)
            
        default:
            break
        }
    }
}

extension HomeViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

