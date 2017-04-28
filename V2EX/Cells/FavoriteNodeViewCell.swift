//
//  FavoriteNodeViewCell.swift
//  V2EX
//
//  Created by darker on 2017/3/20.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit
import Kingfisher

class FavoriteNodeViewCell: UITableViewCell {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    var node: Node? {
        willSet {
            if let model = newValue {
                iconView.kf.setImage(with: URL(string: model.iconURLString), placeholder: #imageLiteral(resourceName: "slide_menu_setting"))
                nameLabel.text = model.name
                countLabel.text = "  \(model.comments)  "
                countLabel.isHidden = model.comments == 0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = AppStyle.shared.theme.cellBackgroundColor
        contentView.backgroundColor = AppStyle.shared.theme.cellBackgroundColor
        let selectedView = UIView()
        selectedView.backgroundColor = AppStyle.shared.theme.cellSelectedBackgroundColor
        self.selectedBackgroundView = selectedView
        
        nameLabel.textColor = AppStyle.shared.theme.black64Color
        
        countLabel.clipsToBounds = true
        countLabel.layer.cornerRadius = 9
        countLabel.backgroundColor = AppStyle.shared.theme.topicReplyCountBackgroundColor
        countLabel.textColor = AppStyle.shared.theme.topicReplyCountTextColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
