//
//  TapLink.swift
//  V2EX
//
//  Created by wgh on 2017/3/31.
//  Copyright © 2017年 wgh. All rights reserved.
//

import Foundation

enum TapLink {
    case user(info: User)
    case node(info: Node)
    case image(src: String)
    case web(url: URL)
}
