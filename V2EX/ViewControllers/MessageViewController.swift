//
//  MessageViewController.swift
//  V2EX
//
//  Created by darker on 2017/3/17.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MessageViewController: UITableViewController {
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        tableView.dataSource = nil
        
        let viewModel = MessageViewModel()
        viewModel.items.asObservable().bindTo(tableView.rx.items) { (table, row, item) in
            let cell: MessageViewCell = table.dequeueReusableCell()
            cell.message = item
            return cell
            }.addDisposableTo(disposeBag)
        
        tableView.addInfiniteScrolling {[weak tableView] in
            viewModel.fetchMoreData(completion: {
                tableView?.infiniteScrollingView?.stopAnimating()
            })
        }
        viewModel.loadMoreEnabled.asObservable().bindTo(tableView.rx.showsInfiniteScrolling).addDisposableTo(disposeBag)
        
        tableView.rx.modelSelected(Message.self).subscribe(onNext: {[weak navigationController] item in
            if let nav = navigationController, let topic = item.topic {
                TopicDetailsViewController.show(from: nav, topic: topic)
            }
        }).addDisposableTo(disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MessageViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
