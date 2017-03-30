//
//  HomeViewModel.swift
//  V2EX
//
//  Created by wgh on 2017/3/29.
//  Copyright © 2017年 wgh. All rights reserved.
//

import RxSwift

class HomeViewModel {
    let sections = Variable<[TopicListSection]>([])
    let defaultNodes = Variable<[Node]>([])
    
    private let disposeBag = DisposeBag()
    
    init() {
        fetchTopics()
    }
    
    func fetchTopics(nodeHref: String = "") {
        API.provider.request(API.topics(nodeHref: nodeHref)).subscribe(onNext: { response in
            
            let nodes = HTMLParser.shared.homeNodes(html: response.data)
            if !nodes.isEmpty && self.defaultNodes.value.isEmpty {
                self.defaultNodes.value = nodes
            }
            let topics = HTMLParser.shared.homeTopics(html: response.data)
            self.sections.value = [TopicListSection(header: "home", topics: topics)]
            
        }, onError: {error in
            print(error)
        }).addDisposableTo(disposeBag)
    }
    
    func removeTopic(for id: String) {
        if sections.value.isEmpty {
            return
        }
        if let index = sections.value[0].topics.index(where: {$0.id == id}) {
            sections.value[0].topics.remove(at: index)
        }
    }
}
