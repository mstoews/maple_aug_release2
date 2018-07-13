//
//  CommentCell.swift
//  InstagramFirebase
//
//  Created by Murray Toews on 6/3/17.
//  Copyright © 2017 maple.com

import UIKit
import MaterialComponents

class CommentCell: MDCCardCollectionCell {
    
    var comment: Comment? {
        didSet {
            guard let comment = comment else { return }
            let attrText = NSMutableAttributedString(string: comment.user.username , attributes: attributes)
            attrText.append(NSAttributedString(string: " " + comment.text , attributes: captionAttr))
            attrText.addAttribute(.paragraphStyle, value: CommentCell.paragraphStyle, range: NSMakeRange(0, attrText.length))
            let timeAgoDisplay = comment.creationDate.timeAgoDisplay()
            attrText.append(NSAttributedString(string: "\n" + timeAgoDisplay, attributes: captionAttr))
            textView.attributedText = attrText
            textView.accessibilityLabel = "\(comment.user.username) said, \(comment.text)"
            profileImageView.accessibilityLabel = comment.user.username
            profileImageView.accessibilityHint = "Double-tap to open profile."
            profileImageView.loadImage(urlString: comment.user.profileImageUrl)
            profileImageView.tag = 1
            textView.tag = 1
            profileImageView.loadImage(urlString: comment.user.profileImageUrl)
        }
    }
    
    let textView: UILabel = {
        let textView = UILabel()
        textView.numberOfLines = 0
        return textView
    }()
    
    let timeView: UILabel = {
        let textView = UILabel()
        //textView.font = UIFont.systemFont(ofSize: 10)
        return textView
    }()

    
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .blue
        return iv
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        addSubview(textView)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        textView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 5, width: 0, height: 0)
        backgroundColor = .white
    }
    
    let attributes = [NSAttributedStringKey.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .body2)]
    let captionAttr = [NSAttributedStringKey.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .caption)]
    
    func populateContent(from: MapleUser, text: String, date: Date, index: Int, isDryRun: Bool)
    {
        let attrText = NSMutableAttributedString(string: from.username , attributes: attributes)
        attrText.append(NSAttributedString(string: " " + text , attributes: captionAttr))
        attrText.addAttribute(.paragraphStyle, value: CommentCell.paragraphStyle, range: NSMakeRange(0, attrText.length))
        attrText.append(NSAttributedString(string: "\n" + date.timeAgoDisplay() , attributes: captionAttr))
        
        if !isDryRun {
            profileImageView.accessibilityLabel = from.username
            profileImageView.accessibilityHint = "Double-tap to open profile."
            profileImageView.loadImage(urlString: from.profileImageUrl)
            profileImageView.tag = 1
            textView.tag = 1
            profileImageView.loadImage(urlString: from.profileImageUrl)
        }
        textView.accessibilityLabel = "\(from.username) said, \(text)"
        textView.attributedText = attrText
        print(textView.text!)
    }
}

extension CommentCell {
    static let paragraphStyle = { () -> NSMutableParagraphStyle in
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 2
        return style
    }()
    
   
    
}


