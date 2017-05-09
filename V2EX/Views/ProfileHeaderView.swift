//
//  ProfileHeaderView.swift
//  V2EX
//
//  Created by darker on 2017/3/14.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit
import Kingfisher
import RxCocoa
import RxSwift

class ProfileHeaderView: UIView, ThemeUpdating {
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    var user: User? {
        willSet {
            if let model = newValue {
                avatarButton.setTitle("", for: .normal)
                avatarButton.kf.setBackgroundImage(with: URL(string: model.avatar(.large)), for: .normal)
                nameLabel.text = model.name
                nameLabel.isHidden = false
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarButton.clipsToBounds = true
        avatarButton.layer.cornerRadius = 40
        nameLabel.isHidden = true
        
        updateTheme()
    }
    
    func updateTheme() {
        backgroundColor = AppStyle.shared.theme.tableBackgroundColor
        nameLabel.textColor = AppStyle.shared.theme.black64Color
        if AppStyle.shared.theme == .night {
            avatarButton.backgroundColor = #colorLiteral(red: 0.1411764706, green: 0.2039215686, blue: 0.2784313725, alpha: 1)
        }else {
            avatarButton.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)
        }
        avatarButton.setTitleColor(AppStyle.shared.theme.black102Color, for: .normal)
    }
    
    func logout() {
        avatarButton.setTitle("登录", for: .normal)
        avatarButton.setBackgroundImage(nil, for: .normal)
        nameLabel.isHidden = true
    }
}

extension Reactive where Base: ProfileHeaderView {
    var user: UIBindingObserver<Base, User?> {
        return UIBindingObserver(UIElement: self.base) { view, value in
            view.user = value
        }
    }
    
    var isLoginEnabled: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { view, value in
            view.avatarButton.isUserInteractionEnabled = value
        }
    }
}
