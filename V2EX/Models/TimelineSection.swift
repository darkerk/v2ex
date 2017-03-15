//
//  TimelineSection.swift
//  V2EX
//
//  Created by wgh on 2017/3/14.
//  Copyright © 2017年 yitop. All rights reserved.
//

import Foundation
import RxDataSources

enum TimelineSection {
    case topic(title: String, items: [SectionTimelineItem])
    case reply(title: String, items: [SectionTimelineItem])
}

enum SectionTimelineItem {
    case topicItem(topic: Topic)
    case replyItem(reply: Reply)
}

extension TimelineSection: SectionModelType {
    typealias Item = SectionTimelineItem
    
    var items: [SectionTimelineItem] {
        switch self {
        case let .topic(_, items):
            return items.map({$0})
        case let .reply(_, items):
             return items.map({$0})
        }
    }
    
    init(original: TimelineSection, items: [Item]) {
        switch original {
        case let .topic(title, items):
            self = .topic(title: title, items: items)
        case let .reply(title, items):
            self = .reply(title: title, items: items)
        }
    }
}

extension TimelineSection {
    var title: String {
        switch self {
        case let .topic(title, _):
            return title
        case let .reply(title, _):
            return title
        }
    }
}
