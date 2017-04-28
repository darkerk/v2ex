//
//  AppStyle.swift
//  V2EX
//
//  Created by darker on 2017/3/9.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit
import RxSwift

let nightOnKey = "theme.night.on"

struct CSSColorMark {
    static let background = "#background#"
    static let subtleBackground = "#subtle#"
    static let topicContent = "#topic_content#"
    static let replyContent = "#reply_content#"
    static let hyperlink = "#hyperlink#"
    static let codePre = "#codePre#"
    static let separator = "#separator#"
}

struct AppStyle {
    static var shared = AppStyle()
    
    let themeUpdateVariable = Variable<Bool>(false)
    
    var css: String = ""
    var theme: Theme = UserDefaults.standard.bool(forKey: nightOnKey) ? .night : .normal {
        didSet {
            UserDefaults.standard.set(theme == .night, forKey: nightOnKey)
            self.themeUpdateVariable.value = true
        }
    }
    
    private init() {
        if let stylePath = Bundle.main.path(forResource: "style", ofType: "css"), let mobilePath = Bundle.main.path(forResource: "mobile", ofType: "css") {
            do {
                let css1 = try String(contentsOfFile: mobilePath, encoding: .utf8)
                let css2 = try String(contentsOfFile: stylePath, encoding: .utf8)
                self.css = css1 + css2
            } catch  {
                
            }
        }
    }
    
    func setupBarStyle(_ navigationBar: UINavigationBar = UINavigationBar.appearance()) {
        navigationBar.isTranslucent = false
        navigationBar.tintColor = theme.tintColor
        navigationBar.barTintColor = theme.barTintColor
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: theme.navigationBarTitleColor, NSFontAttributeName: UIFont.systemFont(ofSize: 17)]
        navigationBar.backIndicatorImage = #imageLiteral(resourceName: "nav_back")
        navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "nav_back")
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 16)], for: .normal)
    }
}
