//
//  TopicDetailsHeaderView.swift
//  V2EX
//
//  Created by darker on 2017/3/9.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa
import Kingfisher

class TopicDetailsHeaderView: UIView {
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nodeLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    lazy var webView: WKWebView = WKWebView()
    
    private var cssText = ""
    
    var linkTap: ((TapLink) -> Void)?
    var heightUpdate = Variable<Bool>(false)
    
    var topic: Topic? {
        willSet {
            if let model = newValue {
                avatarView.isUserInteractionEnabled = true
                avatarView.kf.setImage(with: URL(string: model.owner?.avatar(.large) ?? ""))
                nameLabel.text = model.owner?.name
                timeLabel.text = model.creatTime.components(separatedBy: ",").first
                titleLabel.text = model.title
                
                if let node = model.node {
                    nodeLabel.text = " " + node.name + " "
                    nodeLabel.isHidden = false
                }else {
                    nodeLabel.isHidden = true
                }
            }
        }
    }
    
    var htmlString: String? {
        willSet {
            if let content = newValue {
                if content.isEmpty {
                    let headHeight = titleView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
                    var rect = self.frame
                    rect.size.height = headHeight
                    self.frame = rect
                    self.heightUpdate.value = true
                }else {
                    let head = "<head><meta name=\"viewport\" content=\"width=device-width, user-scalable=no\"><style>\(cssText)</style></head>"
                    let body = "<body><div id=\"Wrapper\">\(content)</div></body>"
                    let html = "<html>\(head)\(body)</html>"
                    webView.loadHTMLString(html, baseURL: URL(string: "https://www.v2ex.com"))
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = 4.0
        
        nodeLabel.clipsToBounds = true
        nodeLabel.layer.cornerRadius = 4.0
        
        webView.scrollView.delaysContentTouches = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = self
        contentView.addSubview(webView)
        
        webView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        let lineView = UIView()
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = UIColor(red: 0.783922, green: 0.780392, blue: 0.8, alpha: 1)
        addSubview(lineView)
        
        lineView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor).isActive = true
        lineView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor).isActive = true
        lineView.bottomAnchor.constraint(equalTo: titleView.bottomAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        avatarView.isUserInteractionEnabled = true
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(userTapAction(_:)))
        avatarView.addGestureRecognizer(avatarTap)
        
        nameLabel.isUserInteractionEnabled = true
        let nameTap = UITapGestureRecognizer(target: self, action: #selector(userTapAction(_:)))
        nameLabel.addGestureRecognizer(nameTap)
        
        nodeLabel.isUserInteractionEnabled = true
        let nodeTap = UITapGestureRecognizer(target: self, action: #selector(nodeTapAction(_:)))
        nodeLabel.addGestureRecognizer(nodeTap)
        
        if AppStyle.shared.theme == .night {
            lineView.backgroundColor = UIColor.black
        }
        
        backgroundColor = AppStyle.shared.theme.cellBackgroundColor
        titleView.backgroundColor = backgroundColor
        contentView.backgroundColor = backgroundColor
        nameLabel.textColor =  AppStyle.shared.theme.black64Color
        timeLabel.textColor = AppStyle.shared.theme.black153Color
        nodeLabel.backgroundColor = AppStyle.shared.theme.topicCellNodeBackgroundColor
        nodeLabel.textColor = AppStyle.shared.theme.black153Color
        titleLabel.textColor = AppStyle.shared.theme.black64Color
        
        cssText = AppStyle.shared.css.replacingOccurrences(of: CSSColorMark.background, with: AppStyle.shared.theme.webBackgroundColorHex)
        cssText = cssText.replacingOccurrences(of: CSSColorMark.subtleBackground, with: AppStyle.shared.theme.webSubBackgroundColorHex)
        cssText = cssText.replacingOccurrences(of: CSSColorMark.topicContent, with: AppStyle.shared.theme.webTopicTextColorHex)
        cssText = cssText.replacingOccurrences(of: CSSColorMark.hyperlink, with: AppStyle.shared.theme.webLinkColorHex)
        cssText = cssText.replacingOccurrences(of: CSSColorMark.codePre, with: AppStyle.shared.theme.webCodePreColorHex)
        cssText = cssText.replacingOccurrences(of: CSSColorMark.separator, with: AppStyle.shared.theme.webLineColorHex)
    }
    
    func userTapAction(_ sender: Any) {
        if let user = topic?.owner {
            linkTap?(TapLink.user(info: user))
        }
    }
    
    func nodeTapAction(_ sender: Any) {
        if let node = topic?.node {
            linkTap?(TapLink.node(info: node))
        }
    }
}

extension TopicDetailsHeaderView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: {(result, _) in
            if let height = result as? CGFloat {
                let headHeight = self.titleView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
                var rect = self.frame
                rect.size.height = headHeight + height
                self.frame = rect
                self.heightUpdate.value = true
            }
        })
        
        let script = "var imgs = document.getElementsByTagName('img');" +
            "for (var i = 0; i < imgs.length; ++i) {" +
            "var img = imgs[i];" +
            "img.onclick = function () {" +
            "window.location.href = 'v2ex-image:' + this.src;" +
            "}" +
        "}"
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            let urlString = url.absoluteString
            if url.scheme == "v2ex-image" {
                let src = urlString.replacingOccurrences(of: "v2ex-image:", with: "")
                linkTap?(TapLink.image(src: src))
                decisionHandler(.cancel)
                return
            }else if urlString.hasPrefix("https://") || urlString.hasPrefix("http://") {
                if navigationAction.navigationType == .linkActivated {
                    if url.path.hasPrefix("/member/") {
                        let href = url.path
                        let name = href.replacingOccurrences(of: "/member/", with: "")
                        let user = User(name: name, href: href, src: "")
                        linkTap?(TapLink.user(info: user))
                    }else {
                        linkTap?(TapLink.web(url: url))
                    }
                    decisionHandler(.cancel)
                    return
                }
            }
        }
        decisionHandler(.allow)
    }
    
}

extension Reactive where Base: TopicDetailsHeaderView {
    var htmlString: UIBindingObserver<Base, String?> {
        return UIBindingObserver(UIElement: self.base) { view, text in
            view.htmlString = text
        }
    }
    
    var topic: UIBindingObserver<Base, Topic?> {
        return UIBindingObserver(UIElement: self.base) { view, model in
            view.topic = model
        }
    }
}
