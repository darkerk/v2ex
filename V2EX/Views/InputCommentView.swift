//
//  InputCommentView.swift
//  V2EX
//
//  Created by wgh on 2017/3/24.
//  Copyright © 2017年 wgh. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class InputCommentView: UIView {
    fileprivate lazy var toolBar = UIToolbar()
    fileprivate lazy var textView: GrowingTextView = GrowingTextView()
    fileprivate lazy var sendButton = UIButton()
    
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.maxHeight = 80
        textView.placeHolder = "添加回复..."
        textView.placeHolderColor = UIColor(white: 0.8, alpha: 1.0)
        textView.placeHolderLeftMargin = 5.0
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.delegate = self
        
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        toolBar.barTintColor = UIColor.white
        toolBar.sizeToFit()
        toolBar.addSubview(textView)
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        sendButton.setTitleColor(#colorLiteral(red: 0.2203660309, green: 0.5916196108, blue: 0.9413970709, alpha: 1), for: .normal)
        sendButton.setTitleColor(#colorLiteral(red: 0.2203660309, green: 0.5916196108, blue: 0.9413970709, alpha: 1).withAlphaComponent(0.6), for: .disabled)
        sendButton.setTitle("发送", for: .normal)
        toolBar.addSubview(sendButton)
        
        sendButton.trailingAnchor.constraint(equalTo: toolBar.trailingAnchor, constant: -5).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: toolBar.centerYAnchor).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 50).isActive = true

        textView.leadingAnchor.constraint(equalTo: toolBar.leadingAnchor, constant: 4).isActive = true
        textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -5).isActive = true
        textView.topAnchor.constraint(equalTo: toolBar.topAnchor, constant: 5).isActive = true
        textView.bottomAnchor.constraint(equalTo: toolBar.bottomAnchor, constant: -4).isActive = true
        
        textView.rx.text.orEmpty.map({!$0.isEmpty}).shareReplay(1).bindTo(sendButton.rx.isEnabled).addDisposableTo(disposeBag)
    }
    
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        textView.becomeFirstResponder()
        return result
    }
    
    override func resignFirstResponder() -> Bool {
        if !isFirstResponder {
            return false
        }
        textView.resignFirstResponder()
        return super.resignFirstResponder()
    }
    
    override var inputAccessoryView: UIView? {
        return toolBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}

extension InputCommentView: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        toolBar.layoutIfNeeded()
    }
}

extension Reactive where Base: InputCommentView {
    var send: ControlProperty<String?> {
        let source: Observable<String?> = Observable.deferred { [weak source = self.base.textView] () -> Observable<String?> in
            return self.base.sendButton.rx.tap.map {_ in
                    return source?.text
                }
        }
        let bindingObserver = UIBindingObserver(UIElement: self.base.textView) { (textView, text: String?) in
            textView.text = text
        }
        return ControlProperty(values: source, valueSink: bindingObserver)
    }
}
