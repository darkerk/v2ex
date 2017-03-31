//
//  API.swift
//  V2EX
//
//  Created by wgh on 2017/3/1.
//  Copyright © 2017年 wgh. All rights reserved.
//

import Foundation
import Moya

enum PrivacyType {
    case online(value: Int)
    case topic(value: Int)
    case search(on: Bool)
}

enum ThankType {
    case topic(id: String)
    case reply(id: String)
}

enum API {
    /// once凭证
    case once()
    /// 登录
    case login(usernameKey: String, passwordKey: String, username: String, password: String, once: String)
    /// 首页话题（切换节点）
    case topics(nodeHref: String)
    /// 个人创建的话题和回复
    case timeline(userHref: String)
    /// 分页列表数据：话题详情评论、个人全部话题、个人全部回复
    case pageList(href: String, page: Int)
    /// 消息提醒
    case notifications(page: Int)
    /// 收藏的节点
    case favoriteNodes(page: Int)
    /// 收藏的话题
    case favoriteTopics(page: Int)
    /// 关注人的话题
    case favoriteFollowings(page: Int)
    /// 更换头像
    case updateAvatar(imageData: Data, once: String)
    /// 隐私设置once凭证
    case privacyOnce()
    /// 隐私设置
    case privacy(type: PrivacyType, once: String)
    /// 评论回复
    case comment(topicHref: String, content: String, once: String)
    /// 感谢话题或回复
    case thank(type: ThankType, token: String)
    /// 忽略主题
    case ignoreTopic(id: String, once: String)
    /// 收藏话题
    case favorite(id: String, token: String, isCancel: Bool)
}

extension API: TargetType {
    var baseURL: URL {
        return URL(string: "https://www.v2ex.com")!
    }
    
    var task: Task {
        switch self {
        case let .updateAvatar(imageData, once):
            return .upload(.multipart([MultipartFormData(provider: .data(imageData), name: "avatar", fileName: "avatar.jpeg", mimeType: "image/jpeg"),
                                       MultipartFormData(provider: .data(once.data(using: .utf8)!), name: "once")]))
        default:
            return .request
        }
    }
    
    var path: String {
        switch self {
        case .once():
            return "/signin"
        case .login(_, _, _, _, _):
            return "/signin"
        case let .timeline(userHref):
            return userHref
        case let .pageList(href, _), let .comment(href, _, _):
            if href.contains("#") {
                return href.components(separatedBy: "#").first ?? ""
            }
            return href
        case .notifications(_):
            return "/notifications"
        case .favoriteNodes(_):
            return "/my/nodes"
        case .favoriteTopics(_):
            return "/my/topics"
        case .favoriteFollowings(_):
            return "/my/following"
        case .updateAvatar(_):
            return "/settings/avatar"
        case .privacy(_, _), .privacyOnce():
            return "/settings/privacy"
        case let .thank(type, _):
            switch type {
            case let .topic(id):
                return "/thank/topic/\(id)"
            case let .reply(id):
                return "/thank/reply/\(id)"
            }
        case let .ignoreTopic(id, _):
            return "/ignore/topic/\(id)"
        case let .favorite(id, _, isCancel):
            return (isCancel ? "/unfavorite" :  "/favorite") + "/topic/\(id)"
        default:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login(_, _, _, _, _):
            return .post
        case .updateAvatar(_), .privacy(_, _), .comment(_, _, _), .thank(_, _):
            return .post
        default:
            return .get
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var parameters: [String : Any]? {
        switch self {
        case let .login(userNameKey, passwordKey, userName, password, once):
            return [userNameKey: userName, passwordKey: password, "once": once, "next": "/"]
        case let .topics(nodeHref):
            if nodeHref.isEmpty {
                return nil
            }
            let node = nodeHref.replacingOccurrences(of: "/?tab=", with: "")
            return ["tab": node]
        case let .pageList(_, page), let .notifications(page):
            return page == 0 ? nil : ["p": page]
        case let .favoriteNodes(page), let .favoriteTopics(page), let .favoriteFollowings(page):
            return page == 0 ? nil : ["p": page]
        case let .privacy(type, once):
            switch type {
            case let .online(value):
                return ["who_can_view_my_online_status": value, "once": once]
            case let .topic(value):
                return ["who_can_view_my_topics_list": value, "once": once]
            case let .search(on):
                return ["topics_indexable": on ? 1 : 0, "once": once]
            }
        case let .comment(_ , content, once):
            return ["content": content, "once": once]
        case let .thank(_, token), let .favorite(_, token, _):
            return ["t": token]
        case let .ignoreTopic(_, once):
            return ["once": once]
        default:
            return nil
        }
    }
    
    var sampleData: Data {
        return Data()
    }
}

extension API {
    static let provider = RxMoyaProvider(endpointClosure: endpointClosure, plugins: [networkActivityPlugin])
    static func endpointClosure(_ target: API) -> Endpoint<API> {
        let defaultEndpoint = MoyaProvider<API>.defaultEndpointMapping(for: target)
        switch target{
        case .once:
            let headers = ["Origin": "https://www.v2ex.com",
                           "Content-Type": "application/x-www-form-urlencoded"]
            return defaultEndpoint.adding(newHTTPHeaderFields: headers)
        case .login(_, _, _, _, _):
            let headers = ["Referer": "https://www.v2ex.com/signin",
                           "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 10_2_1 like Mac OS X) AppleWebKit/602.4.6 (KHTML, like Gecko) Version/10.0 Mobile/14D27 Safari/602.1"]
            return defaultEndpoint.adding(newHTTPHeaderFields: headers)
        default:
            let headers = ["User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 10_2_1 like Mac OS X) AppleWebKit/602.4.6 (KHTML, like Gecko) Version/10.0 Mobile/14D27 Safari/602.1"]
            return defaultEndpoint.adding(newHTTPHeaderFields: headers)
        }
    }
    
   static let networkActivityPlugin = NetworkActivityPlugin(networkActivityClosure: {(change: NetworkActivityChangeType) in
        switch change {
        case .began:
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        case .ended:
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    })
}
