//
//  LoginButton.swift
//  V2EX
//
//  Created by darker on 2017/3/14.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class LoginButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 2
        layer.borderColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1).cgColor
        layer.borderWidth = 0.5
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 1
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
