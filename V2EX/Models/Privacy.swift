//
//  Privacy.swift
//  V2EX
//
//  Created by darker on 2017/3/22.
//  Copyright © 2017年 darker. All rights reserved.
//

import Foundation

struct Privacy {
    // 谁可以看到我的在线状态 0所有人 1已登录用户 2只有我自己
    var online: Int = 0
    // 谁可以看到我的主题列表 0所有人 1已登录用户 2只有我自己
    var topic: Int = 0
    // 是否允许搜索引擎索引我的主题
    var search: Bool = true
}
