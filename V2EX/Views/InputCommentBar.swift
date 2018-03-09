//
//  InputCommentBar.swift
//  V2EX
//
//  Created by darker on 2017/3/27.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class InputCommentBar: UIToolbar {
    fileprivate lazy var textView: GrowingTextView = GrowingTextView()
    fileprivate lazy var sendButton = UIButton()
    private let disposeBag = DisposeBag()
    
    var shouldBeginEditing: ((Bool) -> Void)?
    
    var atName: String? {
        willSet {
            if let name = newValue {
                textView.text = "@\(name) "
            }
        }
    }
    
    private var atText: String {
        if let name = atName {
            return "@\(name) "
        }
        return ""
    }
    
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
        textView.backgroundColor = AppStyle.shared.theme.tableBackgroundColor
        if AppStyle.shared.theme == .night {
            textView.textColor = #colorLiteral(red: 0.6078431373, green: 0.6862745098, blue: 0.8, alpha: 1)
            textView.placeHolderColor = #colorLiteral(red: 0.4196078431, green: 0.4901960784, blue: 0.5490196078, alpha: 1)
            textView.clipsToBounds = true
            textView.layer.cornerRadius = 4
            
            textView.keyboardAppearance = .dark
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = AppStyle.shared.theme.barTintColor
        isTranslucent = false
        barTintColor = AppStyle.shared.theme.barTintColor
        addSubview(textView)
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        sendButton.setTitleColor(#colorLiteral(red: 0.2203660309, green: 0.5916196108, blue: 0.9413970709, alpha: 1), for: .normal)
        sendButton.setTitleColor(#colorLiteral(red: 0.2203660309, green: 0.5916196108, blue: 0.9413970709, alpha: 1).withAlphaComponent(0.6), for: .disabled)
        sendButton.setTitle("发送", for: .normal)
        addSubview(sendButton)
        
        sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4).isActive = true
        textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -5).isActive = true
        textView.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        
        textView.rx.text.orEmpty.map {[weak self] text -> Bool in
            let content = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if let atText = self?.atText {
                return !content.isEmpty && atText != content && !atText.contains(content)
            }
            return !content.isEmpty
            }.share(replay: 1).bind(to: sendButton.rx.isEnabled).disposed(by: disposeBag)
        
        
        
    }
    
    func clear() {
        textView.text = ""
    }
    
    func startEditing() {
        textView.becomeFirstResponder()
    }
    
    func endEditing(isClear: Bool = false) {
        if textView.isFirstResponder {
            textView.resignFirstResponder()
        }
        if isClear {
            clear()
        }
    }
    
    override var isFirstResponder: Bool {
        return textView.isFirstResponder
    }
}

extension InputCommentBar: GrowingTextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        shouldBeginEditing?(true)
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if !textView.text.isEmpty && !sendButton.isEnabled {
            clear()
        }
        shouldBeginEditing?(false)
        return true
    }
    
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        layoutIfNeeded()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            atName = nil
        }
    }
}

extension Reactive where Base: InputCommentBar {
    var sendEvent: ControlEvent<(String, String?)> {
        let source = self.base.sendButton.rx.tap.map {_ -> (String, String?) in
            return (self.base.textView.text, self.base.atName)
            }.share(replay: 1)
        return ControlEvent(events: source)
    }
}
