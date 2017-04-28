//
//  LoginViewController.swift
//  V2EX
//
//  Created by darker on 2017/3/3.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PKHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: LoginButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var googleButton: LoginButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sublitLabel: UILabel!
    @IBOutlet weak var line1View: UIImageView!
    @IBOutlet weak var line2View: UIImageView!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AppStyle.shared.theme == .night {
            view.backgroundColor = AppStyle.shared.theme.cellBackgroundColor
            cancelButton.setImage(#imageLiteral(resourceName: "cancel_X").imageWithTintColor(#colorLiteral(red: 0.1137254902, green: 0.631372549, blue: 0.9490196078, alpha: 1)), for: .normal)
            titleLabel.textColor = UIColor.white
            sublitLabel.textColor = UIColor.white
            
            let lineImage = #imageLiteral(resourceName: "line").imageWithTintColor(UIColor.black)
            line1View.image = lineImage
            line2View.image = lineImage
            
            let attributes = [NSForegroundColorAttributeName: #colorLiteral(red: 0.4196078431, green: 0.4901960784, blue: 0.5490196078, alpha: 1)]
            usernameTextField.attributedPlaceholder = NSAttributedString(string: "用户名或邮箱", attributes: attributes)
            passwordTextField.attributedPlaceholder = NSAttributedString(string: "密码", attributes: attributes)
            usernameTextField.textColor = #colorLiteral(red: 0.6078431373, green: 0.6862745098, blue: 0.8, alpha: 1)
            passwordTextField.textColor = #colorLiteral(red: 0.6078431373, green: 0.6862745098, blue: 0.8, alpha: 1)
            
            loginButton.backgroundColor = #colorLiteral(red: 0.1411764706, green: 0.2039215686, blue: 0.2784313725, alpha: 1)
            loginButton.layer.borderColor = #colorLiteral(red: 0.1411764706, green: 0.2039215686, blue: 0.2784313725, alpha: 1).cgColor
            loginButton.setTitleColor(UIColor.white, for: .normal)
            loginButton.setTitleColor(#colorLiteral(red: 0.6078431373, green: 0.6862745098, blue: 0.8, alpha: 1), for: .disabled)
        }
        
        let usernameValid = usernameTextField.rx.text.orEmpty.map({$0.isEmpty == false}).shareReplay(1)
        let passwordValid = passwordTextField.rx.text.orEmpty.map({$0.isEmpty == false}).shareReplay(1)
        let allValid = Observable.combineLatest(usernameValid, passwordValid) { $0 && $1 }.shareReplay(1)
        allValid.bind(to: loginButton.rx.isEnabled).addDisposableTo(disposeBag)
        
        usernameTextField.rx.controlEvent(.editingDidEndOnExit).subscribe(onNext: {[weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.passwordTextField.becomeFirstResponder()
            
        }).addDisposableTo(disposeBag)
        
        passwordTextField.rx.controlEvent(.editingDidEndOnExit).subscribe().addDisposableTo(disposeBag)
        
        let loginViewModel = LoginViewModel(input: (username: usernameTextField.rx.text.orEmpty.asObservable(), password: passwordTextField.rx.text.orEmpty.asObservable(), tap: loginButton.rx.tap.asObservable()))
        
        loginViewModel.isloading.bind(to: PKHUD.sharedHUD.rx.isAnimating).addDisposableTo(disposeBag)
        
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
    
    @IBAction func googleLoginAction(_ sender: Any) {
        view.endEditing(true)

    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        view.endEditing(true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        switch AppStyle.shared.theme {
        case .normal:
            return .default
        case .night:
            return .lightContent
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

/**
extension LoginViewController: GIDSignInUIDelegate {
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        dismiss(animated: true, completion: nil)
    }
}
**/
