//
//  AllPostsViewController.swift
//  V2EX
//
//  Created by darker on 2017/3/15.
//  Copyright © 2017年 darker. All rights reserved.
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
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        let titleText = type == .topic ? "全部主题" : "全部回复"
        navigationItem.title = titleText
        
        tableView.backgroundColor = AppStyle.shared.theme.tableBackgroundColor
        tableView.separatorColor = AppStyle.shared.theme.separatorColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90
        tableView.dataSource = nil
        
        let viewModel = AllPostsViewModel(href: moreHref, type: type)
        viewModel.totalCount.asObservable().map({titleText + "(\($0))"}).bind(to: navigationItem.rx.title).disposed(by: disposeBag)
        
        viewModel.items.asObservable().bind(to: tableView.rx.items) { (table, row, item) in
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
            }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(SectionTimelineItem.self).subscribe(onNext: {[weak navigationController] item in
            guard let nav = navigationController else { return }
            switch item {
            case let .topicItem(topic):
                TopicDetailsViewController.show(from: nav, topic: topic)
            case let .replyItem(reply):
                if let topic = reply.topic {
                    TopicDetailsViewController.show(from: nav, topic: topic)
                }
            }
        }).disposed(by: disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: {[weak tableView] indexPath in
            tableView?.deselectRow(at: indexPath, animated: true)
        }).disposed(by: disposeBag)

        tableView.addInfiniteScrolling {[weak tableView] in
           viewModel.fetchMoreData(completion: {
                tableView?.infiniteScrollingView?.stopAnimating()
           })
        }
        
        if AppStyle.shared.theme == .night {
            tableView.infiniteScrollingView?.activityIndicatorView.style = .white
        }
        
        viewModel.loadMoreEnabled.asObservable().bind(to: tableView.rx.showsInfiniteScrolling).disposed(by: disposeBag)
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
