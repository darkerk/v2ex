//
//  TimelineHeaderView.swift
//  V2EX
//
//  Created by darker on 2017/3/15.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TimelineHeaderView: UIView {

    @IBOutlet weak var textLabel: UILabel!
    
    var heightUpdate = Variable<Bool>(false)
    
    var text: String? {
        willSet {
            if let content = newValue {
                textLabel.text = content
                layoutIfNeeded()
                let headHeight = self.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
                var rect = self.frame
                rect.size.height = headHeight
                self.frame = rect
                self.heightUpdate.value = true
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = AppStyle.shared.theme.cellBackgroundColor
        textLabel.textColor = AppStyle.shared.theme.black64Color
    }
}

extension Reactive where Base: TimelineHeaderView {
    var text: UIBindingObserver<Base, String?> {
        return UIBindingObserver(UIElement: self.base) { view, content in
            view.text = content
        }
    }
}
