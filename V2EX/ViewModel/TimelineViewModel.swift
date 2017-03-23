//
//  TimelineViewModel.swift
//  V2EX
//
//  Created by wgh on 2017/3/14.
//  Copyright © 2017年 wgh. All rights reserved.
//

import RxSwift
import Moya

class TimelineViewModel {
    let sections = Variable<[TimelineSection]>([])
    let joinTime = Variable<String>("")
    
    private let disposeBag = DisposeBag()
    
    init(href: String) {
        fetcTimeline(href: href)
    }
    
    func fetcTimeline(href: String) {
        API.provider.request(API.timeline(userHref: href)).subscribe(onNext: { response in
            if let data = HTMLParser.shared.timeline(html: response.data) {
                self.joinTime.value = data.joinTime
                var topicItems = data.topics.map({SectionTimelineItem.topicItem(topic: $0)})
                if !data.topicPrivacy.isEmpty {
                    topicItems = [SectionTimelineItem.topicItem(topic: Topic())]
                }
                let replyItems = data.replys.map({SectionTimelineItem.replyItem(reply: $0)})
                self.sections.value = [.topic(title: "创建的主题", privacy: data.topicPrivacy, moreHref: data.moreTopicHref, items: topicItems),
                                       .reply(title: "最近的回复", moreHref: data.moreRepliesHref, items: replyItems)]
            }
        }, onError: { error in
            print(error)
        }).addDisposableTo(disposeBag)
    }
}
