//
//  Account.swift
//  V2EX
//
//  Created by darker on 2017/3/6.
//  Copyright © 2017年 darker. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import Kanna

struct Account {
    let isDailyRewards = Variable<Bool>(false) //领取每日奖励
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
        
        API.provider.request(.once()).flatMapLatest { response -> Observable<Response> in
            if let once = HTMLParser.shared.once(html: response.data) {
                return API.provider.request(API.logout(once: once))
            }else {
                return Observable.error(NetError.message(text: "获取once失败"))
            }
            }.share(replay: 1).subscribe(onNext: { response in
            
            }, onError: {error in
             
            }).disposed(by: disposeBag)
    }
    
    func redeemDailyRewards() -> Observable<Bool> {
        return API.provider.request(.once()).flatMapLatest { response -> Observable<Bool> in
            if let once = HTMLParser.shared.once(html: response.data) {
                return API.provider.request(.dailyRewards(once: once)).flatMapLatest({ resp-> Observable<Bool> in
                    do {
                        let html = try HTML(html: resp.data, encoding: .utf8)
                        let path = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box']/div[@class='message']")
                        if let content = path.first?.content, content.contains("已成功领取") {
                            return Observable.just(true)
                        }else {
                            return Observable.error(NetError.message(text: "领取奖励失败"))
                        }
                    } catch {
                        return Observable.error(NetError.message(text: "请求获取失败"))
                    }

                }).share(replay: 1)
            }else {
                return Observable.error(NetError.message(text: "获取once失败"))
            }
            }.share(replay: 1)
    }
}
