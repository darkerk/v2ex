//
//  FavoriteItem.swift
//  V2EX
//
//  Created by wgh on 2017/3/20.
//  Copyright © 2017年 yitop. All rights reserved.
//

import UIKit

enum FavoriteItem {
    case topicItem(item: Topic)
    case followingItem(item: Topic)
    case nodeItem(item: Node)
}

