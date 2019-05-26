//
//  NotificationPostCell.swift
//  maple
//
//  Created by Murray Toews on 2017-07-25.
//  Copyright © 2017 mapleon. All rights reserved.
//

import Foundation
import Firebase 

import UIKit
import MaterialComponents.MaterialCollectionCells


protocol NotificationDelegate {
   
    func didSave(for cell: NotificationPostCell)
    func didClear(for cell: NotificationPostCell)
}


class NotificationPostCell: MDCCardCollectionCell , UIGestureRecognizerDelegate{
    
    var notification: NotificationFireObject? {
        didSet {
            self.usernameLabel.text = notification?.interactionUserUsername
            let profileImageUrl = notification?.interactionUserProfilePicture
            self.profileImageView.loadImage(urlString: profileImageUrl!)
            self.contentLabel.text = self.notification?.kind
            let date: Date = (self.notification?.timestamp.dateValue())!
            self.timeLabel.text = date.timeAgoToDisplay()
        }
    }
    
    var delegate: NotificationDelegate?
    
    //var pan: UIPanGestureRecognizer!
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
//    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        return abs((pan.velocity(in: pan.view)).x) > abs((pan.velocity(in: pan.view)).y)
//    }
//
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 40/8
        iv.clipsToBounds = true
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        //label.backgroundColor = UIColor.veryLightGray()
        return label
    }()
    
    let contentLabel: UILabel = {
        let label = UILabel()
        label.text = "Content"
        label.textColor = .darkGray
        label.lineBreakMode = .byWordWrapping // notice the 'b' instead of 'B'
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    

    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "Date"
        label.font = UIFont.systemFont(ofSize: 8)
        label.textColor = .lightGray
        return label
    }()
    
    let saveButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_save").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()
    
    lazy var clearButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_delete").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleClear), for: .touchUpInside)
        return button
    }()
    
    @objc func handleSave (){
        delegate?.didSave(for: self)
    }
    
    @objc func handleClear()
    {
        delegate?.didClear(for: self)
    }
    
    let attributes = [NSAttributedStringKey.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .body2)]
    let captionAttr = [NSAttributedStringKey.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .caption)]
    
    func populateContent(from: MapleUser, text: String, date: Date, index: Int, isDryRun: Bool)
    {
        //let dateCreated = Date(timeIntervalSince1970: date)
        
        var msg : String?
        
        if text == "comment" {
            msg = from.username + " commented on your post."
        }
        else
        {
            msg = text
        }
        
        if let msg = msg {
            let commentText =  NSMutableAttributedString(string: msg , attributes: attributes)
            commentText.addAttribute(.paragraphStyle, value: NotificationPostCell.paragraphStyle, range: NSMakeRange(0, commentText.length))
            //commentText.append(NSAttributedString(string: "\n" + date , attributes: captionAttr))
            
            contentLabel.attributedText = commentText
            timeLabel.text = date.description
            
            
            if !isDryRun {
                profileImageView.accessibilityLabel = from.username
                profileImageView.accessibilityHint = "Double-tap to open profile."
                profileImageView.loadImage(urlString: from.profileImageUrl)
                profileImageView.tag = 1
                contentLabel.tag = 1
                profileImageView.loadImage(urlString: from.profileImageUrl)
            }
            
        }
    }
    

    func populateCell(from: NotificationFireObject, isDryRun: Bool)
    {
        var NotificationText : String!
         switch from.kind {
            case "comment":
                print ("Comment Event")
                NotificationText = from.interactionUserUsername + " commented on your post." + "\n" + from.interactionRef
                break
            case "like" :
                print ("Like Event")
                NotificationText = from.interactionUserUsername + " liked your post." + "\n" + from.interactionRef
                break
            case "follow" :
                print ("follow Event")
                NotificationText = from.interactionUserUsername + " is now following you." + "\n" + from.interactionRef
                break
            default:
                print("unknown event " + from.kind)
         }
        
        let dateCreated = from.timestamp.dateValue()
        
        let commentText =  NSMutableAttributedString(string: NotificationText, attributes: attributes)
        commentText.addAttribute(.paragraphStyle, value: NotificationPostCell.paragraphStyle, range: NSMakeRange(0, commentText.length))
        
        contentLabel.attributedText = commentText
        timeLabel.text = dateCreated.timeAgoToDisplay()
        
        
        if !isDryRun {
            profileImageView.accessibilityLabel = from.interactionUserUsername
            profileImageView.accessibilityHint = "Double-tap to open profile."
            profileImageView.loadImage(urlString: from.interactionUserProfilePicture)
            profileImageView.tag = 1
            contentLabel.tag = 1
            profileImageView.loadImage(urlString: from.interactionUserProfilePicture)
        }
        
    }
    
    var deleteLabel1 : UILabel!
    
//    fileprivate func panGesture() {
//        self.insertSubview(clearButton, belowSubview: self.contentView)
//        pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
//        pan.delegate = self
//        self.addGestureRecognizer(pan)
//    }
//    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(profileImageView)
        //self.contentView.addSubview(usernameLabel)
        self.contentView.addSubview(contentLabel)
        self.contentView.addSubview(timeLabel)
        //self.contentView.addSubview(clearButton)
        self.contentView.addSubview(saveButton)
        
        
        
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        
        contentLabel.anchor(top: contentView.topAnchor, left: profileImageView.rightAnchor, bottom: nil,
                            right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 8,
                            paddingBottom: 5, paddingRight: 10, width: 0, height: 45)
        
        
        
        timeLabel.anchor(top: contentLabel.bottomAnchor, left:  profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8,
                         paddingBottom: 0, paddingRight: 0, width: 0, height: 10)
        
        
        //panGesture()

    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        if (pan.state == UIGestureRecognizerState.changed) {
//            let p: CGPoint = pan.translation(in: self)
//            let width = self.contentView.frame.width
//            let height = self.contentView.frame.height
//            self.contentView.frame = CGRect(x: p.x,y: 0, width: width, height: height);
//            //self.deleteLabel1.frame = CGRect(x: p.x - deleteLabel1.frame.size.width-10, y: 0, width: 100, height: height)
//            //self.clearButton.frame = CGRect(x: p.x + width + deleteLabel1.frame.size.width, y: 0, width: 100, height: height)
//            self.clearButton.frame = CGRect(x: p.x + width + clearButton.frame.size.width, y: 0, width: 70, height: height)
//        }
//
//    }
//

    @objc func onPan(_ pan: UIPanGestureRecognizer) {
        if pan.state == UIGestureRecognizerState.began {
            
        } else if pan.state == UIGestureRecognizerState.changed {
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension NotificationPostCell {
    static let paragraphStyle = { () -> NSMutableParagraphStyle in
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 3
        return style
    }()
}

