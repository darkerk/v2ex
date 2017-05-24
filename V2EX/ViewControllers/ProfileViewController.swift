//
//  ProfileViewController.swift
//  V2EX
//
//  Created by darker on 2017/3/14.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import PKHUD

class ProfileViewController: UITableViewController {
    
    @IBOutlet weak var headerView: ProfileHeaderView!
    lazy var menuItems = [(#imageLiteral(resourceName: "slide_menu_topic"), "个人"),
                          (#imageLiteral(resourceName: "slide_menu_message"), "消息"),
                          (#imageLiteral(resourceName: "slide_menu_favorite"), "收藏"),
                          (#imageLiteral(resourceName: "slide_menu_setting"), "设置")]
    
    private let disposeBag = DisposeBag()
    
    var navController: UINavigationController? {
        return drawerViewController?.centerViewController as? UINavigationController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppStyle.shared.themeUpdateVariable.asObservable().subscribe(onNext: { update in
            self.updateTheme()
            if update {
                self.headerView.updateTheme()
                self.tableView.reloadData()
            }
        }).addDisposableTo(disposeBag)
        
        tableView.delegate = nil
        tableView.dataSource = nil
        
        Account.shared.user.asObservable().bind(to: headerView.rx.user).addDisposableTo(disposeBag)
        Account.shared.isLoggedIn.asObservable().subscribe(onNext: {isLoggedIn in
            if !isLoggedIn {
                self.headerView.logout()
            }
        }).addDisposableTo(disposeBag)
    
        Observable.just(menuItems).bind(to: tableView.rx.items) { (tableView, row, item) in
            let cell: ProfileMenuViewCell = tableView.dequeueReusableCell()
            cell.updateTheme()
            cell.configure(image: item.0, text: item.1)
            return cell
            }.addDisposableTo(disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: {[weak self] indexPath in
            guard let `self` = self else { return }
            self.tableView.deselectRow(at: indexPath, animated: true)
            guard let nav = self.navController else {
                return
            }
            guard Account.shared.isLoggedIn.value else {
                self.showLoginView()
                return
            }
            switch indexPath.row {
            case 0:
                self.drawerViewController?.isOpenDrawer = false
                TimelineViewController.show(from: nav, user: Account.shared.user.value)
            case 1:
                if Account.shared.unreadCount.value > 0 {
                    Account.shared.unreadCount.value = 0
                }
                self.drawerViewController?.isOpenDrawer = false
                nav.performSegue(withIdentifier: MessageViewController.segueId, sender: nil)
            case 2:
                self.drawerViewController?.isOpenDrawer = false
                nav.performSegue(withIdentifier: FavoriteViewController.segueId, sender: nil)
            case 3:
                self.drawerViewController?.isOpenDrawer = false
                nav.performSegue(withIdentifier: SettingViewController.segueId, sender: nil)
            default: break
            }
            
        }).addDisposableTo(disposeBag)

        if let cell = tableView.cellForRow(at: IndexPath(item: 1, section: 0)) as? ProfileMenuViewCell {
            Account.shared.unreadCount.asObservable().bind(to: cell.rx.unread).addDisposableTo(disposeBag)
        }

        Account.shared.isDailyRewards.asObservable().flatMapLatest { canRedeem -> Observable<Bool> in
            if canRedeem {
                return Account.shared.redeemDailyRewards()
            }
            return Observable.just(false)
        }.shareReplay(1).delay(1, scheduler: MainScheduler.instance).subscribe(onNext: { success in
            if success {
                HUD.showText("已领取每日登录奖励！")
                Account.shared.isDailyRewards.value = false
            }
        }, onError: { error in
            print(error.message)
        }).addDisposableTo(disposeBag)

    }
    
    @IBAction func loginButtonAction(_ sender: Any) {
        if let nav = navController, Account.shared.isLoggedIn.value {
            drawerViewController?.isOpenDrawer = false
            TimelineViewController.show(from: nav, user: Account.shared.user.value)
        }else {
            showLoginView()
        }
    }
    
    func showLoginView() {
        drawerViewController?.performSegue(withIdentifier: LoginViewController.segueId, sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


