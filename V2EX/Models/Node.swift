//
//  Node.swift
//  V2EX
//
//  Created by wgh on 2017/3/1.
//  Copyright © 2017年 wgh. All rights reserved.
//

import Foundation

struct Node {
    var name: String = ""
    var href: String = ""
    var isCurrent: Bool = false
    
    var icon: String = ""
    var comments: Int = 0

    init(name: String, href: String, isCurrent: Bool = false, icon: String = "", comments: Int = 0) {
        self.name = name
        self.href = href
        self.isCurrent = isCurrent
        self.icon = icon
        self.comments = comments
    }
}

extension Node {
    var iconURLString: String {
        return "https:" + icon
    }
}
