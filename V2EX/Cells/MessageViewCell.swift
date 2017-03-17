//
//  MessageViewCell.swift
//  V2EX
//
//  Created by wgh on 2017/3/17.
//  Copyright © 2017年 yitop. All rights reserved.
//

import UIKit
import Kingfisher

class MessageViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var replyLabel: UILabel!
    @IBOutlet weak var topicLabel: UILabel!
    
    var message: Message? {
        willSet {
            if let model = newValue {
                avatarView.kf.setImage(with: URL(string: model.sender?.avatar(.large) ?? ""))
                nameLabel.text = model.sender?.name
                timeLabel.text = model.time
                topicLabel.text = model.topic?.title
                replyLabel.text = model.content
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = 4.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
