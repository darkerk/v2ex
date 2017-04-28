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
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 1
    }
}

