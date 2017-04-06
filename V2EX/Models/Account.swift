//
//  Account.swift
//  V2EX
//
//  Created by wgh on 2017/3/6.
//  Copyright © 2017年 wgh. All rights reserved.
//

import Foundation
import RxSwift

struct Account {
    var isDailyRewards = false //领取每日奖励
    
    let user = Variable<User?>(nil)
    let isLoggedIn = Variable<Bool>(false)
    
    var privacy: Privacy = Privacy()
    
    static var shared = Account()
    private init() {
    }
    
    mutating func logout() {
        isLoggedIn.value = false
        user.value = nil
        isDailyRewards = false
        HTTPCookieStorage.shared.cookies?.forEach({ cookie in
            HTTPCookieStorage.shared.deleteCookie(cookie)
        })
    }
    
}
