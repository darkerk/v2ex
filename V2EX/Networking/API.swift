//
//  API.swift
//  V2EX
//
//  Created by wgh on 2017/3/1.
//  Copyright © 2017年 yitop. All rights reserved.
//

import Foundation
import Moya

enum API {
    case once()
    case login(usernameKey: String, passwordKey: String, username: String, password: String, once: String)
    case topics(nodeHref: String)
    case topicDetails(href: String, page: Int)
    case timeline(userHref: String)
    case profileTopics(href: String, page: Int)
    case profileReplies(href: String, page: Int)
    case notifications(page: Int)
}

extension API: TargetType {
    var baseURL: URL {
        return URL(string: "https://www.v2ex.com")!
    }
    
    var task: Task {
        return .request
    }
    
    var path: String {
        switch self {
        case .once():
            return "/signin"
        case .login(_, _, _, _, _):
            return "/signin"
        case let .topicDetails(href, _):
            if href.contains("#") {
                return href.components(separatedBy: "#").first ?? ""
            }
            return href
        case let .timeline(userHref):
            return userHref
        case let .profileTopics(href, _), let .profileReplies(href, _):
            return href
        case .notifications(_):
            return "/notifications"
        default:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login(_, _, _, _, _):
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
        case let .topicDetails(_, page), let .profileTopics(_, page), let .profileReplies(_, page):
            return page == 0 ? nil : ["p": page]
        case let .notifications(page):
            return page == 0 ? nil : ["p": page]
        default:
            return nil
        }
    }
    
    var sampleData: Data {
        return Data()
    }
}

extension API {
    static let provider = RxMoyaProvider(endpointClosure: endpointClosure)
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
}
