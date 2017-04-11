//
//  Account.swift
//  V2EX
//
//  Created by wgh on 2017/3/6.
//  Copyright © 2017年 wgh. All rights reserved.
//

import Foundation
import RxSwift
import Moya

struct Account {
    var isDailyRewards = Variable<Bool>(false) //领取每日奖励
    let unreadCount = Variable<Int>(0)
    
    let user = Variable<User?>(nil)
    let isLoggedIn = Variable<Bool>(false)
    
    var privacy: Privacy = Privacy()
    
    private let disposeBag = DisposeBag()
    
    static var shared = Account()
    private init() {
    }
    
    mutating func logout() {
        isLoggedIn.value = false
        user.value = nil
        HTTPCookieStorage.shared.cookies?.forEach({ cookie in
            HTTPCookieStorage.shared.deleteCookie(cookie)
        })
    }
    
    func redeemDailyRewards() -> Observable<Response> {
        return API.provider.request(.once()).flatMap { response -> Observable<Response> in
            if let once = HTMLParser.shared.once(html: response.data) {
                return API.provider.request(.dailyRewards(once: once))
            }else {
                return Observable.error(NetError.message(text: "获取once失败"))
            }
            }.shareReplay(1)
    }
}
