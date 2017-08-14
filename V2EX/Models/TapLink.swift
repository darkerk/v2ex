//
//  TapLink.swift
//  V2EX
//
//  Created by darker on 2017/3/31.
//  Copyright © 2017年 darker. All rights reserved.
//

import Foundation

enum TapLink {
    case user(info: User)
    case node(info: Node)
    case topic(info: Topic)
    case image(src: String)
    case web(url: URL)
}
