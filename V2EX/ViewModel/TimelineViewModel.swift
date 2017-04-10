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
    let loadingActivityIndicator = ActivityIndicator()
    
    var isFollowed: Bool = false
    var isBlockd: Bool = false
    
    private var tValue: String = ""
    private var idValue: String = ""
    
    private let disposeBag = DisposeBag()
    

    func fetcTimeline(href: String) {
        API.provider.request(API.timeline(userHref: href)).observeOn(MainScheduler.instance)
            .trackActivity(loadingActivityIndicator).subscribe(onNext: { response in
            if let data = HTMLParser.shared.timeline(html: response.data) {
                self.isFollowed = data.isFollowed
                self.isBlockd = data.isBlockd
                self.tValue = data.tValue
                self.idValue = data.idValue
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
    
    func sendFollow(completion: ((Bool) -> Void)? = nil) {
        let isCancel = isFollowed
        API.provider.request(.once()).flatMap { response -> Observable<Response> in
            if let once = HTMLParser.shared.once(html: response.data) {
                return API.provider.request(.follow(id: self.idValue, once: once, isCancel: isCancel))
            }else {
                return Observable.error(NetError.message(text: "获取once失败"))
            }
            }.shareReplay(1).subscribe(onNext: { response in
                self.isFollowed = !isCancel
                completion?(true)
            }, onError: {error in
                completion?(false)
            }).addDisposableTo(disposeBag)
    }
    
    func sendBlock(completion: ((Bool) -> Void)? = nil) {
        let isCancel = isBlockd
        API.provider.request(.block(id: idValue, token: tValue, isCancel: isCancel))
            .subscribe(onNext: { response in
                self.isBlockd = !isCancel
                completion?(true)
            }, onError: {error in
                completion?(false)
            }).addDisposableTo(disposeBag)
    }
}
