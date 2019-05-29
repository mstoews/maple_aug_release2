//
//  CommentCell.swift
//  InstagramFirebase
//
//  Created by Murray Toews on 6/3/17.
//  Copyright © 2017 maple.com

import UIKit
import MaterialComponents

class CommentCell: MDCCardCollectionCell , UIGestureRecognizerDelegate{
    
    var comment: Comment? {
        didSet {
            guard let comment = comment else { return }
            let attrText = NSMutableAttributedString(string: comment.user.username , attributes: attributes)
            attrText.append(NSAttributedString(string: " " + comment.text , attributes: captionAttr))
            attrText.addAttribute(.paragraphStyle, value: CommentCell.paragraphStyle, range: NSMakeRange(0, attrText.length))
            let timeAgoDisplay = comment.creationDate.timeAgoToDisplay()
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

    var pan: UIPanGestureRecognizer!
    var deleteLabel1: UILabel!
    var deleteLabel2: UILabel!
    
    
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

    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return abs((pan.velocity(in: pan.view)).x) > abs((pan.velocity(in: pan.view)).y)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        addSubview(textView)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        textView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 5, width: 0, height: 0)
        backgroundColor = .white
        
        deleteLabel1 = UILabel()
        deleteLabel1.text = "Delete"
        deleteLabel1.adjustsFontSizeToFitWidth = true
        deleteLabel1.textColor = UIColor.white
        deleteLabel1.backgroundColor = UIColor.themeColor()
        self.insertSubview(deleteLabel1, belowSubview: self.contentView)
        
        deleteLabel2 = UILabel()
        deleteLabel2.text = "Delete"
        deleteLabel2.textColor = UIColor.white
        deleteLabel2.backgroundColor = UIColor.themeColor()
        self.insertSubview(deleteLabel2, belowSubview: self.contentView)
        
        pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        pan.delegate = self
        self.addGestureRecognizer(pan)
    }
    
    let attributes = [NSAttributedString.Key.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .body2)]
    let captionAttr = [NSAttributedString.Key.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .caption)]
    
    func populateContent(username: String, profileImageUrl: String, text: String, date: Date, index: Int, isDryRun: Bool)
    {
        let attrText = NSMutableAttributedString(string: username , attributes: attributes)
        attrText.append(NSAttributedString(string: " " + text , attributes: captionAttr))
        attrText.addAttribute(.paragraphStyle, value: CommentCell.paragraphStyle, range: NSMakeRange(0, attrText.length))
        attrText.append(NSAttributedString(string: "\n" + date.timeAgoToDisplay() , attributes: captionAttr))
        
        if !isDryRun {
            profileImageView.accessibilityLabel = username
            profileImageView.accessibilityHint = "Double-tap to open profile."
            profileImageView.loadImage(urlString: profileImageUrl)
            profileImageView.tag = 1
            textView.tag = 1
            profileImageView.loadImage(urlString: profileImageUrl)
        }
        textView.accessibilityLabel = "\(username) said, \(text)"
        textView.attributedText = attrText
        print(textView.text!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if (pan.state == UIGestureRecognizer.State.changed) {
            let p: CGPoint = pan.translation(in: self)
            let width = self.contentView.frame.width
            let height = self.contentView.frame.height
            self.contentView.frame = CGRect(x: p.x,y: 0, width: width, height: height);
           //self.deleteLabel1.frame = CGRect(x: p.x - deleteLabel1.frame.size.width-10, y: 0, width: 100, height: height)
            self.deleteLabel2.frame = CGRect(x: p.x + width + deleteLabel2.frame.size.width, y: 0, width: 100, height: height)
        }
        
    }
    
    @objc func onPan(_ pan: UIPanGestureRecognizer) {
        if pan.state == UIGestureRecognizer.State.began {
            
        } else if pan.state == UIGestureRecognizer.State.changed {
            self.setNeedsLayout()
        } else {
            if abs(pan.velocity(in: self).x) > 500 {
                let collectionView: UICollectionView = self.superview as! UICollectionView
                let indexPath: IndexPath = collectionView.indexPathForItem(at: self.center)!
                collectionView.delegate?.collectionView!(collectionView, performAction: #selector(onPan(_:)), forItemAt: indexPath, withSender: nil)
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                })
            }
        }
    }
}


extension CommentCell {
    static let paragraphStyle = { () -> NSMutableParagraphStyle in
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 2
        return style
    }()
    
   
    
}


