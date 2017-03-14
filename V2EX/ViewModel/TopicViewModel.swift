//
//  TopicViewModel.swift
//  V2EX
//
//  Created by wgh on 2017/3/3.
//  Copyright © 2017年 yitop. All rights reserved.
//

import RxSwift

class TopicViewModel {

    let topicItems = Variable<[Topic]>([])
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
            self.topicItems.value = topics
            
        }, onError: {error in
            print(error)
        }).addDisposableTo(disposeBag)
    }
}
