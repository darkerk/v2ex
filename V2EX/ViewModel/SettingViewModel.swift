//
//  SettingViewModel.swift
//  V2EX
//
//  Created by darker on 2017/3/21.
//  Copyright © 2017年 darker. All rights reserved.
//

import RxSwift
import Moya

class SettingViewModel {
    var once: String = ""
    private let disposeBag = DisposeBag()

    func uploadAvatar(imageData: Data, completion: ((_ newURLString: String?) -> Void)? = nil) {
        API.provider.request(.once()).flatMap { response -> Observable<Response> in
            if let once = HTMLParser.shared.once(html: response.data) {
                return API.provider.request(API.updateAvatar(imageData: imageData, once: once))
            }else {
                return Observable.error(NetError.message(text: "获取once失败"))
            }
            }.subscribe(onNext: { response in
                if let newURLString = HTMLParser.shared.uploadAvatar(html: response.data) {
                    completion?(newURLString)
                }else {
                    completion?(nil)
                }
            }, onError: {_ in
                completion?(nil)
            }).disposed(by: disposeBag)
    }
    
    func fetchPrivacyStatus(completion: (() -> Void)? = nil) {
        API.provider.request(API.privacyOnce()).subscribe(onNext: { response in
            if let status = HTMLParser.shared.privacyStatus(html: response.data) {
                self.once = status.once
                Account.shared.privacy = Privacy(online: status.onlineValue, topic: status.topicValue, search: status.searchValue)
            }
            completion?()
        }) { error in
            completion?()
            }.disposed(by: disposeBag)
    }
    
    func setPrivacy(type: PrivacyType) {
        API.provider.request(API.privacy(type: type, once: once)).subscribe(onNext: { response in

        }, onError: {error in
            print("error: ", error)
        }).disposed(by: disposeBag)
    }
}
