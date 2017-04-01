//
//  TimelineViewController.swift
//  V2EX
//
//  Created by wgh on 2017/3/14.
//  Copyright © 2017年 wgh. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class TimelineViewController: UITableViewController {
    @IBOutlet weak var headerView: TimelineHeaderView!
    
    var user: User?
    
    let dataSource = RxTableViewSectionedReloadDataSource<TimelineSection>()
    fileprivate let disposeBag = DisposeBag()
    
    class func show(from navigationController: UINavigationController, user: User?) {
        let controller = UIStoryboard(name: "Timeline", bundle: nil).instantiateViewController(withIdentifier: TimelineViewController.segueId) as! TimelineViewController
        controller.user = user
        navigationController.pushViewController(controller, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        guard let user = user else {
            return
        }
        navigationItem.title = user.name
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        tableView.dataSource = nil
        
        dataSource.configureCell = {(ds, table, indexPath, _) in
            switch ds[indexPath] {
            case let .topicItem(topic):
                let privacy = ds[indexPath.section].privacy
                if privacy.isEmpty {
                    let cell: TimelineTopicViewCell = table.dequeueReusableCell(for: indexPath)
                    cell.topic = topic
                    return cell
                }else {
                    let cell: UITableViewCell = table.dequeueReusableCell(for: indexPath)
                    cell.selectionStyle = .none
                    cell.textLabel?.text = privacy
                    return cell
                }
            case let .replyItem(reply):
                let cell: TimelineReplyViewCell = table.dequeueReusableCell(for: indexPath)
                cell.reply = reply
                return cell
            }
        }
        
        dataSource.titleForHeaderInSection = {(ds, section) in
            return ds[section].title
        }
        
        let viewModel = TimelineViewModel(href: user.href)
        viewModel.joinTime.asObservable().bindTo(headerView.rx.text).addDisposableTo(disposeBag)
        viewModel.sections.asObservable().bindTo(tableView.rx.items(dataSource: dataSource)).addDisposableTo(disposeBag)
        
        headerView.heightUpdate.asObservable().subscribe(onNext: {[weak self] isUpdate in
            if let `self` = self, isUpdate {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        }).addDisposableTo(disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let allPosts = segue.destination as? AllPostsViewController, let section = sender as? Int {
            allPosts.type = section == 0 ? .topic : .reply
            allPosts.moreHref = dataSource[section].moreHref
        }
    }
    
}

extension TimelineViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch dataSource[indexPath] {
        case let .topicItem(topic):
            if let nav = navigationController {
                TopicDetailsViewController.show(from: nav, topic: topic)
            }
        case let .replyItem(reply):
            if let nav = navigationController, let topic = reply.topic {
                TopicDetailsViewController.show(from: nav, topic: topic)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if view is UITableViewHeaderFooterView {
            let header = view as! UITableViewHeaderFooterView
            header.contentView.backgroundColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.00)
            header.textLabel?.font = UIFont.systemFont(ofSize: 14)
            header.textLabel?.textColor = #colorLiteral(red: 0.2509803922, green: 0.2509803922, blue: 0.2509803922, alpha: 1)
            
            let showMoreButton = dataSource[section].privacy.isEmpty
            if showMoreButton  {
                let moreButton = UIButton()
                moreButton.translatesAutoresizingMaskIntoConstraints = false
                moreButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                moreButton.setTitleColor(#colorLiteral(red: 0.2509803922, green: 0.2509803922, blue: 0.2509803922, alpha: 1), for: .normal)
                if section == 0 {
                    moreButton.setTitle("全部主题>", for: .normal)
                }else {
                    moreButton.setTitle("全部回复>", for: .normal)
                }
                header.contentView.addSubview(moreButton)
                moreButton.trailingAnchor.constraint(equalTo: header.contentView.trailingAnchor, constant: -10).isActive = true
                moreButton.bottomAnchor.constraint(equalTo: header.contentView.bottomAnchor, constant: 0).isActive = true
                
                moreButton.rx.tap.subscribe(onNext: {
                    self.performSegue(withIdentifier: AllPostsViewController.segueId, sender: section)
                }).addDisposableTo(disposeBag)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        if view is UITableViewHeaderFooterView {
            let header = view as! UITableViewHeaderFooterView
            header.contentView.subviews.filter({$0 is UIButton}).forEach { v in
                v.removeFromSuperview()
            }
        }
    }
}
