//
//  FavoriteItem.swift
//  V2EX
//
//  Created by darker on 2017/3/20.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit

enum FavoriteItem {
    case topicItem(item: Topic)
    case followingItem(item: Topic)
    case nodeItem(item: Node)
}

