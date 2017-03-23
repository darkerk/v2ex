//
//  AppSetting.swift
//  V2EX
//
//  Created by wgh on 2017/3/21.
//  Copyright © 2017年 wgh. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

struct AppSetting {
    static var isCameraEnabled: Bool {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        return status != .restricted && status != .denied
    }
    
    static var isAlbumEnabled: Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        return status != .restricted && status != .denied
    }
}
