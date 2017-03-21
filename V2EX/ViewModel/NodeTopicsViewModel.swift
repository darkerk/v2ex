//
//  NodeTopicsViewModel.swift
//  V2EX
//
//  Created by wgh on 2017/3/20.
//  Copyright © 2017年 yitop. All rights reserved.
//

import RxSwift
import Moya

class NodeTopicsViewModel {
    let items = Variable<[Topic]>([])
    let loadMoreEnabled = Variable<Bool>(false)
    
    private var currentPage = 1
    private var totalPage = 1
    private var href: String = ""

    private let disposeBag = DisposeBag()
    
    init(href: String) {
        self.href = href
        fetcData()
    }
    
    func fetcData(page: Int = 1, completion: (() -> Void)? = nil) {
        let api = API.pageList(href: href, page: page)
        API.provider.request(api).subscribe(onNext: { response in
            if let data = HTMLParser.shared.nodeTopics(html: response.data) {
                self.currentPage = data.currentPage
                self.totalPage = data.totalPage

                self.items.value.append(contentsOf: data.topics)
                self.loadMoreEnabled.value = data.totalPage > data.currentPage
            }
        }, onError: { error in
            print(error)
        }, onCompleted: {
            completion?()
        }).addDisposableTo(disposeBag)
    }
    
    func fetchMoreData(completion: (() -> Void)? = nil) {
        guard currentPage < totalPage else {
            return
        }
        let page = currentPage + 1
        fetcData(page: page, completion: completion)
    }

}
