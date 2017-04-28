//
//  UIImage.swift
//  V2EX
//
//  Created by darker on 2017/3/21.
//  Copyright © 2017年 darker. All rights reserved.
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
    
    func imageWithTintColor(_ tintColor: UIColor, blendMode: CGBlendMode = .destinationIn) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        tintColor.setFill()
        
        let rect = CGRect(origin: CGPoint.zero, size: size)
        UIRectFill(rect)
        
        //Draw the tinted image in context
        draw(in: rect, blendMode: blendMode, alpha: 1.0)
        if blendMode != .destinationIn {
            draw(in: rect, blendMode: .destinationIn, alpha: 1.0)
        }
        
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage!
    }
}
