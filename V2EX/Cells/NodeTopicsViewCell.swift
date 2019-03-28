//
//  NodeTopicsViewCell.swift
//  V2EX
//
//  Created by darker on 2017/3/20.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit
import Kingfisher

class NodeTopicsViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    var avatarTap: (() -> Void)?
    
    var topic: Topic? {
        willSet {
            if let model = newValue {
                avatarView.kf.setImage(with: URL(string: model.owner?.avatar(.large) ?? ""), placeholder: #imageLiteral(resourceName: "avatar_default"))
                ownerNameLabel.text = model.owner?.name
                countLabel.text = "  \(model.replyCount)  "
                countLabel.isHidden = model.replyCount == "0"
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 3
                
                let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: AppStyle.shared.theme.black64Color, NSAttributedString.Key.paragraphStyle: paragraphStyle]
                titleLabel.attributedText = NSAttributedString(string: model.title, attributes: attributes)
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
        
        ownerNameLabel.textColor = AppStyle.shared.theme.black102Color
        
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = 4.0
        
        countLabel.clipsToBounds = true
        countLabel.layer.cornerRadius = 9
        countLabel.backgroundColor = AppStyle.shared.theme.topicReplyCountBackgroundColor
        countLabel.textColor = AppStyle.shared.theme.topicReplyCountTextColor
        
        avatarView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(avatarTapAction(_:)))
        avatarView.addGestureRecognizer(tap)
    }
    
    @objc func avatarTapAction(_ sender: Any) {
        avatarTap?()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
