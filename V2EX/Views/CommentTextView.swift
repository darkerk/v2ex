//
//  CommentTextView.swift
//  V2EX
//
//  Created by wgh on 2017/3/24.
//  Copyright © 2017年 wgh. All rights reserved.
//

import UIKit

class CommentTextView: UITextView {
    override func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = true
        delaysContentTouches = false
        isScrollEnabled = false
        isEditable = false
        isSelectable = true
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var location = point
        location.x -= textContainerInset.left
        location.y -= textContainerInset.top
        
        let characterIndex = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        if characterIndex < textStorage.length {
            if let _ = textStorage.attribute(NSLinkAttributeName, at: characterIndex, effectiveRange: nil) {
                return self
            }
            if let _ = textStorage.attribute(NSAttachmentAttributeName, at: characterIndex, effectiveRange: nil) {
                return self
            }
        }
        return nil
    }
}
