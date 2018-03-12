//
//  CreateTopicViewController.swift
//  V2EX
//
//  Created by darker on 2017/4/11.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import PKHUD

@objc protocol CreateTopicViewControllerDelegate: class {
    @objc optional func createTopicSuccess(viewcontroller: CreateTopicViewController)
}

class CreateTopicViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: PlaceHolderTextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textViewBottom: NSLayoutConstraint!
    @IBOutlet weak var lineView: UIView!
    
    weak var delegate: CreateTopicViewControllerDelegate?
    var nodeHref: String = ""
    
    fileprivate let disposeBag = DisposeBag()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppStyle.shared.theme.tableBackgroundColor
        textField.backgroundColor = AppStyle.shared.theme.tableBackgroundColor
        textField.attributedPlaceholder = NSAttributedString(string: "标题", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15), NSAttributedStringKey.foregroundColor: AppStyle.shared.theme.textPlaceHolderColor])
        
        textView.backgroundColor = AppStyle.shared.theme.tableBackgroundColor
        textView.placeHolderColor = AppStyle.shared.theme.textPlaceHolderColor
        if AppStyle.shared.theme == .night {
            textField.keyboardAppearance = .dark
            textView.keyboardAppearance = .dark
        }
        lineView.backgroundColor = AppStyle.shared.theme.separatorColor
        
        let titleValid = textField.rx.text.orEmpty.map({$0.isEmpty == false}).share(replay: 1)
        let contentValid = textView.rx.text.orEmpty.map({$0.isEmpty == false}).share(replay: 1)
        let allValid = Observable.combineLatest(titleValid, contentValid) { $0 && $1 }.share(replay: 1)
        allValid.bind(to: sendButton.rx.isEnabled).disposed(by: disposeBag)
        
        textField.rx.controlEvent(.editingDidEndOnExit).subscribe(onNext: {[weak textView] in
            textView?.becomeFirstResponder()
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        textField.becomeFirstResponder()
    }
    
    @IBAction func sendAction(_ sender: Any) {
        guard let titleText = textField.text, let content = textView.text else {
            return
        }
        view.endEditing(true)
        HUD.show()
        API.provider.request(.once()).flatMap { response -> Observable<Response> in
            if let once = HTMLParser.shared.once(html: response.data) {
                return API.provider.request(.createTopic(nodeHref: self.nodeHref, title: titleText, content: content, once: once))
            }else {
                return Observable.error(NetError.message(text: "获取once失败"))
            }
            }.share(replay: 1).subscribe(onNext: { response in
                HUD.showText("发布成功！")
                self.delegate?.createTopicSuccess?(viewcontroller: self)
                self.navigationController?.popViewController(animated: true)
            }, onError: {error in
                HUD.showText(error.message)
            }).disposed(by: disposeBag)
        
    }
    
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        guard let info = notification.userInfo as? [String: Any] else {
            return
        }
        
        let frameEnd = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let curve = (info[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue
        let options = UIViewAnimationOptions(rawValue: curve << 16)
        
        self.textViewBottom.constant = frameEnd.height
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: options,
                       animations: {
                        self.view.layoutIfNeeded()
        },
                       completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


