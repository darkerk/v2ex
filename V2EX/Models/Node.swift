//
//  Node.swift
//  V2EX
//
//  Created by wgh on 2017/3/1.
//  Copyright © 2017年 yitop. All rights reserved.
//

import Foundation

struct Node {
    var name: String = ""
    var href: String = ""
    var isCurrent: Bool = false
    
    init(name: String, href: String, isCurrent: Bool = false) {
        self.name = name
        self.href = href
        self.isCurrent = isCurrent
    }
}
