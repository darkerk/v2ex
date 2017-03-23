//
//  Comment.swift
//  V2EX
//
//  Created by wgh on 2017/3/8.
//  Copyright © 2017年 wgh. All rights reserved.
//

import Foundation

struct Comment {
    var content: String = ""
    var time: String = ""
    var thanks: String = "0"
    var number: String = "0"
    var user: User?
}
