//
//  LoginViewController.swift
//  V2EX
//
//  Created by wgh on 2017/3/3.
//  Copyright © 2017年 yitop. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PKHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: LoginButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let usernameValid = usernameTextField.rx.text.orEmpty.map({$0.isEmpty == false}).shareReplay(1)
        let passwordValid = passwordTextField.rx.text.orEmpty.map({$0.isEmpty == false}).shareReplay(1)
        let allValid = Observable.combineLatest(usernameValid, passwordValid) { $0 && $1 }.shareReplay(1)
        allValid.bindTo(loginButton.rx.isLoginEnabled).addDisposableTo(disposeBag)
        
        usernameTextField.rx.controlEvent(.editingDidEndOnExit).subscribe(onNext: {[weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.passwordTextField.becomeFirstResponder()
            
        }).addDisposableTo(disposeBag)
        
        passwordTextField.rx.controlEvent(.editingDidEndOnExit).subscribe().addDisposableTo(disposeBag)
        
        let loginViewModel = LoginViewModel(input: (username: usernameTextField.rx.text.orEmpty.asObservable(), password: passwordTextField.rx.text.orEmpty.asObservable(), tap: loginButton.rx.tap.asObservable()))
        
        loginViewModel.isloading.bindTo(PKHUD.sharedHUD.rx.isAnimating).addDisposableTo(disposeBag)
        
        loginViewModel.response.subscribe(onNext: {response in
            if let info = HTMLParser.shared.userInfo(html: response.data) {
                Account.shared.user.value = User(name: info.username, href: "/member/" + info.username, src: info.avatar)
                Account.shared.isLoggedIn.value = true
                self.dismiss(animated: true, completion: nil)
            }else {
                HUD.showText("返回数据出错！")
            }
        }, onError: {error in
            HUD.showText(error.localizedDescription)
        }).addDisposableTo(disposeBag)
        
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
