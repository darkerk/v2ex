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
    private var keyOnce: (usernameKey: String, passwordKey: String, codeKey: String, once: String) = ("", "", "", "")
    
    func fetchCaptchaImage() -> Observable<UIImage> {
        return API.provider.request(.once()).flatMapLatest { response -> Observable<UIImage> in
            if let value = HTMLParser.shared.keyAndOnce(html: response.data) {
                self.keyOnce = value
                print("----> \(value.once)")
                return API.provider.request(API.captcha(once: value.once)).flatMapLatest({ resp -> Observable<UIImage> in
                    if let image = UIImage(data: resp.data) {
                        return Observable.just(image)
                    }
                    return Observable.error(NetError.message(text: "获取captcha图片失败"))
                })
            }else {
                return Observable.error(NetError.message(text: "获取once失败"))
            }
        }
    }
    
    func loginRequest(username: String, password: String, code: String) -> Observable<Response> {
        let api = API.login(usernameKey: keyOnce.usernameKey, passwordKey: keyOnce.passwordKey, codeKey: keyOnce.codeKey, username: username, password: password, code: code, once: keyOnce.once)
        return API.provider.request(api).shareReplay(1).observeOn(MainScheduler.instance).trackActivity(activityIndicator)
    }
    
    func twoStepVerifyLogin(code: String) -> Observable<Response> {
        return API.provider.request(API.twoStepVerify(code: code, once: keyOnce.once)).observeOn(MainScheduler.instance).trackActivity(activityIndicator)
    }
}
