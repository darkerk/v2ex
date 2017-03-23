//
//  AllPostsSection.swift
//  V2EX
//
//  Created by wgh on 2017/3/15.
//  Copyright © 2017年 wgh. All rights reserved.
//

import Foundation
import RxDataSources

struct AllPostsSection {
    var type: SectionType
    var data: [SectionTimelineItem]
    
    init(type: SectionType, data: [SectionTimelineItem]) {
        self.type = type
        self.data = data
    }
}

extension AllPostsSection: AnimatableSectionModelType {
    typealias Identity = SectionType
    typealias Item = SectionTimelineItem
    init(original: AllPostsSection, items: [Item]) {
        self = original
        self.data = items
    }
    
    var identity: SectionType {
        return type
    }
    
    var items: [SectionTimelineItem] {
        return data
    }
}

extension SectionTimelineItem: IdentifiableType, Equatable {
    typealias Identity = String
    
    var identity: String {
        switch self {
        case let .topicItem(topic):
            return topic.href
        case let .replyItem(reply):
            return reply.topic?.href ?? ""
        }
    }
    
    static func == (lhs: SectionTimelineItem, rhs: SectionTimelineItem) -> Bool {
        return lhs.identity == lhs.identity
    }
}

extension AllPostsSection: Equatable {
    static func == (lhs: AllPostsSection, rhs: AllPostsSection) -> Bool {
        return lhs.type == rhs.type && lhs.items == rhs.items
    }
}
