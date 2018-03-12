//
//  PlaceHolderTextView.swift
//  V2EX
//
//  Created by darker on 2017/4/11.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit

@IBDesignable
class PlaceHolderTextView: UITextView {

    @IBInspectable var placeHolder: NSString? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var placeHolderColor: UIColor = UIColor(white: 0.8, alpha: 1.0) {
        didSet {
            setNeedsDisplay()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: NSNotification.Name.UITextViewTextDidChange, object: self)
    }
    
    @objc func textDidChange(notification: Notification) {
        if let notificationObject = notification.object as? PlaceHolderTextView {
            if notificationObject === self {
                setNeedsDisplay()
            }
        }
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        if text.isEmpty {
            guard let placeHolder = placeHolder else { return }
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = textAlignment
            
            let rect = CGRect(x: textContainerInset.left + 5.0,
                              y: textContainerInset.top,
                              width:   frame.size.width - textContainerInset.left - textContainerInset.right,
                              height: frame.size.height)
            
            var attributes: [NSAttributedStringKey: Any] = [
                NSAttributedStringKey.foregroundColor: placeHolderColor,
                NSAttributedStringKey.paragraphStyle: paragraphStyle
            ]
            if let font = font {
                attributes[NSAttributedStringKey.font] = font
            }
            placeHolder.draw(in: rect, withAttributes: attributes)
        }
    }

}
