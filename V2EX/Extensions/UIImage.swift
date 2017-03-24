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
    
    convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        color.setFill()
        UIBezierPath(rect: CGRect(origin: CGPoint.zero, size: size)).fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
 
        self.init(cgImage: image!.cgImage!)
    }
    
    class func imageWithColor(_ color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        color.setFill()
        UIBezierPath(rect: CGRect(origin: CGPoint.zero, size: size)).fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
