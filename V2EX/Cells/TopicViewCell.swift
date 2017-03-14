//
//  TopicViewCell.swift
//  V2EX
//
//  Created by wgh on 2017/3/2.
//  Copyright © 2017年 yitop. All rights reserved.
//

import UIKit
import Kingfisher

class TopicViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nodeLabel: UILabel!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    var topic: Topic? {
        willSet {
            if let model = newValue {
                avatarView.kf.setImage(with: URL(string: model.owner?.avatar(.large) ?? ""))
                nodeLabel.text = " " + (model.node?.name ?? "") + " "
                ownerNameLabel.text = model.owner?.name
                timeLabel.text = model.lastReplyTime
                countLabel.text = model.replyCount
                titleLabel.text = model.title
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = 4.0
        nodeLabel.clipsToBounds = true
        nodeLabel.layer.cornerRadius = 4.0
        
        countLabel.clipsToBounds = true
        countLabel.layer.cornerRadius = 9
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
