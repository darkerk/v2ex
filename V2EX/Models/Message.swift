//
//  Message.swift
//  V2EX
//
//  Created by darker on 2017/3/17.
//  Copyright © 2017年 darker. All rights reserved.
//

import Foundation

/// 消息提醒
struct Message {
    var sender: User?
    var topic: Topic?
    var time: String = ""
    var content: String = ""
    
}
