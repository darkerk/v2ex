//
//  TimelineReplyViewCell.swift
//  V2EX
//
//  Created by wgh on 2017/3/15.
//  Copyright © 2017年 yitop. All rights reserved.
//

import UIKit

class TimelineReplyViewCell: UITableViewCell {

    @IBOutlet weak var topicTitleLabel: UILabel!
    @IBOutlet weak var replyContentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var reply: Reply? {
        willSet {
            if let model = newValue {
                topicTitleLabel.text = model.topic?.title
                replyContentLabel.text = model.content
                timeLabel.text = model.topic?.lastReplyTime
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
