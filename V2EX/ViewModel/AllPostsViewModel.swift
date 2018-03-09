//
//  AllPostsViewModel.swift
//  V2EX
//
//  Created by darker on 2017/3/15.
//  Copyright © 2017年 darker. All rights reserved.
//

import RxSwift
import Moya

enum AllPostsType {
    case topic, reply
}

class AllPostsViewModel {
    let items = Variable<[SectionTimelineItem]>([])
    let totalCount = Variable<String>("0")
    let loadMoreEnabled = Variable<Bool>(false)
    
    private var currentPage = 1
    private var totalPage = 1
    private var href: String = ""
    private var type: AllPostsType = .topic

    private let disposeBag = DisposeBag()
    
    init(href: String, type: AllPostsType) {
        self.href = href
        self.type = type
        fetcData()
    }
    
    func fetcData(page: Int = 1, completion: (() -> Void)? = nil) {
        let api = API.pageList(href: href, page: page)
        API.provider.request(api).subscribe(onNext: { response in
            switch self.type {
            case .topic:
                if let data = HTMLParser.shared.profileAllTopics(html: response.data) {
                    self.currentPage = data.currentPage
                    self.totalPage = data.totalPage
                    self.totalCount.value = data.totalCount
                    let topics = data.topics.flatMap({[SectionTimelineItem.topicItem(topic: $0)]})
                    self.items.value.append(contentsOf: topics)
                    
                    self.loadMoreEnabled.value = data.totalPage > data.currentPage
                }
            case .reply:
                if let data = HTMLParser.shared.profileAllReplies(html: response.data) {
                    self.currentPage = data.currentPage
                    self.totalPage = data.totalPage
                    self.totalCount.value = data.totalCount
                    let replies = data.replies.flatMap({[SectionTimelineItem.replyItem(reply: $0)]})
                    self.items.value.append(contentsOf: replies)

                    self.loadMoreEnabled.value = data.totalPage > data.currentPage
                }
            }
        }, onError: { error in
            print(error)
        }, onCompleted: {
            completion?()
        }).disposed(by: disposeBag)
    }
    
    func fetchMoreData(completion: (() -> Void)? = nil) {
        guard currentPage < totalPage else {
            return
        }
        let page = currentPage + 1
        fetcData(page: page, completion: completion)
    }
}
