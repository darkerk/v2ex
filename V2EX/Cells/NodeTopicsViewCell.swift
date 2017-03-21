//
//  NodeTopicsViewCell.swift
//  V2EX
//
//  Created by wgh on 2017/3/20.
//  Copyright © 2017年 yitop. All rights reserved.
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
                avatarView.kf.setImage(with: URL(string: model.owner?.avatar(.large) ?? ""))
                ownerNameLabel.text = model.owner?.name
                countLabel.text = "  \(model.replyCount)  "
                titleLabel.text = model.title
                countLabel.isHidden = model.replyCount == "0"
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = 4.0
        
        countLabel.clipsToBounds = true
        countLabel.layer.cornerRadius = 9
        
        avatarView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(avatarTapAction(_:)))
        avatarView.addGestureRecognizer(tap)
    }
    
    func avatarTapAction(_ sender: Any) {
        avatarTap?()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
