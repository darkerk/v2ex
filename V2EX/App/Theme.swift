//
//  Theme.swift
//  V2EX
//
//  Created by wgh on 2017/4/26.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit

enum Theme {
    case normal
    case night
}

extension Theme {
    var activityIndicatorStyle: UIActivityIndicatorViewStyle {
        switch self {
        case .normal:
            return .gray
        case .night:
            return .white
        }
    }
    
    var tableBackgroundColor: UIColor {
        switch self {
        case .normal:
            return UIColor.white
        case .night:
            return #colorLiteral(red: 0.07843137255, green: 0.1137254902, blue: 0.1490196078, alpha: 1)
        }
    }
    
    var tableGroupBackgroundColor: UIColor {
        switch self {
        case .normal:
            return #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1)
        case .night:
            return #colorLiteral(red: 0.07843137255, green: 0.1137254902, blue: 0.1490196078, alpha: 1)
        }
    }
    
    var tableHeaderBackgroundColor: UIColor {
        switch self {
        case .normal:
            return UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.00)
        case .night:
            return #colorLiteral(red: 0.07843137255, green: 0.1137254902, blue: 0.1490196078, alpha: 1)
        }
    }
    
    var cellBackgroundColor: UIColor {
        switch self {
        case .normal:
            return UIColor.white
        case .night:
            return #colorLiteral(red: 0.1019607843, green: 0.1568627451, blue: 0.2117647059, alpha: 1)
        }
    }
    
    var cellSubBackgroundColor: UIColor {
        switch self {
        case .normal:
            return #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        case .night:
            return #colorLiteral(red: 0.1411764706, green: 0.2039215686, blue: 0.2784313725, alpha: 1)
        }
    }
    
    var cellSelectedBackgroundColor: UIColor {
        switch self {
        case .normal:
            return UIColor(colorLiteralRed: 0.901961, green: 0.901961, blue: 0.901961, alpha: 1)
        case .night:
            return #colorLiteral(red: 0.1411764706, green: 0.2039215686, blue: 0.2784313725, alpha: 1)
        }
    }
    
    var separatorColor: UIColor {
        switch self {
        case .normal:
            return UIColor(colorLiteralRed: 0.901961, green: 0.901961, blue: 0.901961, alpha: 1)
        case .night:
            return UIColor.black
        }
    }
    
    var hyperlinkColor: UIColor {
        switch self {
        case .normal:
            return #colorLiteral(red: 0.4666666667, green: 0.5019607843, blue: 0.5294117647, alpha: 1)
        case .night:
            return #colorLiteral(red: 0.1137254902, green: 0.631372549, blue: 0.9490196078, alpha: 1)
        }
    }
    
    /// webView
    var webBackgroundColorHex: String {
        switch self {
        case .normal:
            return "#ffffff"
        case .night:
            return "#1A2836"
        }
    }
    
    var webSubBackgroundColorHex: String {
        switch self {
        case .normal:
            return "#fffff9"
        case .night:
            return "#243447"
        }
    }
    
    var webCodePreColorHex: String {
        switch self {
        case .normal:
            return "#f8f8f8"
        case .night:
            return "#243447"
        }
    }
    
    var webTopicTextColorHex: String {
        switch self {
        case .normal:
            return "#646464"
        case .night:
            return "#9BAFCC"
        }
    }
    
    var webLinkColorHex: String {
        switch self {
        case .normal:
            return "#778087"
        case .night:
            return "#1DA1F2"
        }
    }
    
    var webLineColorHex: String {
        switch self {
        case .normal:
            return "#e2e2e2"
        case .night:
            return "#243447"
        }
    }

    /// 白天模式RGB(64, 64, 64)
    var black64Color: UIColor {
        switch self {
        case .normal:
            return #colorLiteral(red: 0.2509803922, green: 0.2509803922, blue: 0.2509803922, alpha: 1)
        case .night:
            return #colorLiteral(red: 0.6078431373, green: 0.6862745098, blue: 0.8, alpha: 1)
        }
    }
    
    /// 白天模式RGB(102, 102, 102)
    var black102Color: UIColor {
        switch self {
        case .normal:
            return #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        case .night:
            return #colorLiteral(red: 0.6078431373, green: 0.6862745098, blue: 0.8, alpha: 1)
        }
    }
    
    /// 白天模式RGB(153, 153, 153)
    var black153Color: UIColor {
        switch self {
        case .normal:
            return #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        case .night:
            return #colorLiteral(red: 0.4588235294, green: 0.5137254902, blue: 0.6, alpha: 1)
        }
    }
    
    /// navigationBar
    var tintColor: UIColor {
        switch self {
        case .normal:
            return #colorLiteral(red: 0.2509803922, green: 0.2509803922, blue: 0.2509803922, alpha: 1)
        case .night:
            return #colorLiteral(red: 0.1137254902, green: 0.631372549, blue: 0.9490196078, alpha: 1)
        }
    }
    
    var barTintColor: UIColor {
        switch self {
        case .normal:
            return UIColor.white
        case .night:
            return #colorLiteral(red: 0.1411764706, green: 0.2039215686, blue: 0.2784313725, alpha: 1)
        }
    }
    
    var navigationBarTitleColor: UIColor {
        switch self {
        case .normal:
            return #colorLiteral(red: 0.2509803922, green: 0.2509803922, blue: 0.2509803922, alpha: 1)
        case .night:
            return #colorLiteral(red: 0.6078431373, green: 0.6862745098, blue: 0.8, alpha: 1)
        }
    }
    
    /// 话题列表
    var topicCellNodeBackgroundColor: UIColor {
        switch self {
        case .normal:
            return #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        case .night:
            return #colorLiteral(red: 0.1411764706, green: 0.2039215686, blue: 0.2784313725, alpha: 1)
        }
    }
    
    var topicReplyCountBackgroundColor: UIColor {
        switch self {
        case .normal:
            return #colorLiteral(red: 0.6666666667, green: 0.6901960784, blue: 0.7764705882, alpha: 1)
        case .night:
            return #colorLiteral(red: 0.1411764706, green: 0.2039215686, blue: 0.2784313725, alpha: 1)
        }
    }
    
    var topicReplyCountTextColor: UIColor {
        switch self {
        case .normal:
            return UIColor.white
        case .night:
            return #colorLiteral(red: 0.6078431373, green: 0.6862745098, blue: 0.8, alpha: 1)
        }
    }
}
