//
//  TopicDetailsCommentCell.swift
//  V2EX
//
//  Created by darker on 2017/3/7.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit
import Kingfisher
import Kanna
import SKPhotoBrowser

class ImageAttachment: NSTextAttachment {
    var src: String?
    var imageSize = CGSize(width: 100, height: 100)
    let maxHeight: CGFloat = 100.0
    
    override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        
        if imageSize.height > maxHeight {
            let factor = maxHeight / imageSize.height
            return CGRect(origin: CGPoint.zero, size:CGSize(width: imageSize.width * factor, height: maxHeight))
        }else {
            return CGRect(origin: CGPoint.zero, size:imageSize)
        }
    }
}

class TopicDetailsCommentCell: UITableViewCell {
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var floorLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var lzFlagLabel: UILabel!
    
    var linkTap: ((TapLink) -> Void)?
    
    var comment: Comment? {
        didSet {
            configure()
        }
    }
    
    var isLZ: Bool = false {
        willSet {
            lzFlagLabel.isHidden = !newValue
        }
    }
    
    private var cssText = "a:link, a:visited, a:active {" +
        "text-decoration: none;" +
        "word-break: break-all;" +
        "}" +
        ".reply_content {" +
        "font-size: 14px;" +
        "line-height: 1.6;" +
        "color: #reply_content#;" +
        "word-break: break-all;" +
        "word-wrap: break-word;" +
    "}"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = 4.0
        
        if #available(iOS 11.0, *) {
            textView.textDragInteraction?.isEnabled = false
        } else {
            // Fallback on earlier versions
        };
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: -18, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        textView.linkTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.foregroundColor.rawValue: AppStyle.shared.theme.hyperlinkColor])
        textView.delegate = self
        
        avatarView.isUserInteractionEnabled = true
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(userTapAction(_:)))
        avatarView.addGestureRecognizer(avatarTap)
        
        nameLabel.isUserInteractionEnabled = true
        let nameTap = UITapGestureRecognizer(target: self, action: #selector(userTapAction(_:)))
        nameLabel.addGestureRecognizer(nameTap)
        
        let cellTap = UITapGestureRecognizer(target: self, action: #selector(cellTapAction(_:)))
        textView.addGestureRecognizer(cellTap)
        
        let selectedView = UIView()
        selectedView.backgroundColor = AppStyle.shared.theme.cellSelectedBackgroundColor
        self.selectedBackgroundView = selectedView
        
        backgroundColor = AppStyle.shared.theme.cellBackgroundColor
        contentView.backgroundColor = backgroundColor
        textView.backgroundColor = backgroundColor
        nameLabel.textColor = AppStyle.shared.theme.black64Color
        timeLabel.textColor = AppStyle.shared.theme.black153Color
        floorLabel.textColor = AppStyle.shared.theme.black153Color
        lzFlagLabel.textColor = AppStyle.shared.theme.black153Color
        cssText = cssText.replacingOccurrences(of: CSSColorMark.replyContent, with: AppStyle.shared.theme.webTopicTextColorHex)
    }
    
    @objc func cellTapAction(_ sender: UITapGestureRecognizer) {
        var view = superview
        while (view != nil && view?.isKind(of: UITableView.self) == false) {
            view = view?.superview
        }
        guard let tableView = view as? UITableView, let indexPath = tableView.indexPath(for: self) else {
            return
        }
        
        let tapLocation = sender.location(in: textView)
        guard let textPosition = textView.closestPosition(to: tapLocation),
            let attributes = convertFromOptionalNSAttributedStringKeyDictionary(textView.textStyling(at: textPosition, in: UITextStorageDirection.forward)) else {
                
                tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
                
                return
        }

        if let url = attributes[NSAttributedString.Key.link.rawValue] as? URL {
            
            handleTextViewLink(url: url)
            
        }else if let attachment = attributes[NSAttributedString.Key.attachment.rawValue] as? ImageAttachment {
            if let src = attachment.src, attachment.imageSize.width > 50 {
                linkTap?(TapLink.image(src: src))
            }
        }else {
            tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
        }
    }
    
    @objc func userTapAction(_ sender: Any) {
        if let user = comment?.user {
            linkTap?(TapLink.user(info: user))
        }
    }
    
    func configure() {
        guard let model = comment else {
            return
        }
        avatarView.kf.setImage(with: URL(string: model.user?.avatar(.large) ?? ""), placeholder: #imageLiteral(resourceName: "avatar_default"))
        nameLabel.text = model.user?.name
        floorLabel.text = "#" + model.number
        timeLabel.text = model.time
        
        var content = model.content
        do {
            let html = try HTML(html: content, encoding: .utf8)
            var imgsrcs: [(id: String, src: String)] = []
            let srcs = html.xpath("//img").compactMap({$0["src"]})
            let imgTags = matchImgTags(text: content)
            imgTags.forEach({img in
                let id = "\(img.hashValue)"
                if let index = srcs.firstIndex(where: {img.contains($0)}) {
                    content = content.replacingOccurrences(of: img, with: id)
                    var src = srcs[index]
                    if src.hasPrefix("//") {
                        src = "http:" + src
                    }
                    imgsrcs.append((id, src))
                }
            })
            
            let htmlText = "<style>\(cssText)</style>" + content
            
            guard let htmlData = htmlText.data(using: .unicode),
                let attributedString = try? NSMutableAttributedString(data: htmlData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) else {
                    
                    return
            }
            
            imgsrcs.forEach({ item in
                let url = URL(string: item.src)!
                var imgSize = CGSize(width: 100, height: 100)
                var image: UIImage?
                var isImageCached = false
                ImageCache.default.retrieveImage(forKey: item.id, completionHandler: { result in
                    switch result {
                    case .success(let value):
                        if let cacheImage = value.image {
                            isImageCached = true
                            image = cacheImage
                            imgSize = cacheImage.size
                        }else {
                            image = UIImage(color: AppStyle.shared.theme.topicCellNodeBackgroundColor, size: imgSize)
                        }
                    case .failure(let error):
                        print("retrieveImage: \(error.localizedDescription)")
                    }
                })
                
                let attachment = ImageAttachment()
                attachment.imageSize = imgSize
                attachment.image = image
                attachment.src = item.src
                
                let imgString = NSAttributedString(attachment: attachment)
                if let range = attributedString.string.range(of: item.id) {
                    let nsRange = attributedString.string.nsRange(from: range)
                    attributedString.replaceCharacters(in: nsRange, with: imgString)
                }
                
                if !isImageCached {
                    ImageDownloader.default.downloadImage(with: url, completionHandler: { result in
                        switch result {
                        case .success(let value):
                            let smallImage = value.image.thumbnailForMaxPixelSize(200)
                            attachment.image = smallImage
                            if smallImage.size != attachment.imageSize {
                                attachment.imageSize = smallImage.size
                                self.textView.textContainer.layoutManager?.setNeedsLayout(forAttachment: attachment)
                            }else {
                                self.textView.textContainer.layoutManager?.setNeedsDisplay(forAttachment: attachment)
                            }
                            ImageCache.default.store(smallImage, forKey: item.id)
                            SKCache.sharedCache.setImage(value.image, forKey: item.src)
                        case .failure(let error):
                            print("downloadImage: \(error.localizedDescription)")
                        }
                    })
                }
            })
            textView.attributedText = attributedString
        } catch {
            textView.text = content
            return
        }
    }
    
    func matchImgTags(text: String) -> [String] {
        let pattern = "<img src=(.*?)>"
        let regx = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators])
        guard let results = regx?.matches(in: text, options: .reportProgress, range: text.nsRange) else {
            return []
        }
        return results.compactMap({result -> String? in
            if let range = result.range.range(for: text) {
                return String(text[range])
            }
            return nil
        })
    }
    
    func handleTextViewLink(url: URL) {
        let link = url.absoluteString
        if link.hasPrefix("https://") || link.hasPrefix("http://"){
            linkTap?(TapLink.web(url: url))
        }else if link.hasPrefix("applewebdata://") && link.contains("/member/") {
            let href = url.path
            let name = href.replacingOccurrences(of: "/member/", with: "")
            let user = User(name: name, href: href, src: "")
            linkTap?(TapLink.user(info: user))
        }else if link.hasPrefix("applewebdata://") && link.contains("/t/") {
            let href = url.path
            let topic = Topic(href: href)
            linkTap?(TapLink.topic(info: topic))
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension TopicDetailsCommentCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        handleTextViewLink(url: URL)
        return false
    }
    
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if textAttachment is ImageAttachment {
            let attachment = textAttachment as! ImageAttachment
            if let src = attachment.src, attachment.imageSize.width > 50 {
                linkTap?(TapLink.image(src: src))
            }
            return false
        }
        return true
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromOptionalNSAttributedStringKeyDictionary(_ input: [NSAttributedString.Key: Any]?) -> [String: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
