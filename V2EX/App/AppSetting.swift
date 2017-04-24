//
//  AppSetting.swift
//  V2EX
//
//  Created by darker on 2017/3/21.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import SafariServices
import SKPhotoBrowser

struct AppSetting {
    static var isCameraEnabled: Bool {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        return status != .restricted && status != .denied
    }
    
    static var isAlbumEnabled: Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        return status != .restricted && status != .denied
    }
    
    static func openWebBrowser(from viewController: UIViewController, URL: URL) {
        let browser = SFSafariViewController(url: URL)
        viewController.present(browser, animated: true, completion: nil)
    }
    
    static func openPhotoBrowser(from viewController: UIViewController, src: String) {
        let photo = SKPhoto.photoWithImageURL(src)
        photo.shouldCachePhotoURLImage = true
        
        let browser = SKPhotoBrowser(photos: [photo])
        browser.initializePageIndex(0)
        viewController.present(browser, animated: true, completion: nil)
    }
}
