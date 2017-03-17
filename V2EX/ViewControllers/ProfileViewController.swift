//
//  ProfileViewController.swift
//  V2EX
//
//  Created by wgh on 2017/3/14.
//  Copyright © 2017年 yitop. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ProfileViewController: UITableViewController {

    @IBOutlet weak var headerView: ProfileHeaderView!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = nil
        tableView.dataSource = nil
        
        Account.shared.isLoggedIn.asObservable().map({!$0}).bindTo(headerView.rx.isLoginEnabled).addDisposableTo(disposeBag)
        Account.shared.user.asObservable().bindTo(headerView.rx.user).addDisposableTo(disposeBag)
        
        let menuItems = [(#imageLiteral(resourceName: "slide_menu_topic"), "个人"), (#imageLiteral(resourceName: "slide_menu_message"), "消息"), (#imageLiteral(resourceName: "slide_menu_favorite"), "收藏"), (#imageLiteral(resourceName: "slide_menu_setting"), "设置")]
        Observable.just(menuItems).bindTo(tableView.rx.items) { (tableView, row, item) in
            let cell: ProfileMenuViewCell = tableView.dequeueReusableCell()
            cell.configure(image: item.0, text: item.1)
            return cell
        }.addDisposableTo(disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: {[weak self] indexPath in
            guard let `self` = self else { return }
            `self`.tableView.deselectRow(at: indexPath, animated: true)
            
            switch indexPath.row {
            case 0:
                if Account.shared.isLoggedIn.value {
                    guard let nav = self.drawerViewController?.centerViewController as? UINavigationController else {
                        return
                    }
                    self.drawerViewController?.isOpenDrawer = false
                    TimelineViewController.show(from: nav, user: Account.shared.user.value)
                }else {
                    `self`.showLoginView()
                }
            case 1:
                guard let nav = self.drawerViewController?.centerViewController as? UINavigationController else {
                    return
                }
                self.drawerViewController?.isOpenDrawer = false
                nav.performSegue(withIdentifier: MessageViewController.segueId, sender: nil)
            default: break
            }
            
        }).addDisposableTo(disposeBag)
    }

    @IBAction func loginButtonAction(_ sender: Any) {
        showLoginView()
    }
    
    func showLoginView() {
        drawerViewController?.performSegue(withIdentifier: LoginViewController.segueId, sender: nil)
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


