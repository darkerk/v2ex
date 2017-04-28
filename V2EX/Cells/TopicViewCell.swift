//
//  TopicViewCell.swift
//  V2EX
//
//  Created by darker on 2017/3/2.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift

class TopicViewCell: UITableViewCell, ThemeUpdating {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nodeLabel: UILabel!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    var linkTap: ((TapLink) -> Void)?
    
    var topic: Topic? {
        willSet {
            if let model = newValue {
                avatarView.kf.setImage(with: URL(string: model.owner?.avatar(.large) ?? ""), placeholder: #imageLiteral(resourceName: "avatar_default"))
                nodeLabel.text = " " + (model.node?.name ?? "") + " "
                ownerNameLabel.text = model.owner?.name
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

    private let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = 4.0
        nodeLabel.clipsToBounds = true
        nodeLabel.layer.cornerRadius = 4.0
        
        countLabel.clipsToBounds = true
        countLabel.layer.cornerRadius = 9
        
        avatarView.isUserInteractionEnabled = true
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(userTapAction(_:)))
        avatarView.addGestureRecognizer(avatarTap)
        
        ownerNameLabel.isUserInteractionEnabled = true
        let nameTap = UITapGestureRecognizer(target: self, action: #selector(userTapAction(_:)))
        ownerNameLabel.addGestureRecognizer(nameTap)
        
        nodeLabel.isUserInteractionEnabled = true
        let nodeTap = UITapGestureRecognizer(target: self, action: #selector(nodeTapAction(_:)))
        nodeLabel.addGestureRecognizer(nodeTap)
        
        updateTheme()
        AppStyle.shared.themeUpdateVariable.asObservable().subscribe(onNext: { update in
            if update {
                self.updateTheme()
            }
        }).addDisposableTo(disposeBag)
    }
    
    func updateTheme() {
        let selectedView = UIView()
        selectedView.backgroundColor = AppStyle.shared.theme.cellSelectedBackgroundColor
        self.selectedBackgroundView = selectedView
        
        self.backgroundColor = AppStyle.shared.theme.cellBackgroundColor
        
        ownerNameLabel.textColor = AppStyle.shared.theme.black102Color
        nodeLabel.backgroundColor = AppStyle.shared.theme.topicCellNodeBackgroundColor
        nodeLabel.textColor = AppStyle.shared.theme.black153Color
        timeLabel.textColor = AppStyle.shared.theme.black153Color
        countLabel.backgroundColor = AppStyle.shared.theme.topicReplyCountBackgroundColor
        countLabel.textColor = AppStyle.shared.theme.topicReplyCountTextColor
        
        if let data = topic {
            topic = data
        }
    }
    
    func userTapAction(_ sender: Any) {
        if let user = topic?.owner {
            linkTap?(TapLink.user(info: user))
        }
    }
    
    func nodeTapAction(_ sender: Any) {
        if let node = topic?.node {
            linkTap?(TapLink.node(info: node))
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
