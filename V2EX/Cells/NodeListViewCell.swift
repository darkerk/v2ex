//
//  NodeListViewCell.swift
//  V2EX
//
//  Created by wgh on 2017/4/26.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit

class NodeListViewCell: UITableViewCell {
    
    var node: Node? {
        willSet {
            if let item = newValue {
                textLabel?.text = item.name
                switch AppStyle.shared.theme {
                case .normal:
                    textLabel?.textColor = item.isCurrent ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 0.3137254902, green: 0.3137254902, blue: 0.3137254902, alpha: 1)
                case .night:
                    textLabel?.textColor = item.isCurrent ? #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1) : #colorLiteral(red: 0.6078431373, green: 0.6862745098, blue: 0.8, alpha: 1)
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = AppStyle.shared.theme.tableBackgroundColor
        self.contentView.backgroundColor = AppStyle.shared.theme.tableBackgroundColor
        let selectedView = UIView()
        selectedView.backgroundColor = AppStyle.shared.theme.cellSelectedBackgroundColor
        self.selectedBackgroundView = selectedView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
