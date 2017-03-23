//
//  MessageViewController.swift
//  V2EX
//
//  Created by wgh on 2017/3/17.
//  Copyright © 2017年 wgh. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MessageViewController: UITableViewController {
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
