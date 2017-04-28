//
//  AboutLicensesViewController.swift
//  V2EX
//
//  Created by darker on 2017/3/22.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class AboutLicensesViewController: UIViewController {
    enum ViewType {
        case about, licenses
    }
    
    var viewType: ViewType = .about
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationItem.title = viewType == .about ? "关于V2EX" : "LICENSES"
        view.backgroundColor = AppStyle.shared.theme.cellBackgroundColor
        
        let webView = WKWebView()
        webView.backgroundColor = AppStyle.shared.theme.cellBackgroundColor
        webView.scrollView.backgroundColor = AppStyle.shared.theme.cellBackgroundColor
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        if let path = Bundle.main.path(forResource: viewType == .about ? "ABOUT" : "LICENSES", ofType: "html") {
            do {
                let body = try String(contentsOfFile: path, encoding: .utf8)
                let head = "<head><meta name=\"viewport\" content=\"width=device-width, user-scalable=no\"><style>\(cssText)</style></head>"
                let html = "<html>\(head)\(body)</html>"
                webView.loadHTMLString(html, baseURL: nil)
            } catch  {
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var cssText: String {
        return "body {" +
            "background-color: \(AppStyle.shared.theme.webBackgroundColorHex);" +
            "font-size: 15px;" +
            "color: \(AppStyle.shared.theme.webTopicTextColorHex); }" +
            "h1 {" +
            "font-size: 18px;" +
            "font-weight: 500;" +
            "line-height: 100%;" +
            "margin: 5px 0px 20px 0px;" +
            "padding: 0px;" +
            "word-wrap: break-word; }" +
            "a {" +
            "color: \(AppStyle.shared.theme.webLinkColorHex);" +
            "text-decoration: none;" +
            "word-break: break-all; }" +
            "hr {" +
            "border: none;" +
            "height: 1px;" +
            "background-color: \(AppStyle.shared.theme.webLineColorHex);" +
            "margin-bottom: 1em; }"
    }
}

extension AboutLicensesViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if url.absoluteString.hasPrefix("https://") {
                let safari = SFSafariViewController(url: url)
                present(safari, animated: true, completion: nil)
                decisionHandler(.cancel)
            }else {
                decisionHandler(.allow)
            }
        }else {
            decisionHandler(.cancel)
        }
    }
}
