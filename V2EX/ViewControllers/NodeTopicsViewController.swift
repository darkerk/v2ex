//
//  NodeTopicsViewController.swift
//  V2EX
//
//  Created by wgh on 2017/3/20.
//  Copyright © 2017年 yitop. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NodeTopicsViewController: UITableViewController {

    var nodeHref: String = ""
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        tableView.dataSource = nil
        
        let viewModel = NodeTopicsViewModel(href: nodeHref)

        viewModel.items.asObservable().bindTo(tableView.rx.items) {[weak navigationController] (table, row, item) in
            let cell: NodeTopicsViewCell = table.dequeueReusableCell()
            cell.topic = item
            if let nav = navigationController {
                cell.avatarTap = {
                    TimelineViewController.show(from: nav, user: item.owner)
                }
            }
            return cell
            }.addDisposableTo(disposeBag)
        
        tableView.rx.modelSelected(Topic.self).subscribe(onNext: {[weak navigationController] item in
            if let nav = navigationController {
                TopicDetailsViewController.show(from: nav, topic: item)
            }
        }).addDisposableTo(disposeBag)
        
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

extension NodeTopicsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
