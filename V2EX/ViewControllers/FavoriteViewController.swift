//
//  FavoriteViewController.swift
//  V2EX
//
//  Created by wgh on 2017/3/17.
//  Copyright © 2017年 yitop. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class FavoriteViewController: UITableViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    lazy var viewModel = FavoriteViewModel()
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        tableView.dataSource = nil
        
        viewModel.dataItems.asObservable().bindTo(tableView.rx.items) {[weak self]  (table, row, item) in
            switch item {
            case let .topicItem(topic), let .followingItem(topic):
                let cell: TopicViewCell = table.dequeueReusableCell()
                cell.topic = topic
                guard let `self` = self else { return cell }
                cell.avatarTap = {
                    TimelineViewController.show(from: self.navigationController!, user: topic.owner)
                }
                return cell
            case let .nodeItem(node):
                let cell: FavoriteNodeViewCell = table.dequeueReusableCell()
                cell.node = node
                return cell
            }
        }.addDisposableTo(disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: {[weak self] indexPath in
            guard let strongSelf = self else { return }
            strongSelf.tableView.deselectRow(at: indexPath, animated: true)
        }).addDisposableTo(disposeBag)
        
        tableView.addInfiniteScrolling {[weak tableView, weak viewModel] in
            viewModel?.fetchMoreData(completion: {
                tableView?.infiniteScrollingView?.stopAnimating()
            })
        }
        viewModel.loadMoreEnabled.asObservable().bindTo(tableView.rx.showsInfiniteScrolling).addDisposableTo(disposeBag)
    }
    
    @IBAction func segmentedChange(_ sender: UISegmentedControl) {
        viewModel.type = FavoriteType(rawValue: sender.selectedSegmentIndex)!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
