//
//  ProfileMenuViewCell.swift
//  V2EX
//
//  Created by darker on 2017/3/14.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ProfileMenuViewCell: UITableViewCell, ThemeUpdating {

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
    
    func updateTheme() {
        self.backgroundColor = AppStyle.shared.theme.tableBackgroundColor
        contentView.backgroundColor = AppStyle.shared.theme.tableBackgroundColor
        let selectedView = UIView()
        selectedView.backgroundColor = AppStyle.shared.theme.cellSelectedBackgroundColor
        self.selectedBackgroundView = selectedView
        
        nameLabel.textColor = AppStyle.shared.theme.black64Color
    }
    
    func configure(image: UIImage, text: String) {
        iconView.image = AppStyle.shared.theme == .night ? image.imageWithTintColor(#colorLiteral(red: 0.6078431373, green: 0.6862745098, blue: 0.8, alpha: 1)) : image
        nameLabel.text = text
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension Reactive where Base: ProfileMenuViewCell {
    var unread: Binder<Int> {
        return Binder(self.base) { view, value in
            view.unreadCount = value
        }
    }
}
