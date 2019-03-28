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
            themeUpdateVariable.value = true
        }
    }
    
    private init() {
        if let stylePath = Bundle.main.path(forResource: "style", ofType: "css") {
            do {
                self.css  = try String(contentsOfFile: stylePath, encoding: .utf8)
            } catch  {
                
            }
        }
    }
    
    func setupBarStyle(_ navigationBar: UINavigationBar = UINavigationBar.appearance()) {
        navigationBar.isTranslucent = false
        navigationBar.tintColor = theme.tintColor
        navigationBar.barTintColor = theme.barTintColor
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: theme.navigationBarTitleColor, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)]
        navigationBar.backIndicatorImage = #imageLiteral(resourceName: "nav_back")
        navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "nav_back")
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], for: .normal)
    }
}
