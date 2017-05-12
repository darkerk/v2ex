//
//  NSLayoutManager.swift
//  V2EX
//
//  Created by darker on 2017/5/12.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit

extension NSLayoutManager {
    
    private func rangesForAttachment(_ attachment: NSTextAttachment) -> [NSRange]? {
        guard let attributedString = self.textStorage else {
            return nil
        }
        
        // find character range for this attachment
        let range = NSRange(location: 0, length: attributedString.length)
        var refreshRanges = [NSRange]()
        
        attributedString.enumerateAttribute(NSAttachmentAttributeName, in: range, options: []) { (value, effectiveRange, nil) in
            guard let foundAttachment = value as? NSTextAttachment, foundAttachment == attachment else {
                return
            }
            // add this range to the refresh ranges
            refreshRanges.append(effectiveRange)
        }
        
        if refreshRanges.count == 0 {
            return nil
        }
        return refreshRanges
    }
    
    /// Trigger a relayout for an attachment
    func setNeedsLayout(forAttachment attachment: NSTextAttachment) {
        guard let ranges = rangesForAttachment(attachment) else {
            return
        }

        // invalidate the display for the corresponding ranges
        ranges.reversed().forEach { (range) in
            self.invalidateLayout(forCharacterRange: range, actualCharacterRange: nil)
//            // also need to trigger re-display or already visible images might not get updated
//            self.invalidateDisplay(forCharacterRange: range)
        }
    }
    
    /// Trigger a re-display for an attachment
    func setNeedsDisplay(forAttachment attachment: NSTextAttachment) {
        guard let ranges = rangesForAttachment(attachment) else {
            return
        }
        // invalidate the display for the corresponding ranges
        ranges.reversed().forEach { (range) in
            self.invalidateDisplay(forCharacterRange: range)
        }
    }
}
