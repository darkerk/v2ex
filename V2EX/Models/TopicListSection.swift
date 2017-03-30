//
//  TopicListSection.swift
//  V2EX
//
//  Created by wgh on 2017/3/29.
//  Copyright © 2017年 wgh. All rights reserved.
//

import RxDataSources

struct TopicListSection {
    var header: String
    var topics: [Topic]
    
    init(header: String, topics: [Topic]) {
        self.header = header
        self.topics = topics
    }
}

extension TopicListSection: AnimatableSectionModelType {
    typealias Identity = String
    typealias Item = Topic
    init(original: TopicListSection, items: [Item]) {
        self = original
        self.topics = items
    }

    var identity: String {
        return header
    }
    
    var items: [Topic] {
        return topics
    }
}

extension Topic: IdentifiableType, Equatable {
    typealias Identity = String
    
    var identity: String {
        return id
    }
    
    static func == (lhs: Topic, rhs: Topic) -> Bool {
        return lhs.id == rhs.id
    }
}

extension TopicListSection: Equatable {
    static func == (lhs: TopicListSection, rhs: TopicListSection) -> Bool {
        return lhs.identity == rhs.identity && lhs.items == rhs.items
    }
}
