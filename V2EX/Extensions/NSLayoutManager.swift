//
//  NSLayoutManager.swift
//  V2EX
//
//  Created by wgh on 2017/6/30.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit

extension NSLayoutManager {
    
    func rangesForAttachment(attachment: NSTextAttachment) -> [NSRange]? {
        guard let textStorage = textStorage else {
            return nil
        }
        let range = NSRange(location: 0, length: textStorage.length)
        var ranges: [NSRange] = []
        textStorage.enumerateAttribute(NSAttachmentAttributeName, in: range, options: []) { (value, effectiveRange, nil) in
            if let value = value as? NSTextAttachment, value == attachment {
                ranges.append(effectiveRange)
            }
        }
        
        return ranges.isEmpty ? nil : ranges
    }
    
    func setNeedsLayout(forAttachment attachment: NSTextAttachment) {
        if let ranges = rangesForAttachment(attachment: attachment) {
            
            ranges.reversed().forEach({range in
                self.invalidateLayout(forCharacterRange: range, actualCharacterRange: nil)
                self.invalidateDisplay(forCharacterRange: range)
            })

        }
    }
    
    func setNeedsDisplay(forAttachment attachment: NSTextAttachment) {
        if let ranges = rangesForAttachment(attachment: attachment) {
            ranges.reversed().forEach({range in
                self.invalidateDisplay(forCharacterRange: range)
            })
        }
    }
}
