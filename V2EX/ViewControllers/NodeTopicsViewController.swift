//
//  NodeTopicsViewController.swift
//  V2EX
//
//  Created by wgh on 2017/3/20.
//  Copyright © 2017年 wgh. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PKHUD

class NodeTopicsViewController: UITableViewController {

    let viewModel = NodeTopicsViewModel()
    var nodeHref: String = ""
    
    fileprivate let disposeBag = DisposeBag()
    
    class func show(from navigationController: UINavigationController, node: Node) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: NodeTopicsViewController.segueId) as! NodeTopicsViewController
        
        controller.nodeHref = node.href
        controller.title = node.name
        navigationController.pushViewController(controller, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        tableView.dataSource = nil
        
        viewModel.nodeHref = nodeHref
        viewModel.fetcData()

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
        
        tableView.addInfiniteScrolling {[weak viewModel] in
            viewModel?.fetchMoreData()
        }
        
        viewModel.loadMoreEnabled.asObservable().bindTo(tableView.rx.showsInfiniteScrolling).addDisposableTo(disposeBag)
        viewModel.loadMoreCompleted.asObservable().subscribe(onNext: {[weak tableView] isFinished in
            if isFinished {
                tableView?.infiniteScrollingView?.stopAnimating()
            }
        }).addDisposableTo(disposeBag)
        
        viewModel.loadingActivityIndicator.asObservable().subscribe(onNext: {[weak self] isLoading in
            guard let `self` = self else { return }
            if isLoading {
                let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                activityIndicator.startAnimating()
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
            }else {
                if Account.shared.isLoggedIn.value {
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_more"), style: .plain, target: self, action: #selector(self.moreAction(_:)))
                }else {
                    self.navigationItem.rightBarButtonItem = nil
                }
            }
        }).addDisposableTo(disposeBag)
    }

    func moreAction(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        let isFavorite = viewModel.isFavorited
        let favoriteAction = UIAlertAction(title: isFavorite ? "取消收藏" : "收藏", style: .default, handler: {action in
            self.viewModel.sendFavorite(completion: {isSuccess in
                if isSuccess {
                    HUD.showText(isFavorite ? "取消收藏成功！" : "收藏成功！")
                }else {
                    HUD.showText(isFavorite ? "取消收藏失败！" : "收藏失败！")
                }
            })
        })
        
        alert.addAction(favoriteAction)
        alert.addAction(UIAlertAction(title: "创建新主题", style: .default, handler: {_ in
            self.performSegue(withIdentifier: CreateTopicViewController.segueId, sender: nil)
        }))
        if UI_USER_INTERFACE_IDIOM() == .pad {
            alert.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is CreateTopicViewController {
            let controller = segue.destination as! CreateTopicViewController
            controller.nodeHref = nodeHref
            controller.delegate = self
        }
    }
}

extension NodeTopicsViewController: CreateTopicViewControllerDelegate {
    func createTopicSuccess(viewcontroller: CreateTopicViewController) {
        viewModel.fetcData()
    }
}

extension NodeTopicsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
