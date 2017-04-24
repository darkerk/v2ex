//
//  MessageViewModel.swift
//  V2EX
//
//  Created by darker on 2017/3/17.
//  Copyright © 2017年 darker. All rights reserved.
//

import RxSwift
import Moya

class MessageViewModel {
    let items = Variable<[Message]>([])
    let loadMoreEnabled = Variable<Bool>(false)
    
    private var currentPage = 1
    private var totalPage = 1

    private let disposeBag = DisposeBag()
    
    init() {
        fetcData()
    }
    
    func fetcData(page: Int = 1, completion: (() -> Void)? = nil) {
        API.provider.request(.notifications(page: page)).subscribe(onNext: { response in
            if let data = HTMLParser.shared.notifications(html: response.data) {
                self.currentPage = data.currentPage
                self.totalPage = data.totalPage

                self.items.value.append(contentsOf: data.messages)
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
