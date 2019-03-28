//
//  MessageViewCell.swift
//  V2EX
//
//  Created by darker on 2017/3/17.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit
import Kingfisher

class MessageViewCell: UITableViewCell {
    
    @IBOutlet weak var replyContentView: UIView!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var replyLabel: UILabel!
    @IBOutlet weak var topicLabel: UILabel!
    
    var message: Message? {
        willSet {
            if let model = newValue {
                avatarView.kf.setImage(with: URL(string: model.sender?.avatar(.large) ?? ""), placeholder: #imageLiteral(resourceName: "avatar_default"))
                nameLabel.text = model.sender?.name
                timeLabel.text = model.time

                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 3
                
                let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: AppStyle.shared.theme.black102Color, NSAttributedString.Key.paragraphStyle: paragraphStyle]
                replyLabel.attributedText = NSAttributedString(string: model.content, attributes: attributes)
                
                if let title = model.topic?.title {
                    let titleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: AppStyle.shared.theme.black102Color, NSAttributedString.Key.paragraphStyle: paragraphStyle]
                    topicLabel.attributedText = NSAttributedString(string: title, attributes: titleAttributes)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = 4.0
        
        let selectedView = UIView()
        selectedView.backgroundColor = AppStyle.shared.theme.cellSelectedBackgroundColor
        self.selectedBackgroundView = selectedView
        
        self.backgroundColor = AppStyle.shared.theme.cellBackgroundColor
        nameLabel.textColor = AppStyle.shared.theme.black64Color
        timeLabel.textColor = AppStyle.shared.theme.black153Color
        replyContentView.backgroundColor = AppStyle.shared.theme.cellSubBackgroundColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
