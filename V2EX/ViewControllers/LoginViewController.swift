//
//  LoginViewController.swift
//  V2EX
//
//  Created by wgh on 2017/3/3.
//  Copyright © 2017年 wgh. All rights reserved.
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
        
        loginViewModel.response.subscribe(onNext: {[weak self] response in
            let result = HTMLParser.shared.loginResult(html: response.data)
            if let user = result.user {
                Account.shared.user.value = user
                Account.shared.isLoggedIn.value = true
                self?.dismiss(animated: true, completion: nil)
            }else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    let errorMsg = result.problem ?? "登录失败，请稍后再试"
                    HUD.showText(errorMsg)
                })
            }
        }, onError: {error in
            HUD.showText(error.message)
        }).addDisposableTo(disposeBag)
        
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
