//
//  AboutLicensesViewController.swift
//  V2EX
//
//  Created by wgh on 2017/3/22.
//  Copyright © 2017年 wgh. All rights reserved.
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
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        if let fileURL = Bundle.main.url(forResource: viewType == .about ? "ABOUT" : "LICENSES", withExtension: "html") {
            webView.loadFileURL(fileURL, allowingReadAccessTo: Bundle.main.bundleURL)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
