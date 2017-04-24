//
//  FavoriteViewController.swift
//  V2EX
//
//  Created by darker on 2017/3/17.
//  Copyright © 2017年 darker. All rights reserved.
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
        
        viewModel.dataItems.asObservable().bind(to: tableView.rx.items) {[weak self]  (table, row, item) in
            switch item {
            case let .topicItem(topic), let .followingItem(topic):
                let cell: TopicViewCell = table.dequeueReusableCell()
                cell.topic = topic
                cell.linkTap = {type in
                    self?.linkTapAction(type: type)
                }
                return cell
            case let .nodeItem(node):
                let cell: FavoriteNodeViewCell = table.dequeueReusableCell()
                cell.node = node
                return cell
            }
        }.addDisposableTo(disposeBag)
        
        tableView.rx.modelSelected(FavoriteItem.self).subscribe(onNext: {[weak self] item in
            switch item {
            case let .topicItem(topic), let .followingItem(topic):
                if let nav = self?.navigationController {
                    TopicDetailsViewController.show(from: nav, topic: topic)
                }
            case let .nodeItem(node):
                self?.performSegue(withIdentifier: NodeTopicsViewController.segueId, sender: node)
                break
            }
        }).addDisposableTo(disposeBag)
        
        tableView.addInfiniteScrolling {[weak tableView, weak viewModel] in
            viewModel?.fetchMoreData(completion: {
                tableView?.infiniteScrollingView?.stopAnimating()
            })
        }
        viewModel.loadMoreEnabled.asObservable().bind(to: tableView.rx.showsInfiniteScrolling).addDisposableTo(disposeBag)
    }
    
    @IBAction func segmentedChange(_ sender: UISegmentedControl) {
        viewModel.type = FavoriteDataType(rawValue: sender.selectedSegmentIndex)!
    }
    
    func linkTapAction(type: TapLink) {
        guard let nav = navigationController else { return }
        switch type {
        case let .user(info):
            TimelineViewController.show(from: nav, user: info)
        case let .node(info):
            NodeTopicsViewController.show(from: nav, node: info)
        default: break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let node = sender as? Node, segue.destination is NodeTopicsViewController {
            let controller = segue.destination as! NodeTopicsViewController
            controller.nodeHref = node.href
            controller.title = node.name
        }
    }
}

extension FavoriteViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
