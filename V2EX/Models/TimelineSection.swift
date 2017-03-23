//
//  TimelineSection.swift
//  V2EX
//
//  Created by wgh on 2017/3/14.
//  Copyright © 2017年 wgh. All rights reserved.
//

import Foundation
import RxDataSources

enum TimelineSection {
    case topic(title: String, privacy: String, moreHref: String, items: [SectionTimelineItem])
    case reply(title: String, moreHref: String, items: [SectionTimelineItem])
}

enum SectionTimelineItem {
    case topicItem(topic: Topic)
    case replyItem(reply: Reply)
}

extension TimelineSection: SectionModelType {
    typealias Item = SectionTimelineItem
    
    var items: [SectionTimelineItem] {
        switch self {
        case let .topic(_, _, _, items):
            return items.map({$0})
        case let .reply(_, _ , items):
             return items.map({$0})
        }
    }
    
    init(original: TimelineSection, items: [Item]) {
        switch original {
        case let .topic(title, privacy, moreHref, items):
            self = .topic(title: title, privacy: privacy, moreHref: moreHref, items: items)
        case let .reply(title, moreHref, items):
            self = .reply(title: title, moreHref: moreHref, items: items)
        }
    }
}

extension TimelineSection {
    var title: String {
        switch self {
        case let .topic(title, _, _, _):
            return title
        case let .reply(title, _, _):
            return title
        }
    }
    
    var privacy: String {
        switch self {
        case let .topic(_,privacy, _, _):
            return privacy
        default:
            return ""
        }
    }
    
    var moreHref: String {
        switch self {
        case let .topic(_, _, moreHref, _):
            return moreHref
        case let .reply(_, moreHref, _):
            return moreHref
        }
    }
}
