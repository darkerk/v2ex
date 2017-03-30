//
//  HomeViewController.swift
//  V2EX
//
//  Created by wgh on 2017/3/2.
//  Copyright © 2017年 wgh. All rights reserved.
//

import UIKit
import Kanna
import RxSwift
import RxCocoa
import RxDataSources

class HomeViewController: UITableViewController {
    
    fileprivate lazy var viewModel = HomeViewModel()
    fileprivate let dataSource = RxTableViewSectionedAnimatedDataSource<TopicListSection>()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        tableView.delegate = nil
        tableView.dataSource = nil
        
        dataSource.configureCell = {[weak self] (ds, table, indexPath, _) in
            let cell: TopicViewCell = table.dequeueReusableCell()
            let item = ds[indexPath]
            cell.topic = item
            guard let `self` = self else { return cell }
            cell.avatarTap = {
                TimelineViewController.show(from: self.navigationController!, user: item.owner)
            }
            return cell
        }
        
        viewModel.sections.asObservable().bindTo(tableView.rx.items(dataSource: dataSource)).addDisposableTo(disposeBag)
        viewModel.defaultNodes.asObservable().subscribe(onNext: {[weak self] nodes in
            guard let `self` = self else { return }
            if let currentNode = nodes.filter({$0.isCurrent}).first {
                self.navigationItem.rightBarButtonItem?.title = currentNode.name
            }else {
                self.navigationItem.rightBarButtonItem?.title = nil
            }
        }).addDisposableTo(disposeBag)

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
            controller.selectedItem.asObservable().subscribe(onNext: {[weak self] node in
                if let node = node {
                    guard let `self` = self else {
                        return
                    }
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
            let topic = dataSource[indexPath]
            let controller = segue.destination as! TopicDetailsViewController
            controller.delegate = self
            controller.viewModel = TopicDetailsViewModel(topic: topic)
        default:
            break
        }
    }
}

extension HomeViewController: TopicDetailsViewControllerDelegate {
    func topicDetailsViewController(viewcontroller: TopicDetailsViewController, ignoreTopic topicId: String?) {
        if let topicId = topicId {
            viewModel.removeTopic(for: topicId)
        }
    }
}

extension HomeViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

