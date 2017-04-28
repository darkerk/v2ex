//
//  TimelineTopicViewCell.swift
//  V2EX
//
//  Created by darker on 2017/3/15.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit

class TimelineTopicViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    var topic: Topic? {
        willSet {
            if let model = newValue {
                timeLabel.text = model.lastReplyTime
                countLabel.text = "  \(model.replyCount)  "
                countLabel.isHidden = model.replyCount == "0"
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 3
                
                let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 15), NSForegroundColorAttributeName: AppStyle.shared.theme.black102Color, NSParagraphStyleAttributeName: paragraphStyle]
                titleLabel.attributedText = NSAttributedString(string: model.title, attributes: attributes)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        countLabel.clipsToBounds = true
        countLabel.layer.cornerRadius = 9
        
        let selectedView = UIView()
        selectedView.backgroundColor = AppStyle.shared.theme.cellSelectedBackgroundColor
        self.selectedBackgroundView = selectedView
        
        self.backgroundColor = AppStyle.shared.theme.cellBackgroundColor
        timeLabel.textColor = AppStyle.shared.theme.black153Color
        countLabel.backgroundColor = AppStyle.shared.theme.topicReplyCountBackgroundColor
        countLabel.textColor = AppStyle.shared.theme.topicReplyCountTextColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
