//
//  FavoriteViewModel.swift
//  V2EX
//
//  Created by wgh on 2017/3/17.
//  Copyright © 2017年 wgh. All rights reserved.
//

import RxSwift
import Moya

enum FavoriteDataType: Int {
    case topic = 0, following = 1, node = 2
}

class FavoriteViewModel {
    let dataItems = Variable<[FavoriteItem]>([])
    let loadMoreEnabled = Variable<Bool>(false)
    
    private var topics: [FavoriteItem] = []
    private var followings: [FavoriteItem] = []
    private var nodes: [FavoriteItem] = []
    
    private var topicCurrentPage = 1
    private var topicTotalPage = 1
    
    private var followCurrentPage = 1
    private var followTotalPage = 1
    
    private var nodeCurrentPage = 1
    private var nodeTotalPage = 1
    
    var type: FavoriteDataType = .topic {
        didSet {
            if type != oldValue {
                dataItems.value.removeAll()
                switch type {
                case .topic:
                    if !topics.isEmpty {
                        dataItems.value.append(contentsOf: topics)
                        loadMoreEnabled.value = topicTotalPage > topicCurrentPage
                    }else {
                        fetcData()
                    }
                case .following:
                    if !followings.isEmpty {
                        dataItems.value.append(contentsOf:followings)
                        loadMoreEnabled.value = followTotalPage > followCurrentPage
                    }else {
                        fetcData()
                    }
                case .node:
                    if !nodes.isEmpty {
                        dataItems.value.append(contentsOf: nodes)
                        loadMoreEnabled.value = nodeTotalPage > nodeCurrentPage
                    }else {
                        fetcData()
                    }
                }
            }
        }
    }
    
    private let disposeBag = DisposeBag()
    
    init() {
        fetcData()
    }
    
    func fetcData(page: Int = 1, completion: (() -> Void)? = nil) {
        var api: API
        switch type {
        case .node:
            api = API.favoriteNodes(page: page)
        case .topic:
            api = API.favoriteTopics(page: page)
        case .following:
            api = API.favoriteFollowings(page: page)
        }
        API.provider.request(api).subscribe(onNext: { response in
            switch self.type {
            case .topic:
                if let data = HTMLParser.shared.favoriteTopicsAndFollowings(html: response.data) {
                    self.topicTotalPage = data.totalPage
                    
                    let items = data.topics.map({FavoriteItem.topicItem(item: $0)})
                    self.topics.append(contentsOf: items)
                    self.dataItems.value.append(contentsOf: items)
                
                    self.loadMoreEnabled.value = self.topicTotalPage > self.topicCurrentPage
                }
            case .following:
                if let data = HTMLParser.shared.favoriteTopicsAndFollowings(html: response.data) {
                    self.followTotalPage = data.totalPage
                    
                    let items = data.topics.map({FavoriteItem.followingItem(item: $0)})
                    self.followings.append(contentsOf: items)
                    self.dataItems.value.append(contentsOf: items)
                    
                    self.loadMoreEnabled.value = self.followTotalPage > self.followCurrentPage
                }
            case .node:
                if let data = HTMLParser.shared.favoriteNodes(html: response.data) {

                    let items = data.map({FavoriteItem.nodeItem(item: $0)})
                    self.nodes.append(contentsOf: items)
                    self.dataItems.value.append(contentsOf: items)
                    
                    self.loadMoreEnabled.value = self.nodeTotalPage > self.nodeCurrentPage
                }
            }
        }, onError: { error in
            print(error)
        }, onCompleted: {
            completion?()
        }).addDisposableTo(disposeBag)
    }
    
    func fetchMoreData(completion: (() -> Void)? = nil) {
        switch type {
        case .topic:
            guard topicCurrentPage < topicTotalPage else {
                return
            }
            topicCurrentPage += 1
            fetcData(page: topicCurrentPage, completion: completion)
        case .following:
            guard followCurrentPage < followTotalPage else {
                return
            }
            followCurrentPage += 1
            fetcData(page: followCurrentPage, completion: completion)
        case .node:
            guard nodeCurrentPage < nodeTotalPage else {
                return
            }
            nodeCurrentPage += 1
            fetcData(page: nodeCurrentPage, completion: completion)
        }
    }
    
    func removeItem(id: String) {
        switch type {
        case .topic:
            if let index = topics.index(where: {data -> Bool in
                switch data {
                case let .topicItem(item):
                    return item.id == id
                default:
                    return false
                }
            }) {
                topics.remove(at: index)
            }
            
            if let index = dataItems.value.index(where: {data -> Bool in
                switch data {
                case let .topicItem(item):
                    return item.id == id
                default:
                    return false
                }
            }) {
                dataItems.value.remove(at: index)
            }
            
        case .following:
            break
        case .node:
            break
        }
    }
}
