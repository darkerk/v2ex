//
//  SettingViewModel.swift
//  V2EX
//
//  Created by wgh on 2017/3/21.
//  Copyright © 2017年 yitop. All rights reserved.
//

import RxSwift
import Moya

class SettingViewModel {
    private let disposeBag = DisposeBag()
    
    func uploadAvatar(imageData: Data, completion: ((_ newURLString: String?) -> Void)? = nil) {
        API.provider.request(.uploadOnce()).flatMap { response -> Observable<Response> in
            if let value = HTMLParser.shared.uploadOnce(html: response.data) {
                return API.provider.request(API.updateAvatar(imageData: imageData, once: value))
            }else {
                return Observable.just(response)
            }
            }.subscribe(onNext: { response in
                if let newURLString = HTMLParser.shared.uploadAvatar(html: response.data) {
                    completion?(newURLString)
                }else {
                    completion?(nil)
                }
            }, onError: {_ in
                completion?(nil)
            }).addDisposableTo(disposeBag)
    }
    
}
