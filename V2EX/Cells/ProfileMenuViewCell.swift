//
//  ProfileMenuViewCell.swift
//  V2EX
//
//  Created by wgh on 2017/3/14.
//  Copyright © 2017年 wgh. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ProfileMenuViewCell: UITableViewCell {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var unreadLabel: UILabel!
    
    var unreadCount: Int = 0 {
        willSet {
            unreadLabel.isHidden = newValue < 1
            unreadLabel.text = "  \(newValue)  "
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        unreadLabel.clipsToBounds = true
        unreadLabel.layer.cornerRadius = 9
        unreadLabel.isHidden = true
    }
    
    func configure(image: UIImage, text: String) {
        iconView.image = image
        nameLabel.text = text
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension Reactive where Base: ProfileMenuViewCell {
    var unread: UIBindingObserver<Base, Int> {
        return UIBindingObserver(UIElement: self.base) { view, value in
            view.unreadCount = value
        }
    }
}
