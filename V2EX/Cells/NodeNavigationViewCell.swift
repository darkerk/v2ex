//
//  NodeNavigationViewCell.swift
//  V2EX
//
//  Created by darker on 2017/4/6.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit

class NodeNavigationViewCell: UITableViewCell {
    
    @IBOutlet weak var textView: UITextView!
    var linkTap: ((TapLink) -> Void)?
    
    private let css = "a:link, a:visited, a:active { " +
        "line-height: 1.6;" +
        "text-decoration: none; " +
        "word-break: break-all; " +
    "}"
    
    var content: String? {
        willSet {
            if let content = newValue?.trimmingCharacters(in: .whitespacesAndNewlines) {
                let text = content.replacingOccurrences(of: "14px", with: "16px")
                let htmlText = "<style>\(css)</style>" + text
                if let htmlData = htmlText.data(using: .unicode) {
                    do {
                        let attributedString = try NSMutableAttributedString(data: htmlData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
                        textView.attributedText = attributedString
                    } catch {
                        textView.text = content
                    }
                }else {
                    textView.text = content
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textView.linkTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.foregroundColor.rawValue: #colorLiteral(red: 0.4666666667, green: 0.5019607843, blue: 0.5294117647, alpha: 1)])
        textView.delegate = self
        
        if AppStyle.shared.theme == .night {
            textView.linkTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.foregroundColor.rawValue: #colorLiteral(red: 0.6078431373, green: 0.6862745098, blue: 0.8, alpha: 1)])
        }
        backgroundColor = AppStyle.shared.theme.cellBackgroundColor
        contentView.backgroundColor = backgroundColor
        textView.backgroundColor = backgroundColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension NodeNavigationViewCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {

        if URL.absoluteString.hasPrefix("applewebdata://") {
            let href = URL.path
            var name = URL.lastPathComponent
            let text = textView.attributedText.string
            if let range = characterRange.range(for: text) {
                name = String(text[range])
            }
            let node = Node(name: name, href: href)
            linkTap?(TapLink.node(info: node))
        }
        return false
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
