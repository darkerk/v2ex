//
//  AppStyle.swift
//  V2EX
//
//  Created by wgh on 2017/3/9.
//  Copyright © 2017年 wgh. All rights reserved.
//

import UIKit

struct AppStyle {
    static let shared = AppStyle()
    
    var css: String = ""
    
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
    
    func setupBarStyle() {
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: #colorLiteral(red: 0.1568627451, green: 0.1568627451, blue: 0.1568627451, alpha: 1), NSFontAttributeName: UIFont.systemFont(ofSize: 17)]
        UINavigationBar.appearance().backIndicatorImage = #imageLiteral(resourceName: "nav_back")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "nav_back")
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 16), NSForegroundColorAttributeName: #colorLiteral(red: 0.2509803922, green: 0.2509803922, blue: 0.2509803922, alpha: 1)], for: .normal)
    }
}
