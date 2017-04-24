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

    var response: Observable<Response>
    var isloading: Observable<Bool>
    
    init(input: (username: Observable<String>, password: Observable<String>, tap: Observable<Void>)) {
        
        let activityIndicator = ActivityIndicator()
        isloading = activityIndicator.asObservable()
        
        let usernameAndPassword = Observable.combineLatest(input.username, input.password) { ($0, $1) }
        response = input.tap.withLatestFrom(usernameAndPassword).flatMapLatest { (username, password) -> Observable<Response> in
            return API.provider.request(.once()).flatMap { response -> Observable<Response> in
                if let value = HTMLParser.shared.keyAndOnce(html: response.data) {
                    let api = API.login(usernameKey: value.usernameKey, passwordKey: value.passwordKey, username: username, password: password, once: value.once)
                    return API.provider.request(api)
                }else {
                    return Observable.error(NetError.message(text: "获取once失败"))
                }
            }.shareReplay(1).observeOn(MainScheduler.instance).trackActivity(activityIndicator)
        }
    }
}
