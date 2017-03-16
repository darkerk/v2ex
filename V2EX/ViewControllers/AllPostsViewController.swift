//
//  AllPostsViewController.swift
//  V2EX
//
//  Created by wgh on 2017/3/15.
//  Copyright © 2017年 yitop. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AllPostsViewController: UITableViewController {
    
    var type: AllPostsType = .topic
    var moreHref: String = ""
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let titleText = type == .topic ? "全部主题" : "全部回复"
        navigationItem.title = titleText
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        tableView.dataSource = nil
        
        let viewModel = AllPostsViewModel(href: moreHref, type: type)
        viewModel.totalCount.asObservable().map({titleText + "(\($0))"}).bindTo(navigationItem.rx.title).addDisposableTo(disposeBag)
        
        viewModel.items.asObservable().bindTo(tableView.rx.items) { (table, row, item) in
            switch item {
            case let .topicItem(topic):
                let cell: TimelineTopicViewCell = table.dequeueReusableCell()
                cell.topic = topic
                return cell
            case let .replyItem(reply):
                let cell: TimelineReplyViewCell = table.dequeueReusableCell()
                cell.reply = reply
                return cell
            }
        }.addDisposableTo(disposeBag)

        tableView.addInfiniteScrolling {[weak tableView] in
           viewModel.fetchMoreData(completion: {
                tableView?.infiniteScrollingView?.stopAnimating()
           })
        }
        viewModel.loadMoreEnabled.asObservable().bindTo(tableView.rx.showsInfiniteScrolling).addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

