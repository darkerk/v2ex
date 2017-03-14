//
//  ProfileHeaderView.swift
//  V2EX
//
//  Created by wgh on 2017/3/14.
//  Copyright © 2017年 yitop. All rights reserved.
//

import UIKit
import Kingfisher
import RxCocoa
import RxSwift

class ProfileHeaderView: UIView {
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
