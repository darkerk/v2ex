//
//  TopicDetailsViewModel.swift
//  V2EX
//
//  Created by wgh on 2017/3/8.
//  Copyright © 2017年 yitop. All rights reserved.
//

import RxSwift
import Moya

class TopicDetailsViewModel {

    let content = Variable<String>("")
    let countTime = Variable<String>("")
    let sections = Variable<[TopicDetailsSection]>([])
    let updateTopic = Variable<Topic?>(nil)
    let loadMoreActivityIndicator = ActivityIndicator()
    
    var currentPage = 1
    
    private let disposeBag = DisposeBag()
    
    var topic: Topic
    
    init(topic: Topic) {
        self.topic = topic
        fetchDetails(href: topic.href)
    }
    
    func fetchDetails(href: String) {
        API.provider.request(.topicDetails(href: href, page: 0)).subscribe(onNext: { response in
            if let data = HTMLParser.shared.topicDetails(html: response.data) {
                var updateTopicInfo = self.topic
                updateTopicInfo.creatTime = data.creatTime
                self.updateTopic.value = updateTopicInfo
    
                self.content.value = data.content
                self.countTime.value = data.countTime
                self.currentPage = data.currentPage
                if data.currentPage > 1 {
                    self.sections.value = [TopicDetailsSection(type: .more, comments: [Comment()]), TopicDetailsSection(type: .comment, comments: data.comments)]
                }else {
                    self.sections.value = [TopicDetailsSection(type: .comment, comments: data.comments)]
                }
            }

        }, onError: {error in
            print(error)
        }).addDisposableTo(disposeBag)
    }

    func fetchMoreComments() {
        guard currentPage > 1 else {
            return
        }
        
        let page = currentPage - 1
        API.provider.request(.topicDetails(href: topic.href, page: page))
            .observeOn(MainScheduler.instance)
            .trackActivity(loadMoreActivityIndicator)
            .subscribe(onNext: { response in
            if let data = HTMLParser.shared.topicDetails(html: response.data) {
            
                self.sections.value[1].comments.insert(contentsOf: data.comments, at: 0)
                if data.currentPage < 2 && self.sections.value.count == 2 {
                    self.sections.value.remove(at: 0)
                }
                self.currentPage = data.currentPage
            }
            
        }, onError: { error in
            print(error)
        }).addDisposableTo(disposeBag)
    }
}
