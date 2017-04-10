//
//  TopicDetailsCommentCell.swift
//  V2EX
//
//  Created by wgh on 2017/3/7.
//  Copyright © 2017年 wgh. All rights reserved.
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
    
    var linkTap: ((TapLink) -> Void)?
    
    var comment: Comment? {
        didSet {
            configure()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = 4.0
        
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: -18, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        textView.linkTextAttributes = [NSForegroundColorAttributeName: #colorLiteral(red: 0.4666666667, green: 0.5019607843, blue: 0.5294117647, alpha: 1)]
        textView.delegate = self
        
        avatarView.isUserInteractionEnabled = true
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(userTapAction(_:)))
        avatarView.addGestureRecognizer(avatarTap)
        
        nameLabel.isUserInteractionEnabled = true
        let nameTap = UITapGestureRecognizer(target: self, action: #selector(userTapAction(_:)))
        nameLabel.addGestureRecognizer(nameTap)
        
        let cellTap = UITapGestureRecognizer(target: self, action: #selector(cellTapAction(_:)))
        addGestureRecognizer(cellTap)
    }
    
    func cellTapAction(_ sender: Any) {
        if let tableView = superview?.superview as? UITableView, let indexPath = tableView.indexPath(for: self) {
            tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
        }
    }
    
    func userTapAction(_ sender: Any) {
        if let user = comment?.user {
            linkTap?(TapLink.user(info: user))
        }
    }
    
    func configure() {
        guard let model = comment else {
            return
        }
        avatarView.kf.setImage(with: URL(string: model.user?.avatar(.large) ?? ""))
        nameLabel.text = model.user?.name
        floorLabel.text = "#" + model.number
        timeLabel.text = model.time
        
        var content = model.content
        
        guard let html = HTML(html: content, encoding: .utf8) else {
            textView.text = content
            return
        }

        var imgsrcs: [(id: String, src: String)] = []
        let srcs = html.xpath("//img").flatMap({$0["src"]})
        let imgTags = matchImgTags(text: content)
        imgTags.forEach({img in
            let id = "\(img.hashValue)"
            if let index = srcs.index(where: {img.contains($0)}) {
                content = content.replacingOccurrences(of: img, with: id)
                imgsrcs.append((id, srcs[index]))
            }
        })
        let htmlText = "<style>\(AppStyle.shared.css)</style>" + content
        if let htmlData = htmlText.data(using: .unicode) {
            do {
                let attributedString = try NSMutableAttributedString(data: htmlData, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
                imgsrcs.forEach({ item in
                    
                    let url = URL(string: item.src)!
                    var imgSize = CGSize(width: 100, height: 100)
                    var image: UIImage?
                    var isImageCached = false
                    if let cacheImage = ImageCache.default.retrieveImageInDiskCache(forKey: item.id) {
                        isImageCached = true
                        image = cacheImage
                        imgSize = cacheImage.size
                    }else {
                        image = UIImage(color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), size: imgSize)
                    }
                    
                    let attachment = ImageAttachment()
                    attachment.imageSize = imgSize
                    attachment.image = image
                    attachment.src = item.src
                    
                    let imgString = NSAttributedString(attachment: attachment)
                    if let range = attributedString.string.range(of: item.id) {
                        let nsRange = attributedString.string.nsRange(from: range)
                        attributedString.replaceCharacters(in: nsRange, with: imgString)
                        
                        if !isImageCached {
                            ImageDownloader.default.downloadImage(with: url, completionHandler: { (newImage, _, _, _) in
                                if let newImage = newImage {
                                    let smallImage = newImage.thumbnailForMaxPixelSize(200)
                                    attachment.imageSize = smallImage.size
                                    attachment.image = smallImage
                                    self.textView.textContainer.layoutManager?.invalidateLayout(forCharacterRange: nsRange, actualCharacterRange: nil)
                                    ImageCache.default.store(smallImage, forKey: item.id)
                                    SKCache.sharedCache.setImage(newImage, forKey: item.src)
                                }
                            })
                        }
                    }
                })
                textView.attributedText = attributedString
            } catch {
                textView.text = model.content
            }
        }else {
            textView.text = model.content
        }
    }
    
    func matchImgTags(text: String) -> [String] {
        let pattern = "<img src=(.*?)>"
        let regx = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators])
        guard let results = regx?.matches(in: text, options: .reportProgress, range: text.nsRange) else {
            return []
        }
        return results.flatMap({result -> String? in
            if let range = result.range.range(for: text) {
                return text.substring(with: range)
            }
            return nil
        })
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension TopicDetailsCommentCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let link = URL.absoluteString
        if link.hasPrefix("https://") || link.hasPrefix("http://"){
            linkTap?(TapLink.web(url: URL))
        }else if link.hasPrefix("applewebdata://") && link.contains("/member/") {
            let href = URL.path
            let name = href.replacingOccurrences(of: "/member/", with: "")
            let user = User(name: name, href: href, src: "")
            linkTap?(TapLink.user(info: user))
        }
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
