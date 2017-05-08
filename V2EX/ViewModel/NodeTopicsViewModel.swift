//
//  NodeTopicsViewModel.swift
//  V2EX
//
//  Created by darker on 2017/3/20.
//  Copyright © 2017年 darker. All rights reserved.
//

import RxSwift
import Moya

class NodeTopicsViewModel {
    let items = Variable<[Topic]>([])
    let loadMoreEnabled = Variable<Bool>(false)
    let loadMoreCompleted = Variable<Bool>(false)
    let loadingActivityIndicator = ActivityIndicator()
    let shouldLogin = Variable<Bool>(false)
    var nodeHref: String = ""
    
    private var favoriteHref: String = ""
    private var currentPage = 1
    private var totalPage = 1
    private let disposeBag = DisposeBag()
    
    var isFavorited: Bool = false
    
    func fetcData(page: Int = 1) {
        let api = API.pageList(href: nodeHref, page: page)
        let observable = page > 1 ? API.provider.request(api) : API.provider.request(api).observeOn(MainScheduler.instance)
            .trackActivity(loadingActivityIndicator)
        observable.subscribe(onNext: { response in
            if let data = HTMLParser.shared.nodeTopics(html: response.data) {
                self.currentPage = data.currentPage
                self.totalPage = data.totalPage
                self.favoriteHref = data.favoriteHref
                self.isFavorited = data.favoriteHref.contains("/unfavorite/")
                
                if page == 1 {
                    self.shouldLogin.value = data.shouldLogin
                    self.items.value = data.topics
                }else {
                    self.items.value.append(contentsOf: data.topics)
                }
                self.loadMoreEnabled.value = data.totalPage > data.currentPage
                if page > 1 {
                    self.loadMoreCompleted.value = true
                }
            }
        }, onError: { error in
            print(error)
            self.loadMoreCompleted.value = true
        }).addDisposableTo(disposeBag)
    }
    
    func fetchMoreData() {
        guard currentPage < totalPage else {
            return
        }
        let page = currentPage + 1
        fetcData(page: page)
    }

    func sendFavorite(completion: ((Bool) -> Void)? = nil) {
        let isCancel = isFavorited
        let text = favoriteHref.components(separatedBy: "/node/").last
        let id = text?.components(separatedBy: "?").first ?? ""
        API.provider.request(.once()).flatMap { response -> Observable<Response> in
            if let once = HTMLParser.shared.once(html: response.data) {
                return API.provider.request(.favorite(type: .node(id: id, once: once), isCancel: isCancel))
            }else {
                return Observable.error(NetError.message(text: "获取once失败"))
            }
            }.shareReplay(1).subscribe(onNext: { response in
                self.isFavorited = !isCancel
                completion?(true)
            }, onError: {error in
                completion?(false)
            }).addDisposableTo(disposeBag)
    }
}
