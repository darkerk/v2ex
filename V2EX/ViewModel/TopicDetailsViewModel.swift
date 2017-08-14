//
//  TopicDetailsViewModel.swift
//  V2EX
//
//  Created by darker on 2017/3/8.
//  Copyright © 2017年 darker. All rights reserved.
//

import RxSwift
import Moya
import Kanna

class TopicDetailsViewModel {
    
    let content = Variable<String>("")
    let countTime = Variable<String>("")
    let sections = Variable<[TopicDetailsSection]>([])
    let updateTopic = Variable<Topic?>(nil)
    let loadingActivityIndicator = ActivityIndicator()
    let loadMoreActivityIndicator = ActivityIndicator()
    
    var currentPage = 1
    
    private let disposeBag = DisposeBag()
    
    var topic: Topic
    var htmlContent: String?
    init(topic: Topic) {
        self.topic = topic
        fetchDetails(href: topic.href)
    }
    
    func insertNew(text: String, atName: String?) {
        var atString = ""
        var string = text
        if let atName = atName {
            string = text.replacingOccurrences(of: "@\(atName) ", with: "")
            atString = "@<a href=\"/member/\(atName)\">\(atName)</a> "
        }
        let content = "<div class=\"reply_content\">\(atString)\(string)</div>"
        
        let number = currentPage > 1 ? sections.value[1].comments.count : sections.value[0].comments.count
        let comment = Comment(id: "", content: content, time: "刚刚", thanks: "0", number: "\(number + 1)", user: Account.shared.user.value)
        
        if currentPage > 1 {
            sections.value[1].comments.append(comment)
        }else {
            sections.value[0].comments.append(comment)
        }
    }
    
    func fetchDetails(href: String) {
        API.provider.request(.pageList(href: href, page: 0))
            .observeOn(MainScheduler.instance)
            .trackActivity(loadingActivityIndicator)
            .subscribe(onNext: { response in
            if let data = HTMLParser.shared.topicDetails(html: response.data) {
                self.topic.token = data.topic.token
                self.topic.isThank = data.topic.isThank
                self.topic.isFavorite = data.topic.isFavorite
                if let owner = data.topic.owner {
                    self.topic.owner = owner
                }
                if let node = data.topic.node {
                    self.topic.node = node
                }
                if !data.topic.title.isEmpty {
                    self.topic.title = data.topic.title
                }
                
                var updateTopicInfo = self.topic
                updateTopicInfo.creatTime = data.topic.creatTime
                self.updateTopic.value = updateTopicInfo
                
                self.content.value = data.topic.content
                self.countTime.value = data.countTime
                self.currentPage = data.currentPage
                if data.currentPage > 1 {
                    self.sections.value = [TopicDetailsSection(type: .more, comments: [Comment()]), TopicDetailsSection(type: .data, comments: data.comments)]
                }else {
                    self.sections.value = [TopicDetailsSection(type: .data, comments: data.comments)]
                }
                
                self.htmlContent = HTMLParser.shared.htmlContent(html: data.topic.content)
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
        API.provider.request(.pageList(href: topic.href, page: page))
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
    
    func sendComment(content: String, atName: String? = nil, completion: ((Swift.Error?) -> Void)? = nil) {
        API.provider.request(.once()).flatMap { response -> Observable<Response> in
            if let once = HTMLParser.shared.once(html: response.data) {
                return API.provider.request(API.comment(topicHref: self.topic.href, content: content, once: once))
            }else {
                return Observable.error(NetError.message(text: "获取once失败"))
            }
            }.shareReplay(1).subscribe(onNext: { response in
                self.insertNew(text: content, atName: atName)
                completion?(nil)
            }, onError: {error in
                completion?(error)
            }).addDisposableTo(disposeBag)
    }
    
    func sendThank(type: ThankType, completion: ((Bool) -> Void)? = nil) {
        topic.isThank = true
        API.provider.request(.thank(type: type, token: topic.token)).subscribe(onNext: {response in
            self.topic.isThank = true
            completion?(true)
        }, onError: {error in
            completion?(false)
        }).addDisposableTo(disposeBag)
    }
    
    func sendIgnore(completion: ((Bool) -> Void)? = nil) {
        API.provider.request(.once()).flatMap { response -> Observable<Response> in
            if let once = HTMLParser.shared.once(html: response.data) {
                return API.provider.request(API.ignoreTopic(id: self.topic.id, once: once))
            }else {
                return Observable.error(NetError.message(text: "获取once失败"))
            }
            }.shareReplay(1).subscribe(onNext: { response in
                completion?(true)
            }, onError: {error in
                completion?(false)
            }).addDisposableTo(disposeBag)
    }
    
    func sendFavorite(completion: ((Bool) -> Void)? = nil) {
        let isCancel = topic.isFavorite
        API.provider.request(.favorite(type: .topic(id: topic.id, token: topic.token), isCancel: isCancel)).subscribe(onNext: {response in
            self.topic.isFavorite = !isCancel
            completion?(true)
        }, onError: {error in
            completion?(false)
        }).addDisposableTo(disposeBag)
    }
}
