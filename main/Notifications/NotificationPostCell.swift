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


class NotificationPostCell: MDCCardCollectionCell {
    
    var notification: NotificationObject? {
        didSet {
            if  let sender = notification?.sender {
                Database.fetchUserWithUID(uid: sender, completion: { (user) in
                    self.usernameLabel.text = user.username
                    let profileImageUrl = user.profileImageUrl
                    self.profileImageView.loadImage(urlString: profileImageUrl)
                    self.contentLabel.text = self.notification?.content
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy/MM/dd"
                    let date = Date(timeIntervalSince1970: (self.notification?.date)!)
                    let timeAgoDisplay = date.timeAgoDisplay()
                    self.timeLabel.text = timeAgoDisplay
                })
            }
        }
    }
    
    var delegate: NotificationDelegate?
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
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
    
    func populateContent(from: MapleUser, text: String, date: Double, index: Int, isDryRun: Bool)
    {
        let dateCreated = Date(timeIntervalSince1970: date)
        
        let commentText =  NSMutableAttributedString(string: text, attributes: attributes)
        commentText.addAttribute(.paragraphStyle, value: NotificationPostCell.paragraphStyle, range: NSMakeRange(0, commentText.length))
        //commentText.append(NSAttributedString(string: "\n" + dateCreated.timeAgoDisplay() , attributes: captionAttr))
        
        contentLabel.attributedText = commentText
        timeLabel.text = dateCreated.timeAgoDisplay()
        
        
        if !isDryRun {
            profileImageView.accessibilityLabel = from.username
            profileImageView.accessibilityHint = "Double-tap to open profile."
            profileImageView.loadImage(urlString: from.profileImageUrl)
            profileImageView.tag = 1
            contentLabel.tag = 1
            profileImageView.loadImage(urlString: from.profileImageUrl)
        }
    
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(profileImageView)
        //self.contentView.addSubview(usernameLabel)
        self.contentView.addSubview(contentLabel)
        self.contentView.addSubview(timeLabel)
        self.contentView.addSubview(clearButton)
        self.contentView.addSubview(saveButton)
        
        
        
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        

        contentLabel.anchor(top: contentView.topAnchor, left: profileImageView.rightAnchor, bottom: nil,
                            right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 8,
                            paddingBottom: 5, paddingRight: 60, width: 0, height: 40)
        
        
//        saveButton.anchor(top: contentLabel.topAnchor, left: nil, bottom: nil,
//                            right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 2,
//                            paddingBottom: 5, paddingRight: 2, width: 25, height: 25)
        
        clearButton.anchor(top: contentLabel.topAnchor, left: nil, bottom: nil,
                               right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 2,
                               paddingBottom: 5, paddingRight: 2, width: 25, height: 25)
        
        timeLabel.anchor(top: contentLabel.bottomAnchor, left:  profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8,
                         paddingBottom: 0, paddingRight: 0, width: 0, height: 10)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension NotificationPostCell {
    static let paragraphStyle = { () -> NSMutableParagraphStyle in
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 2
        return style
    }()
    
    
    
}

