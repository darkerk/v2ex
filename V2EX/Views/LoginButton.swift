//
//  LoginButton.swift
//  V2EX
//
//  Created by wgh on 2017/3/14.
//  Copyright © 2017年 wgh. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class LoginButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 4
        layer.borderColor = #colorLiteral(red: 0.8235294118, green: 0.8235294118, blue: 0.8235294118, alpha: 1).cgColor
        layer.borderWidth = 0.5
    }
}

extension Reactive where Base: LoginButton {
    var isLoginEnabled: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { button, value in
            button.isEnabled = value
            button.layer.borderColor = value ? #colorLiteral(red: 0.2509803922, green: 0.2509803922, blue: 0.2509803922, alpha: 1).cgColor :  #colorLiteral(red: 0.8235294118, green: 0.8235294118, blue: 0.8235294118, alpha: 1).cgColor
        }
    }
}
