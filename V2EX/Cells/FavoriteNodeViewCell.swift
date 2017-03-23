//
//  FavoriteNodeViewCell.swift
//  V2EX
//
//  Created by wgh on 2017/3/20.
//  Copyright © 2017年 wgh. All rights reserved.
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
        
        countLabel.clipsToBounds = true
        countLabel.layer.cornerRadius = 9
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
