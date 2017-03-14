//
//  Topic.swift
//  V2EX
//
//  Created by wgh on 2017/3/1.
//  Copyright © 2017年 yitop. All rights reserved.
//

import Foundation

struct Topic {
    var title: String = ""
    var href: String = ""
    var owner: User?
    var node: Node?
    var lastReplyTime: String = ""
    var lastReplyUser: User?
    var replyCount: String = "0"
    
    var creatTime: String = ""
    
    init(title: String = "", href: String = "", owner: User? = nil, node: Node? = nil, lastReplyTime: String = "", lastReplyUser: User? = nil, replyCount: String = "0", creatTime: String = "") {
        self.title = title
        self.href = href
        self.owner = owner
        self.node = node
        self.lastReplyTime = lastReplyTime
        self.lastReplyUser = lastReplyUser
        self.replyCount = replyCount
        self.creatTime = creatTime
    }
}
