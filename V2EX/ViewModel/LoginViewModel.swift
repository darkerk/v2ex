//
//  LoginViewModel.swift
//  V2EX
//
//  Created by darker on 2017/3/3.
//  Copyright © 2017年 darker. All rights reserved.
//

import RxSwift
import Moya

class LoginViewModel {
    
    let activityIndicator = ActivityIndicator()
    private var once = ""
    
    func loginRequest(username: String, password: String) -> Observable<Response> {
        return API.provider.request(.once()).flatMapLatest { response -> Observable<Response> in
            if let value = HTMLParser.shared.keyAndOnce(html: response.data) {
                self.once = value.once
                let api = API.login(usernameKey: value.usernameKey, passwordKey: value.passwordKey, username: username, password: password, once: value.once)
                return API.provider.request(api)
            }else {
                return Observable.error(NetError.message(text: "获取once失败"))
            }
        }.shareReplay(1).observeOn(MainScheduler.instance).trackActivity(self.activityIndicator)
    }
    
    func twoStepVerifyLogin(code: String) -> Observable<Response> {
        return API.provider.request(API.twoStepVerify(code: code, once: once)).observeOn(MainScheduler.instance).trackActivity(activityIndicator)
    }
}
