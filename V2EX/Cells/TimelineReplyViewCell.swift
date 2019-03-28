//
//  TimelineReplyViewCell.swift
//  V2EX
//
//  Created by darker on 2017/3/15.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit

class TimelineReplyViewCell: UITableViewCell {

    @IBOutlet weak var titleContentView: UIView!
    @IBOutlet weak var topicTitleLabel: UILabel!
    @IBOutlet weak var replyContentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var reply: Reply? {
        willSet {
            if let model = newValue {
                timeLabel.text = model.topic?.lastReplyTime
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 3
                
                let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: AppStyle.shared.theme.black102Color, NSAttributedString.Key.paragraphStyle: paragraphStyle]
                replyContentLabel.attributedText = NSAttributedString(string: model.content, attributes: attributes)
                
                if let title = model.topic?.title {
                    let titleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: AppStyle.shared.theme.black102Color, NSAttributedString.Key.paragraphStyle: paragraphStyle]
                    topicTitleLabel.attributedText = NSAttributedString(string: title, attributes: titleAttributes)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let selectedView = UIView()
        selectedView.backgroundColor = AppStyle.shared.theme.cellSelectedBackgroundColor
        self.selectedBackgroundView = selectedView
        
        self.backgroundColor = AppStyle.shared.theme.cellBackgroundColor
        timeLabel.textColor = AppStyle.shared.theme.black153Color
        titleContentView.backgroundColor = AppStyle.shared.theme.cellSubBackgroundColor
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
