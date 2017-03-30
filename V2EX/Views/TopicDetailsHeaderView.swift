//
//  TopicDetailsHeaderView.swift
//  V2EX
//
//  Created by wgh on 2017/3/9.
//  Copyright © 2017年 wgh. All rights reserved.
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
    @IBOutlet weak var contentView: UIView!
    lazy var webView: WKWebView = WKWebView()
    
    var linkTap: ((URL) -> Void)?
    var heightUpdate = Variable<Bool>(false)
    
    var topic: Topic? {
        willSet {
            if let model = newValue {
                avatarView.kf.setImage(with: URL(string: model.owner?.avatar(.large) ?? ""))
                nameLabel.text = model.owner?.name
                timeLabel.text = model.creatTime.components(separatedBy: ",").first
                titleLabel.text = model.title
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
                    let head = "<head><meta name=\"viewport\" content=\"width=device-width, user-scalable=no\"><style>\(AppStyle.shared.css)</style></head>"
                    let body = "<body><div id=\"Wrapper\">\(content)</div></body>"
                    let html = "<html>\(head)\(body)</html>"
                    webView.loadHTMLString(html, baseURL: URL(string: "https://www.v2ex.com"))
                }
            }
        }
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = 4.0
        webView.scrollView.delaysContentTouches = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = self
        contentView.addSubview(webView)

        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
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
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let object = object as? WKWebView, keyPath == "estimatedProgress" {
            if let newValue = change?[.newKey] as? Double, newValue == 1.0 {
                object.evaluateJavaScript("document.body.scrollHeight", completionHandler: {(result, _) in
                    if let height = result as? CGFloat {
                        
                        let headHeight = self.titleView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
                        var rect = self.frame
                        rect.size.height = headHeight + height
                        self.frame = rect
                        self.heightUpdate.value = true
                    }
                })
            }
        }
    }
}

extension TopicDetailsHeaderView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if url.absoluteString.hasPrefix("https://") || url.absoluteString.hasPrefix("http://") {
                if navigationAction.navigationType == .linkActivated {
                    linkTap?(url)
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
