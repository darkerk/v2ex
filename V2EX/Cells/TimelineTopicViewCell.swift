//
//  TimelineTopicViewCell.swift
//  V2EX
//
//  Created by wgh on 2017/3/15.
//  Copyright © 2017年 wgh. All rights reserved.
//

import UIKit

class TimelineTopicViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    var topic: Topic? {
        willSet {
            if let model = newValue {
                titleLabel.text = model.title
                timeLabel.text = model.lastReplyTime
                countLabel.text = "  \(model.replyCount)  "
                countLabel.isHidden = model.replyCount == "0"
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
