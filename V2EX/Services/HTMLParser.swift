//
//  HTMLParser.swift
//  V2EX
//
//  Created by darker on 2017/3/1.
//  Copyright © 2017年 darker. All rights reserved.
//

import Foundation
import Kanna

struct HTMLParser {
    static let shared = HTMLParser()
    
    private init() {
    }
    
    // MARK: - 首页默认节点
    func homeNodes(html data: Data) -> [Node] {
        guard let html = HTML(html: data, encoding: .utf8) else {
            return []
        }
        
        var nodePath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][1]/div[@class='cell'][1]/a")
        let infoPath = html.xpath("//body/div[@id='Top']/div[@class='content']//table/tr/td[3]/a[1]")
        if let nameHref = infoPath.first?["href"], nameHref.hasPrefix("/member/") {
            //已经登录
            let username = nameHref.replacingOccurrences(of: "/member/", with: "")
            let src = infoPath.first?.xpath("./img").first?["src"] ?? ""
            Account.shared.user.value = User(name: username, href: nameHref, src: src)
            Account.shared.isLoggedIn.value = true
            
            let dailyPath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][1]/div[@class='inner']/a")
            if let href = dailyPath.first?["href"], href == "/mission/daily" {
                //领取今日的登录奖励
                Account.shared.isDailyRewards.value = true
                nodePath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][2]/div[@class='cell'][2]/a")
            }else {
                Account.shared.isDailyRewards.value = false
                nodePath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][1]/div[@class='cell'][2]/a")
            }
        }
        
        let nodes = nodePath.flatMap({e -> Node? in
            if let href = e["href"], let name = e.content, let className = e.className {
                return Node(name: name, href: href, isCurrent: className.hasSuffix("current"))
            }
            return nil
        })
        return nodes
    }
    
    // MARK: - 获取once
    func once(html data: Data) -> String? {
        guard let html = HTML(html: data, encoding: .utf8) else {
            return nil
        }
        if let onceElement = html.css("input").first(where: {$0["name"] == "once"}) {
            if let value = onceElement["value"] {
                return value
            }
        }
        return nil
    }
    
    // MARK: - 登录的用户名key，密码key，once值
    func keyAndOnce(html data: Data) -> (usernameKey: String, passwordKey: String, once: String)? {
        guard let html = HTML(html: data, encoding: .utf8) else {
            return nil
        }
        var unName = ""
        var pwName = ""
        var once = ""
        if let unElement = html.css(".sl").first(where: {$0["type"] == "text"}) {
            if let name = unElement["name"] {
                unName = name
            }
        }
        if let pwElement = html.css(".sl").first(where: {$0["type"] == "password"}) {
            if let name = pwElement["name"] {
                pwName = name
            }
        }
        if let onceElement = html.css("input").first(where: {$0["name"] == "once"}) {
            if let value = onceElement["value"] {
                once = value
            }
        }
        if !unName.isEmpty && !pwName.isEmpty && !once.isEmpty {
            return (unName, pwName, once)
        }
        return nil
    }
    
    // MARK: - 登录结果
    func loginResult(html data: Data) -> (user: User?, problem: String?) {
        guard let html = HTML(html: data, encoding: .utf8) else {
            return (nil, "登录失败，请稍后再试")
        }

        let problemPath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box']/div[@class='problem']/ul")
        if let problem = problemPath.first?.content {
            return (nil, problem)
        }
        
        let path = html.xpath("//body/div[@id='Top']/div[@class='content']/div/table/tr/td[3]/a[1]")
        if let href = path.first?["href"], href.contains("/member/")  {
            let name = href.replacingOccurrences(of: "/member/", with: "")
            let src = path.first?.xpath("./img").first?["src"] ?? ""
            let user = User(name: name, href: href, src: src)
            return (user, nil)
        }
        return (nil, "登录失败，请稍后再试")
    }
    
    // MARK: - 首页话题列表
    func homeTopics(html data: Data) -> [Topic] {
        guard let html = HTML(html: data, encoding: .utf8) else {
            return []
        }
        
        var path = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][1]")
        if Account.shared.isLoggedIn.value && Account.shared.isDailyRewards.value {
            path = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][2]")
        }
        
        let unreadPath = path.first?.xpath("./div[@class='cell'][1]/table/tr/td[1]/input")
        var unreadCount = "0"
        if let unreadChar = unreadPath?.first?["value"]?.characters.first {
            unreadCount = String(unreadChar)
        }
        
        if let count = Int(unreadCount) {
            Account.shared.unreadCount.value = count
        }

        let items = path.first?.xpath("./div[@class='cell item']").flatMap({e -> Topic? in
            if let userSrc = e.xpath(".//td[1]/a/img").first?["src"],
                let nodeHref = e.xpath(".//td[3]/span[1]/a").first?["href"],
                let nodeName = e.xpath(".//td[3]/span[1]/a").first?.content,
                let userHref = e.xpath(".//td[3]/span[1]/strong/a").first?["href"],
                let username = e.xpath(".//td[3]/span[1]/strong/a").first?.content,
                let topicHref = e.xpath(".//td[3]/span[2]/a[1]").first?["href"],
                let topicTitle = e.xpath(".//td[3]/span[2]/a[1]").first?.content,
                let lastReplyTime = e.xpath(".//td[3]/span[3]").first?.content {
                
                var lastReplyerUser: User?
                if let lastReplyerHref = e.xpath(".//td[3]/span[3]/strong/a").first?["href"],
                    let lastReplyerName = e.xpath(".//td[3]/span[3]/strong/a").first?.content {
                    lastReplyerUser = User(name: lastReplyerName, href: lastReplyerHref, src: "")
                }
                
                let owner = User(name: username, href: userHref, src: userSrc)
                let node = Node(name: nodeName, href: nodeHref)
                let replyCount = e.xpath(".//td[4]/a").first?.content ?? "0"
                let topic = Topic(title: topicTitle, href: topicHref, owner: owner, node: node, lastReplyTime: lastReplyTime, lastReplyUser: lastReplyerUser, replyCount: replyCount)
                
                return topic
            }
            return nil
        })
        return items ?? []
    }
    
    // MARK: - 节点导航
    func nodesNavigation(html data: Data) -> [(name: String, content: String)] {
        guard let html = HTML(html: data, encoding: .utf8) else {
            return []
        }
        let path = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][last()]/div[position()>1]")
        let items = path.flatMap { e -> (name: String, content: String)? in
            if let name = e.xpath("./table/tr/td[1]/span").first?.content,
                let content = e.xpath("./table/tr/td[2]").first?.innerHTML {
                return (name, content)
            }
            return nil
        }
        return items
    }
    
    // MARK: - 话题详情
    func topicDetails(html data: Data) -> (topic: Topic, currentPage: Int, countTime: String, comments: [Comment])? {
        guard let html = HTML(html: data, encoding: .utf8) else {
            return nil
        }
        
        let tokenPath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][1]/div[@class='inner']/div[@class='fr']/a[@class='op'][1]")
        let token = tokenPath.first?["href"]?.components(separatedBy: "?t=").last ?? ""
        let isFavorite = tokenPath.first?["href"]?.contains("unfavorite") ?? false
        
        let thankPath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][1]/div[@class='inner']/div[@class='fr']/div[@id='topic_thank']")
        let isThank = thankPath.first?.content?.contains("感谢已发送") ?? false
        
        let creatTimePath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][1]/div[@class='header']/small[@class='gray']")
        let creatTimeString = creatTimePath.first?.content ?? ""
        let creatTime = creatTimeString.components(separatedBy: " at ").last ?? ""
        
        let contentPath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][1]/div[@class='cell']/div[@class='topic_content']")
        let subtlePath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][1]/div[@class='subtle']")
        let subtle =  subtlePath.flatMap({$0.toHTML}).joined(separator: "")
        let content = (contentPath.first?.toHTML ?? "") + subtle
        
        let replyTimePath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][2]/div[@class='cell'][1]")
        let countTime = (replyTimePath.first?.content ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        let pagePath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][2]/div[starts-with(@class,'inner')]/*[contains(@class,'page_current')]")
        var currentPage = 1
        if let page = pagePath.first?.content {
            currentPage = Int(page) ?? 1
        }
        
        var owner: User?
        let headerPath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][1]/div[@class='header']")
        if let ownerHref = headerPath.first?.xpath("./div[@class='fr']/a").first?["href"],
            let ownerSrc = headerPath.first?.xpath("./div[@class='fr']/a/img").first?["src"],
            let ownerName = headerPath.first?.xpath("./small[@class='gray']/a").first?.content {
            owner = User(name: ownerName, href: ownerHref, src: ownerSrc)
        }
        
        var node: Node?
        if let nodeName = headerPath.first?.xpath("./a[2]").first?.content,
            let nodeHref = headerPath.first?.xpath("./a[2]").first?["href"] {
            node = Node(name: nodeName, href: nodeHref)
        }
        
        let title = headerPath.first?.xpath("./h1").first?.content ?? ""
        
        let replyContentPath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][2]/div[contains(@id,'r_')]")
        let comments = replyContentPath.flatMap({e -> Comment? in
            if let src = e.xpath("./table/tr/td[1]/img").first?["src"],
                let userHref = e.xpath("./table/tr/td[3]/strong/a").first?["href"],
                let userName = e.xpath("./table/tr/td[3]/strong/a").first?.content,
                let time = e.xpath("./table/tr/td[3]/span[1]").first?.content,
                let text = e.xpath("./table/tr/td[3]/div[@class='reply_content']").first?.toHTML {
                let thanks = e.xpath("./table/tr/td[3]/span[2]").first?.content ?? "0"
                let number = e.xpath("./table/tr/td[3]/div[@class='fr']/span[@class='no']").first?.content ?? "0"
                let user = User(name: userName, href: userHref, src: src)
                
                let replyId = e["id"]?.replacingOccurrences(of: "r_", with: "") ?? ""

                return Comment(id: replyId, content: text, time: time, thanks: thanks, number: number, user: user)
            }
            return nil
        })

        let topic = Topic(title: title, content: content, owner: owner, node: node, creatTime: creatTime, token: token, isFavorite: isFavorite, isThank: isThank)
        return (topic, currentPage, countTime, comments)
    }
    
    // MARK: - 个人的主题和回复
    func timeline(html data: Data) -> (joinTime: String, topicPrivacy: String, topics: [Topic], replys: [Reply], moreTopicHref: String, moreRepliesHref: String, isFollowed: Bool, isBlockd: Bool, tValue: String, idValue: String)? {
        guard let html = HTML(html: data, encoding: .utf8) else {
            return nil
        }
        
        let joinTimePath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][1]//table/tr/td[3]/span[@class='gray']")
        let joinTime = joinTimePath.first?.content ?? ""
        
        let privacyPath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][2]/div[@class='inner']/table/tr[2]/td")
        let topicPrivacy = privacyPath.first?.content ?? ""
        
        let topicPath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']//div[@class='cell item']")
        let topicItems = topicPath.flatMap({e -> Topic? in
            if let nodeHref = e.xpath("./table/tr/td[1]/span[1]/a[@class='node']").first?["href"],
                let nodeName = e.xpath("./table/tr/td[1]/span[1]/a[@class='node']").first?.content,
                let topicHref = e.xpath("./table/tr/td[1]/span[@class='item_title']/a").first?["href"],
                let topicTitle = e.xpath("./table/tr/td[1]/span[@class='item_title']/a").first?.content,
                let lastReplyTime = e.xpath("./table/tr/td[1]/span[3]").first?.content {
                
                var lastReplyerUser: User?
                if let lastReplyerHref = e.xpath("./table/tr/td[1]/span[3]/strong/a").first?["href"],
                    let lastReplyerName = e.xpath("./table/tr/td[1]/span[3]/strong/a").first?.content {
                    lastReplyerUser = User(name: lastReplyerName, href: lastReplyerHref, src: "")
                }
                
                let node = Node(name: nodeName, href: nodeHref)
                let replyCount = e.xpath("./table/tr/td[2]/a").first?.content ?? "0"
                let topic = Topic(title: topicTitle, href: topicHref, node: node, lastReplyTime: lastReplyTime, lastReplyUser: lastReplyerUser, replyCount: replyCount)
                
                return topic
            }
            return nil
        })
        
        let replyTopicPath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][last()]/div[@class='dock_area']")
        let replyContentPath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][last()]//div[@class='reply_content']")
        
        let replyItems = replyTopicPath.enumerated().flatMap { (i, e) -> Reply? in
            if let time = e.xpath("./table/tr[1]/td/div[@class='fr']/span[@class='fade']").first?.content,
                let topicTitle = e.xpath("./table/tr[1]/td/span[@class='gray']").first?.content,
                let topicHref = e.xpath("./table/tr[1]/td/span[@class='gray']/a").first?["href"] {
                
                let titleText = topicTitle.components(separatedBy: "›").last?.trimmingCharacters(in: .whitespacesAndNewlines) ?? topicTitle
                let topic = Topic(title: titleText, href: topicHref, lastReplyTime: time)
                var replyContent = ""
                if i < replyContentPath.count {
                    replyContent = replyContentPath[i].content ?? ""
                }
                let reply = Reply(content: replyContent.trimmingCharacters(in: .whitespacesAndNewlines), topic: topic)
                return reply
            }
            return nil
        }
        
        let moreTopicsPath = topicPath.first?.parent?.xpath("./div[@class='inner']/a")
        let moreTopicHref = moreTopicsPath?.first?["href"] ?? ""
        
        let moreRepliesPath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][last()]/div[@class='inner'][last()]/a")
        let moreRepliesHref = moreRepliesPath.first?["href"] ?? ""
        
        let followPath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][1]/div[1]/table/tr/td[3]/div[@class='fr']/input[1]")
        let blockPath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][1]/div[1]/table/tr/td[3]/div[@class='fr']/input[2]")
        let followHref = followPath.first?["onclick"]?.components(separatedBy: "location.href = '").last?.components(separatedBy: "'").first ?? ""
        let blockHref = blockPath.first?["onclick"]?.components(separatedBy: "location.href = '").last?.components(separatedBy: "'").first ?? ""
        let isFollowed = followHref.contains("unfollow")
        let tValue = blockHref.components(separatedBy: "?t=").last ?? ""
        let isBlockd = blockHref.contains("unblock")
        let idValue = followHref.components(separatedBy: "?t=").first?.components(separatedBy: "/").last ?? ""
        return (joinTime, topicPrivacy, topicItems, replyItems, moreTopicHref, moreRepliesHref, isFollowed, isBlockd, tValue, idValue)
    }
    
    // MARK: - 个人的全部主题
    func profileAllTopics(html data: Data) -> (totalCount: String, topics: [Topic], currentPage: Int, totalPage: Int)? {
        guard let html = HTML(html: data, encoding: .utf8) else {
            return nil
        }
        let totalPath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box']/div[@class='header']/div[@class='fr f12']/strong[@class='gray']")
        let totalCount = totalPath.first?.content ?? "0"
        
        let topicPath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box']/div[@class='cell item']")
        let topicItems = topicPath.flatMap({e -> Topic? in
            if let nodeHref = e.xpath("./table/tr/td[1]/span[1]/a[@class='node']").first?["href"],
                let nodeName = e.xpath("./table/tr/td[1]/span[1]/a[@class='node']").first?.content,
                let topicHref = e.xpath("./table/tr/td[1]/span[@class='item_title']/a").first?["href"],
                let topicTitle = e.xpath("./table/tr/td[1]/span[@class='item_title']/a").first?.content,
                let lastReplyTime = e.xpath("./table/tr/td[1]/span[3]").first?.content {
                
                var lastReplyerUser: User?
                if let lastReplyerHref = e.xpath("./table/tr/td[1]/span[3]/strong/a").first?["href"],
                    let lastReplyerName = e.xpath("./table/tr/td[1]/span[3]/strong/a").first?.content {
                    lastReplyerUser = User(name: lastReplyerName, href: lastReplyerHref, src: "")
                }
                
                let node = Node(name: nodeName, href: nodeHref)
                let replyCount = e.xpath("./table/tr/td[2]/a").first?.content ?? "0"
                let topic = Topic(title: topicTitle, href: topicHref, node: node, lastReplyTime: lastReplyTime, lastReplyUser: lastReplyerUser, replyCount: replyCount)
                
                return topic
            }
            return nil
        })
        
        let pagePath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box']/div[@class='inner']/table/tr/td[2]/strong")
        let pageTotal = pagePath.first?.content ?? "1/1"
        let currentPage = pageTotal.components(separatedBy: "/").first ?? "1"
        let totalPage = pageTotal.components(separatedBy: "/").last ?? "1"
        
        return (totalCount, topicItems, Int(currentPage)!, Int(totalPage)!)
    }
    
    // MARK: - 个人的全部回复
    func profileAllReplies(html data: Data) -> (totalCount: String, replies: [Reply], currentPage: Int, totalPage: Int)? {
        guard let html = HTML(html: data, encoding: .utf8) else {
            return nil
        }
        let totalPath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box']/div[@class='header']/div[@class='fr f12']/strong[@class='gray']")
        let totalCount = totalPath.first?.content ?? "0"
        
        let replyTopicPath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box']/div[@class='dock_area']")
        let replyContentPath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box']//div[@class='reply_content']")
        
        let replyItems = replyTopicPath.enumerated().flatMap { (i, e) -> Reply? in
            if let time = e.xpath("./table/tr[1]/td/div[@class='fr']/span[@class='fade']").first?.content,
                let topicTitle = e.xpath("./table/tr[1]/td/span[@class='gray']").first?.content,
                let topicHref = e.xpath("./table/tr[1]/td/span[@class='gray']/a").first?["href"] {
                
                let topic = Topic(title: topicTitle, href: topicHref, lastReplyTime: time)
                var replyContent = ""
                if i < replyContentPath.count {
                    replyContent = replyContentPath[i].content ?? ""
                }
                let reply = Reply(content: replyContent.trimmingCharacters(in: .whitespacesAndNewlines), topic: topic)
                return reply
            }
            return nil
        }
        
        let pagePath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box']/div[@class='inner']/table/tr/td[2]/strong")
        let pageTotal = pagePath.first?.content ?? "1/1"
        let currentPage = pageTotal.components(separatedBy: "/").first ?? "1"
        let totalPage = pageTotal.components(separatedBy: "/").last ?? "1"
        
        return (totalCount, replyItems, Int(currentPage)!, Int(totalPage)!)
    }
    
    // MARK: - 消息提醒
    func notifications(html data: Data) -> (messages: [Message], currentPage: Int, totalPage: Int)? {
        guard let html = HTML(html: data, encoding: .utf8) else {
            return nil
        }
        
        let path = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box']/div[@class='cell']")
        let items = path.flatMap { e -> Message? in
            if let userSrc = e.xpath("./table/tr/td[1]/a/img").first?["src"],
                let userHref = e.xpath("./table/tr/td[1]/a").first?["href"],
                let userName = e.xpath("./table/tr/td[2]/span[@class='fade']/a[1]/strong").first?.content,
                let time = e.xpath("./table/tr/td[2]/span[@class='snow']").first?.content,
                let topicTitle = e.xpath("./table/tr/td[2]/span[@class='fade']").first?.content,
                let topicHref = e.xpath("./table/tr/td[2]/span[@class='fade']/a[2]").first?["href"],
                let replyContent = e.xpath("./table/tr/td[2]/div[@class='payload']").first?.content {
                
                let sender = User(name: userName, href: userHref, src: userSrc)
                let topic = Topic(title: topicTitle, href: topicHref)
                
                return Message(sender: sender, topic: topic, time: time, content: replyContent)
            }
            
            return nil
        }
        
        let pagePath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box']/div[@class='inner'][last()]/table/tr/td[2]")
        let pageTotal = pagePath.first?.content ?? "1/1"
        let currentPage = pageTotal.components(separatedBy: "/").first ?? "1"
        let totalPage = pageTotal.components(separatedBy: "/").last ?? "1"
        
        return (items, Int(currentPage)!, Int(totalPage)!)
    }
    
    // MARK: - 收藏的话题和特别关注
    func favoriteTopicsAndFollowings(html data: Data) -> (totalPage: Int, topics: [Topic])? {
        guard let html = HTML(html: data, encoding: .utf8) else {
            return nil
        }
        
        let pagePath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box']/div[@class='cell'][1]/table/tr/td[1]/a")
        let totalPage = pagePath.count
        
        let path = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box']/div[@class='cell item']")
        let items = path.flatMap({e -> Topic? in
            if let userSrc = e.xpath("./table/tr/td[1]/a/img").first?["src"],
                let nodeHref = e.xpath("./table/tr/td[3]/span[@class='small fade']/a[@class='node']").first?["href"],
                let nodeName = e.xpath("./table/tr/td[3]/span[@class='small fade']/a[@class='node']").first?.content,
                let userHref = e.xpath("./table/tr/td[3]/span[@class='small fade']/strong[1]/a").first?["href"],
                let username = e.xpath("./table/tr/td[3]/span[@class='small fade']/strong[1]/a").first?.content,
                let topicHref = e.xpath("./table/tr/td[3]/span[@class='item_title']/a").first?["href"],
                let topicTitle = e.xpath("./table/tr/td[3]/span[@class='item_title']/a").first?.content {
                
                var lastReplyTime = e.xpath("./table/tr/td[3]/span[@class='small fade']").first?.content ?? ""
                lastReplyTime = lastReplyTime.components(separatedBy: "•  \(username)  •  ").last ?? ""
                
                var lastReplyerUser: User?
                if let lastReplyerHref = e.xpath("./table/tr/td[3]/span[@class='small fade']/strong[last()]/a").first?["href"],
                    let lastReplyerName = e.xpath("./table/tr/td[3]/span[@class='small fade']/strong[last()]/a").first?.content {
                    lastReplyerUser = User(name: lastReplyerName, href: lastReplyerHref, src: "")
                }
                
                let owner = User(name: username, href: userHref, src: userSrc)
                let node = Node(name: nodeName, href: nodeHref)
                let replyCount = e.xpath("./table/tr/td[4]/a").first?.content ?? "0"
                let topic = Topic(title: topicTitle, href: topicHref, owner: owner, node: node, lastReplyTime: lastReplyTime, lastReplyUser: lastReplyerUser, replyCount: replyCount)
                
                return topic
            }
            return nil
        })
        return (totalPage, items)
    }
    
    // MARK: - 收藏的节点
    func favoriteNodes(html data: Data) -> [Node]? {
        guard let html = HTML(html: data, encoding: .utf8) else {
            return nil
        }
        let path = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box']/div[@id='MyNodes']/a[@class='grid_item']")
        let items = path.flatMap({e -> Node? in
            if let href = e["href"],
                let icon = e.xpath("./div/img").first?["src"],
                let name = e.xpath("./div").first?.content,
                let comments = e.xpath("./div/span[@class='fade f12']").first?.content {
                
                let nodeName = name.replacingOccurrences(of: comments, with: "")
                let count = comments.trimmingCharacters(in: .whitespacesAndNewlines)
                
                return Node(name: nodeName, href: href, icon: icon, comments: Int(count)!)
            }
            
            return nil
        })
        return items
    }
    
    // MARK: - 节点的话题列表
    func nodeTopics(html data: Data) -> (shouldLogin: Bool, topics: [Topic], currentPage: Int, totalPage: Int, favoriteHref: String)? {
        guard let html = HTML(html: data, encoding: .utf8) else {
            return nil
        }
        
        if let title = html.xpath("//head/title").first?.content, title.contains("登录") {
            return (true, [], 0, 0, "")
        }

        let path = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][1]/div[@class='cell']")
        let items = path.flatMap({e -> Topic? in
            if let userSrc = e.xpath("./table/tr/td[1]/a/img").first?["src"],
                let userHref = e.xpath("./table/tr/td[1]/a").first?["href"],
                let username = e.xpath("./table/tr/td[3]/span[@class='small fade']/strong").first?.content,
                let topicHref = e.xpath("./table/tr/td[3]/span[@class='item_title']/a").first?["href"],
                let topicTitle = e.xpath("./table/tr/td[3]/span[@class='item_title']/a").first?.content {
                
                let owner = User(name: username, href: userHref, src: userSrc)
                let replyCount = e.xpath("./table/tr/td[4]/a[@class='count_livid']").first?.content ?? "0"
                let topic = Topic(title: topicTitle, href: topicHref, owner: owner, replyCount: replyCount)
                return topic
            }
            return nil
        })
        
        let pagePath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][1]/div[@class='inner'][last()]/table/tr/td[2]")
        let pageTotal = pagePath.first?.content ?? "1/1"
        let currentPage = pageTotal.components(separatedBy: "/").first ?? "1"
        let totalPage = pageTotal.components(separatedBy: "/").last ?? "1"
        
        let favoritePath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][1]/div[@class='header']/div[@class='fr f12']/a")
        let favoriteHref = favoritePath.first?["href"] ?? ""
        
        return (false, items, Int(currentPage)!, Int(totalPage)!, favoriteHref)
    }
    
    // MARK: - 上传头像成功后新头像
    func uploadAvatar(html data: Data) -> String? {
        guard let html = HTML(html: data, encoding: .utf8) else {
            return nil
        }
        let path1 = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@id='Main']/div[@class='box']/div[@class='message']")
        let success = path1.first?.content?.contains("成功") ?? false
        if success {
            let path2 = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@id='Main']/div[@class='box']/div[@class='inner']/form/table/tr[1]/td[2]/img[1]")
            return path2.first?["src"]
        }
        return nil
    }
    
    // MARK: - 隐私状态once值
    func privacyStatus(html data: Data) -> (once: String, onlineValue: Int, topicValue: Int, searchValue: Bool)? {
        guard let html = HTML(html: data, encoding: .utf8) else {
            return nil
        }
        let oncePath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@id='Main']/div[@class='box']/div[@class='inner']/form/table/tr[last()]//input[@name='once']")
        let once = oncePath.first?["value"] ?? ""
        
        let onlinePath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@id='Main']/div[@class='box']/div[@class='inner']/form/table//select[@name='who_can_view_my_online_status']/option")
        let topicPath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@id='Main']/div[@class='box']/div[@class='inner']/form/table//select[@name='who_can_view_my_topics_list']/option")
        let searchPath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@id='Main']/div[@class='box']/div[@class='inner']/form/table//select[@name='topics_indexable']/option")
        
        let currentOnlineValue = onlinePath.filter({$0["selected"] == "selected"}).first?["value"] ?? "0"
        let currentTopicValue = topicPath.filter({$0["selected"] == "selected"}).first?["value"] ?? "0"
        let currentSearchValue = searchPath.filter({$0["selected"] == "selected"}).first?["value"] ?? "0"
        
        return (once, Int(currentOnlineValue)!, Int(currentTopicValue)!, currentSearchValue == "1")
    }
}
