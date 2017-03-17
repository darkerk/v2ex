//
//  HTMLParser.swift
//  V2EX
//
//  Created by wgh on 2017/3/1.
//  Copyright © 2017年 yitop. All rights reserved.
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
                //print(href)
                Account.shared.isDailyRewards = true
                nodePath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][2]/div[@class='cell'][2]/a")
            }else {
                Account.shared.isDailyRewards = false
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
    
    // MARK: - 首页话题列表
    func homeTopics(html data: Data) -> [Topic] {
        guard let html = HTML(html: data, encoding: .utf8) else {
            return []
        }
        
        var path = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][1]/div[@class='cell item']")
        if Account.shared.isLoggedIn.value {
            if Account.shared.isDailyRewards {
                path = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][2]/div[@class='cell item']")
            }else {
                path = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][1]/div[@class='cell item']")
            }
        }
        let items = path.flatMap({e -> Topic? in
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
        return items
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
    
    // MARK: - 登录用户的头像
    func userInfo(html data: Data) -> (username: String, avatar: String)? {
        guard let html = HTML(html: data, encoding: .utf8) else {
            return nil
        }
        if let element = html.css(".top").first(where: {$0["href"]?.hasPrefix("/member") == true}) {
            if let href = element["href"], let src = element.css("img").first?["src"] {
                let name = href.replacingOccurrences(of: "/member/", with: "")
                return (name, src)
            }
        }
        return nil
    }
    
    // MARK: - 话题详情
    func topicDetails(html data: Data) -> (creatTime: String, currentPage: Int, content: String, countTime: String, comments: [Comment])? {
        guard let html = HTML(html: data, encoding: .utf8) else {
            return nil
        }
        
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
        
        let replyContentPath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][2]/div[contains(@id,'r_')]")
        let comments = replyContentPath.flatMap({e -> Comment? in
            if let src = e.xpath("./table/tr/td[1]/img").first?["src"],
                let userHref = e.xpath("./table/tr/td[3]/strong/a").first?["href"],
                let userName = e.xpath("./table/tr/td[3]/strong/a").first?.content,
                let time = e.xpath("./table/tr/td[3]/span[1]").first?.content,
                let text = e.xpath("./table/tr/td[3]/div[@class='reply_content']").first?.content {
                let thanks = e.xpath("./table/tr/td[3]/span[2]").first?.content ?? "0"
                let number = e.xpath("./table/tr/td[3]/div[@class='fr']/span[@class='no']").first?.content ?? "0"
                let user = User(name: userName, href: userHref, src: src)
                
                return Comment(content: text, time: time, thanks: thanks, number: number, user: user)
            }
            return nil
        })
        return (creatTime, currentPage, content, countTime, comments)
    }
    
    // MARK: - 个人的主题和回复
    func timeline(html data: Data) -> (joinTime: String, topicPrivacy: String, topics: [Topic], replys: [Reply], moreTopicHref: String, moreRepliesHref: String)? {
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
        
        let moreTopicsPath = topicPath.first?.parent?.xpath("./div[@class='inner']/a")
        let moreTopicHref = moreTopicsPath?.first?["href"] ?? ""
        
        let moreRepliesPath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][last()]/div[@class='inner'][last()]/a")
        let moreRepliesHref = moreRepliesPath.first?["href"] ?? ""
        
        return (joinTime, topicPrivacy, topicItems, replyItems, moreTopicHref, moreRepliesHref)
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
}
