//
//  TopicDetailsViewController.swift
//  V2EX
//
//  Created by darker on 2017/3/7.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SKPhotoBrowser
import PKHUD

@objc protocol TopicDetailsViewControllerDelegate: class {
    @objc optional func topicDetailsViewController(viewcontroller: TopicDetailsViewController, ignoreTopic topicId: String?)
    @objc optional func topicDetailsViewController(viewcontroller: TopicDetailsViewController, unfavorite topicId: String?)
}

class TopicDetailsViewController: UITableViewController {
    @IBOutlet weak var headerView: TopicDetailsHeaderView!
    
    var viewModel: TopicDetailsViewModel?
    weak var delegate: TopicDetailsViewControllerDelegate?
    
    fileprivate lazy var dataSource = RxTableViewSectionedAnimatedDataSource<TopicDetailsSection>()
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate lazy var inputbar: InputCommentBar = InputCommentBar()
    fileprivate var lastSelectIndexPath: IndexPath?
    fileprivate var canCancelFirstResponder = true
    
    class func show(from navigationController: UINavigationController, topic: Topic, delegate: TopicDetailsViewControllerDelegate? = nil) {
        let controller = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: TopicDetailsViewController.segueId) as! TopicDetailsViewController
        controller.delegate = delegate
        controller.viewModel = TopicDetailsViewModel(topic: topic)
        navigationController.pushViewController(controller, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        tableView.dataSource = nil
        
        inputbar.sizeToFit()
        
        guard let viewModel = viewModel else { return }
        
        headerView.topic = viewModel.topic
        headerView.linkTap = {[weak self] type in
            self?.linkTapAction(type: type)
        }
        
        headerView.heightUpdate.asObservable().subscribe(onNext: {[weak self] isUpdate in
            if let `self` = self, isUpdate {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        }).addDisposableTo(disposeBag)
        
        dataSource.configureCell = {[weak self] (ds, tv, indexPath, item) in
            switch ds[indexPath.section].type {
            case .more:
                let cell: LoadMoreCommentCell = tv.dequeueReusableCell()
                return cell
            case .data:
                let cell: TopicDetailsCommentCell = tv.dequeueReusableCell()
                cell.comment = item
                cell.linkTap = {type in
                    self?.linkTapAction(type: type)
                }
                return cell
            }
        }
        
        dataSource.titleForHeaderInSection = {[weak viewModel] (ds, section) in
            if section == 0, let viewModel = viewModel {
                return ds[section].comments.isEmpty ? "目前尚无回复" : viewModel.countTime.value
            }
            return nil
        }
        
        dataSource.canEditRowAtIndexPath = {_ in
            return Account.shared.isLoggedIn.value
        }
        
        viewModel.updateTopic.asObservable().bindTo(headerView.rx.topic).addDisposableTo(disposeBag)
        viewModel.content.asObservable().bindTo(headerView.rx.htmlString).addDisposableTo(disposeBag)
        viewModel.sections.asObservable().bindTo(tableView.rx.items(dataSource: dataSource)).addDisposableTo(disposeBag)
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
        
        inputbar.rx.sendEvent.subscribe(onNext: {[weak viewModel, weak inputbar, weak self] (text, atName) in
            HUD.show()
            viewModel?.sendComment(content: text, atName: atName, completion: {error in
                if let error = error {
                    HUD.showText(error.message)
                }else {
                    HUD.hide()
                    self?.lastSelectIndexPath = nil
                    inputbar?.endEditing(isClear: true)
                }
            })
        }).addDisposableTo(disposeBag)
        
        /// 处理当键盘弹出时，点击web会造成inputbar取消第一响应
        inputbar.shouldBeginEditing = {[weak self] isEditing in
            self?.headerView.webView.isUserInteractionEnabled = !isEditing
            self?.canCancelFirstResponder = true
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(headerTap(_:)))
        tap.delegate = self
        headerView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        canCancelFirstResponder = true
        inputbar.endEditing()
        resignFirstResponder()
    }
    
    func linkTapAction(type: TapLink) {
        guard let nav = navigationController else { return }
        switch type {
        case let .user(info):
            TimelineViewController.show(from: nav, user: info)
        case let .image(src):
            AppSetting.openPhotoBrowser(from: nav, src: src)
        case let .web(url):
            AppSetting.openWebBrowser(from: nav, URL: url)
        case let .node(info):
            NodeTopicsViewController.show(from: nav, node: info)
        }
    }
    
    func headerTap(_ sender: Any) {
        if inputbar.isFirstResponder {
            canCancelFirstResponder = true
            inputbar.endEditing()
        }else {
            canCancelFirstResponder = false
            becomeFirstResponder()
        }
    }
    
    func moreAction(_ sender: Any) {
        inputbar.endEditing()
        guard let viewModel = viewModel else {
            return
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let isFavorite = viewModel.topic.isFavorite
        let favoriteAction = UIAlertAction(title: isFavorite ? "取消收藏" : "收藏", style: .default, handler: {action in
            viewModel.sendFavorite(completion: {isSuccess in
                if isSuccess {
                    HUD.showText(isFavorite ? "取消收藏成功！" : "收藏成功！")
                    if isFavorite {
                        self.delegate?.topicDetailsViewController?(viewcontroller: self, unfavorite: viewModel.topic.id)
                    }
                }else {
                    HUD.showText(isFavorite ? "取消收藏失败！" : "收藏失败！")
                }
            })
        })
        
        let thankAction = UIAlertAction(title: viewModel.topic.isThank ? "已感谢" : "感谢", style: .default, handler: {_ in
            self.sendThank(type: .topic(id: self.viewModel?.topic.id ?? ""))
        })
        thankAction.isEnabled = !viewModel.topic.isThank
        
        alert.addAction(thankAction)
        alert.addAction(favoriteAction)
        alert.addAction(UIAlertAction(title: "忽略主题", style: .default, handler: {_ in
            self.sendIgnore()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        if UI_USER_INTERFACE_IDIOM() == .pad {
            alert.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(alert, animated: true, completion: nil)
    }
    
    func sendThank(type: ThankType, username: String? = nil) {
        var tips = "确定要发送感谢？"
        switch type {
        case .topic(_):
            tips = "确定要向本主题创建者发送感谢？"
        case .reply(_):
            if let username = username {
                tips = "确定要向 \(username) 发送感谢？"
            }
        }
        let alert = UIAlertController(title: tips, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "好", style: .default, handler: {action in
            self.viewModel?.sendThank(type: type, completion: { isSuccess in
                HUD.showText(isSuccess ? "感谢已发送！" : "感谢发送失败！")
            })
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func sendIgnore() {
        let alert = UIAlertController(title: "确定不想再看到这个主题？", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "好", style: .default, handler: {action in
            action.isEnabled = false
            self.viewModel?.sendIgnore(completion: {isSuccess in
                action.isEnabled = true
                if isSuccess {
                    _ = self.navigationController?.popViewController(animated: true)
                    self.delegate?.topicDetailsViewController?(viewcontroller: self, ignoreTopic: self.viewModel?.topic.id)
                }else {
                    HUD.showText("忽略主题失败！")
                }
            })
        }))
        present(alert, animated: true, completion: nil)
    }
    
    override var inputAccessoryView: UIView? {
        if Account.shared.isLoggedIn.value {
            return inputbar
        }
        return nil
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var canResignFirstResponder: Bool {
        return canCancelFirstResponder
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TopicDetailsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension TopicDetailsViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 40 : 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if section == 0 && view is UITableViewHeaderFooterView {
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.font = UIFont.systemFont(ofSize: 13)
            header.textLabel?.textColor = #colorLiteral(red: 0.2509803922, green: 0.2509803922, blue: 0.2509803922, alpha: 1)
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let thankAction = UITableViewRowAction(style: .default, title: "感谢") { (action, index) in
            tableView.setEditing(false, animated: true)
            let item = self.dataSource[index.section].comments[index.row]
            self.sendThank(type: .reply(id: item.id), username: item.user?.name)
        }
        thankAction.backgroundColor = #colorLiteral(red: 0.7401831746, green: 0.09487184137, blue: 0.09507951885, alpha: 1)
        return [thankAction]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch dataSource[indexPath.section].type {
        case .more:
            tableView.deselectRow(at: indexPath, animated: true)
            if let cell = tableView.cellForRow(at: indexPath) as? LoadMoreCommentCell {
                viewModel?.loadMoreActivityIndicator.asObservable().bindTo(cell.activityIndicatorView.rx.isAnimating).addDisposableTo(disposeBag)
            }
            viewModel?.fetchMoreComments()
        case .data:
            canCancelFirstResponder = true
            becomeFirstResponder()
            inputbar.startEditing()
            
            if lastSelectIndexPath != indexPath {
                inputbar.clear()
            }
            
            lastSelectIndexPath = indexPath
            let item = dataSource[indexPath.section].comments[indexPath.row]
            inputbar.atName = item.user?.name
        }
    }
}
