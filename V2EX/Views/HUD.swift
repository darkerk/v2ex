//
//  HUD.swift
//  V2EX
//
//  Created by darker on 2017/3/14.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit
import PKHUD
import RxSwift
import RxCocoa

class HUDLoadingView: PKHUDRotatingImageView {
    
    static let defaultFrame = CGRect(origin: CGPoint.zero, size: CGSize(width: 100.0, height: 100.0))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(image: UIImage?, title: String? = nil, subtitle: String? = nil) {
        super.init(image: image, title: title, subtitle: subtitle)
        self.frame = HUDLoadingView.defaultFrame
        self.imageView.contentMode = .scaleAspectFit
    }
}

extension HUD {
    static func show() {
        HUD.dimsBackground = true
        PKHUD.sharedHUD.effect = UIBlurEffect(style: .extraLight)
        PKHUD.sharedHUD.contentView = HUDLoadingView(image: UIImage(named: "hud_progress"))
        PKHUD.sharedHUD.show(onView: UIApplication.shared.windows.last)
    }
    
    static func showSuccess(_ text: String? = nil) {
        PKHUD.sharedHUD.effect = UIBlurEffect(style: .extraLight)
        HUD.flash(.labeledSuccess(title: nil, subtitle: text), onView: UIApplication.shared.windows.last, delay: 3)
    }
    
    static func showText(_ text: String, delay: TimeInterval = 2) {
        PKHUD.sharedHUD.effect = UIBlurEffect(style: .extraLight)
        HUD.flash(.label(text), onView: UIApplication.shared.windows.last, delay: delay)
    }
}

extension Reactive where Base: PKHUD {
    var isAnimating: Binder<Bool> {
        return Binder(self.base, binding: { (hud, animating) in
            if animating {
                HUD.show()
            }else {
                HUD.hide(animated: true)
            }
        })
    }
}
