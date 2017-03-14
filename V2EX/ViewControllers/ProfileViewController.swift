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
            guard let strongSelf = self else { return }
            strongSelf.tableView.deselectRow(at: indexPath, animated: true)
            
        }).addDisposableTo(disposeBag)
    }

    @IBAction func loginButtonAction(_ sender: Any) {
        
        drawerViewController?.performSegue(withIdentifier: LoginViewController.segueId, sender: sender)
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
