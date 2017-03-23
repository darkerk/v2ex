//
//  UIImage.swift
//  V2EX
//
//  Created by wgh on 2017/3/21.
//  Copyright © 2017年 wgh. All rights reserved.
//

import UIKit
import ImageIO

extension UIImage {
    func thumbnailForMaxPixelSize(_ size: UInt) -> UIImage {
        if let imageData = UIImageJPEGRepresentation(self, 1.0),
            let sourceRef = CGImageSourceCreateWithData(imageData as CFData, nil) {
            
            let options: [NSString: Any] = [
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceThumbnailMaxPixelSize: size]
            
            if let imageRef = CGImageSourceCreateThumbnailAtIndex(sourceRef, 0, options as CFDictionary?) {
                return UIImage(cgImage: imageRef)
            }
            return self
        }
        return self
    }
}
