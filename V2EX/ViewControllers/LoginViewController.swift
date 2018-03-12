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
import OnePasswordExtension

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
    @IBOutlet weak var line3View: UIImageView!
    @IBOutlet weak var captchaView: UIImageView!
    @IBOutlet weak var verifcodeTextField: UITextField!
    
    var viewModel: LoginViewModel = LoginViewModel()
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
            line3View.image = lineImage
            
            let attributes = [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.4196078431, green: 0.4901960784, blue: 0.5490196078, alpha: 1)]
            usernameTextField.attributedPlaceholder = NSAttributedString(string: "用户名或邮箱", attributes: attributes)
            passwordTextField.attributedPlaceholder = NSAttributedString(string: "密码", attributes: attributes)
            verifcodeTextField.attributedPlaceholder = NSAttributedString(string: "请输入下图中的验证码", attributes: attributes)
            
            usernameTextField.textColor = #colorLiteral(red: 0.6078431373, green: 0.6862745098, blue: 0.8, alpha: 1)
            passwordTextField.textColor = #colorLiteral(red: 0.6078431373, green: 0.6862745098, blue: 0.8, alpha: 1)
            verifcodeTextField.textColor = #colorLiteral(red: 0.6078431373, green: 0.6862745098, blue: 0.8, alpha: 1)
                
            loginButton.backgroundColor = #colorLiteral(red: 0.1411764706, green: 0.2039215686, blue: 0.2784313725, alpha: 1)
            loginButton.layer.borderColor = #colorLiteral(red: 0.1411764706, green: 0.2039215686, blue: 0.2784313725, alpha: 1).cgColor
            loginButton.setTitleColor(UIColor.white, for: .normal)
            loginButton.setTitleColor(#colorLiteral(red: 0.6078431373, green: 0.6862745098, blue: 0.8, alpha: 1), for: .disabled)
            
            usernameTextField.keyboardAppearance = .dark
            passwordTextField.keyboardAppearance = .dark
            verifcodeTextField.keyboardAppearance = .dark
        }
        
        if OnePasswordExtension.shared().isAppExtensionAvailable() {
            let bundlePath = Bundle(for: OnePasswordExtension.self).path(forResource: "OnePasswordExtensionResources", ofType: "bundle")
            let image = UIImage(named: AppStyle.shared.theme == .night ? "onepassword-button-light" : "onepassword-button",
                                in: Bundle(path: bundlePath!),
                                compatibleWith: nil)
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            button.setImage(image, for: .normal)
            button.addTarget(self, action: #selector(findLoginFrom1Password(_:)), for: .touchUpInside)
            passwordTextField.rightViewMode = .always
            passwordTextField.rightView = button
            
        }
        
        let usernameValid = usernameTextField.rx.text.orEmpty.map({$0.isEmpty == false}).share(replay: 1)
        let passwordValid = passwordTextField.rx.text.orEmpty.map({$0.isEmpty == false}).share(replay: 1)
       // let codeValid = verifcodeTextField.rx.text.orEmpty.map({$0.isEmpty == false}).shareReplay(1)
        let allValid = Observable.combineLatest(usernameValid, passwordValid) { $0 && $1 }.share(replay: 1)
        allValid.bind(to: loginButton.rx.isEnabled).disposed(by: disposeBag)
        
        usernameTextField.rx.controlEvent(.editingDidEndOnExit).subscribe(onNext: {[weak self] in
            self?.passwordTextField.becomeFirstResponder()
            
        }).disposed(by: disposeBag)
        
        passwordTextField.rx.controlEvent(.editingDidEndOnExit).subscribe().disposed(by: disposeBag)
        verifcodeTextField.rx.controlEvent(.editingDidEndOnExit).subscribe().disposed(by: disposeBag)
        
        viewModel.activityIndicator.asObservable().bind(to: PKHUD.sharedHUD.rx.isAnimating).disposed(by: disposeBag)
        
        viewModel.fetchCaptchaImage().asObservable().bind(to: captchaView.rx.image).disposed(by: disposeBag)
    }
    
    @objc func findLoginFrom1Password(_ sender: Any) {
        view.endEditing(true)
        OnePasswordExtension.shared().findLogin(forURLString: "www.v2ex.com", for: self, sender: sender) { (result, error) in
            if let result = result as? [String: String], let username = result[AppExtensionUsernameKey], let password = result[AppExtensionPasswordKey] {
                
                self.usernameTextField.text = username
                self.passwordTextField.text = password
                
                self.loginButton.isEnabled = true
                self.loginButton.sendActions(for: .touchUpInside)
            }
        }
    }
    
    func showTwoStepVerify() {
        let alert = UIAlertController(title: "两步验证登录", message: "你的 V2EX 账号已经开启了两步验证，请输入验证码继续", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        let action = UIAlertAction(title: "登录", style: .default, handler: {_ in
            let code = alert.textFields?.first?.text ?? ""
            
            self.viewModel.twoStepVerifyLogin(code: code).asObservable().subscribe(onNext: {[weak self] resp in
                let result = HTMLParser.shared.twoStepVerifyResult(html: resp.data)
                if let user = result.user {
                    Account.shared.user.value = user
                    Account.shared.isLoggedIn.value = true
                    self?.dismiss(animated: true, completion: nil)
                }else {
                    self?.showTwoStepVerify()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        let errorMsg = result.problem ?? "验证失败，请重新输入验证码"
                        HUD.showText(errorMsg)
                    })
                }
            }, onError: {[weak self] error in
                HUD.showText(error.message)
                self?.showTwoStepVerify()
            }).disposed(by: self.disposeBag)
        })
        alert.addTextField { textField in
            textField.keyboardType = .numberPad
            textField.placeholder = "验证码"
            textField.rx.text.orEmpty.map({$0.isEmpty == false}).share(replay: 1).bind(to: action.rx.isEnabled).disposed(by: self.disposeBag)
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func loginButtonAction(_ sender: Any) {
        guard let username = usernameTextField.text, let password = passwordTextField.text, let code = verifcodeTextField.text else {
            return
        }
        viewModel.loginRequest(username: username, password: password, code: code).subscribe(onNext: {[weak self] response in
            let result = HTMLParser.shared.loginResult(html: response.data)
            if result.isTwoStepVerification {
                self?.showTwoStepVerify()
                return
            }
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
        }).disposed(by: disposeBag)
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
