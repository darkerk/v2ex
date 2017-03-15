//
//  TimelineViewController.swift
//  V2EX
//
//  Created by wgh on 2017/3/14.
//  Copyright © 2017年 yitop. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class TimelineViewController: UITableViewController {
    @IBOutlet weak var headerView: TimelineHeaderView!
    
    var userHref: String?

    fileprivate let disposeBag = DisposeBag()
    
    class func show(from navigationController: UINavigationController, userHref href: String?) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: TimelineViewController.segueId) as! TimelineViewController
        controller.userHref = href
        navigationController.pushViewController(controller, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "个人"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        tableView.dataSource = nil

        guard let userHref = userHref else { return }
        
        let dataSource = RxTableViewSectionedReloadDataSource<TimelineSection>()
        dataSource.configureCell = {(ds, table, indexPath, _) in
            switch ds[indexPath] {
            case let .topicItem(topic):
                let cell: TimelineTopicViewCell = table.dequeueReusableCell(for: indexPath)
                cell.topic = topic
                return cell
            case let .replyItem(reply):
                let cell: TimelineReplyViewCell = table.dequeueReusableCell(for: indexPath)
                cell.reply = reply
                return cell
            }
        }

        dataSource.titleForHeaderInSection = {(ds, section) in
            return ds[section].title
        }
        
        let viewModel = TimelineViewModel(href: userHref)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TimelineViewController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if view is UITableViewHeaderFooterView {
            let header = view as! UITableViewHeaderFooterView
            header.contentView.backgroundColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.00)
            header.textLabel?.font = UIFont.systemFont(ofSize: 14)
            header.textLabel?.textColor = #colorLiteral(red: 0.2509803922, green: 0.2509803922, blue: 0.2509803922, alpha: 1)
            
            let moreButton = UIButton()
            moreButton.translatesAutoresizingMaskIntoConstraints = false
            moreButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            moreButton.setTitleColor(#colorLiteral(red: 0.2509803922, green: 0.2509803922, blue: 0.2509803922, alpha: 1), for: .normal)
            moreButton.setTitle("查看更多>", for: .normal)
            header.contentView.addSubview(moreButton)
            moreButton.trailingAnchor.constraint(equalTo: header.contentView.trailingAnchor, constant: -10).isActive = true
            moreButton.bottomAnchor.constraint(equalTo: header.contentView.bottomAnchor, constant: 0).isActive = true
        }
    }
    
}
