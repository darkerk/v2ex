//
//  TopicDetailsCommentCell.swift
//  V2EX
//
//  Created by wgh on 2017/3/7.
//  Copyright © 2017年 yitop. All rights reserved.
//

import UIKit
import Kingfisher

class TopicDetailsCommentCell: UITableViewCell {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var floorLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var comment: Comment? {
        willSet {
            if let model = newValue {
                avatarView.kf.setImage(with: URL(string: model.user?.avatar(.large) ?? ""))
                nameLabel.text = model.user?.name
                textView.text = model.content
                floorLabel.text = "#" + model.number
                timeLabel.text = model.time
            }
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = 4.0
        
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
