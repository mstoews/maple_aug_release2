//
//  PostCollectionCell.swift
//  maple_release
//
//  Created by Murray Toews on 2018/05/04.
//  Copyright © 2018 Murray Toews. All rights reserved.
//


import AlgoliaSearch
import InstantSearchCore
//import AFNetworking
import UIKit
import Firebase
import FirebaseFirestore
import MaterialComponents

class UserCollectionCell: MDCCardCollectionCell {
    
    static let placeholder = UIImage(named: "placeholder")!
    var userId : String!
    
    
    public var imageConstraint: NSLayoutConstraint?
    public var imageWidthContraint: NSLayoutConstraint?
    
    let attributeTitle = [NSAttributedStringKey.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .title)]
    let attributeCaption = [NSAttributedStringKey.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .body2 )]
    let attributeSubline = [NSAttributedStringKey.font: UIFont.mdc_preferredFont(forMaterialTextStyle:  .subheadline )]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.collectionCell()
        addSubview(profileImageView)
        addSubview(usernameLabel)
        
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        
        stackView.axis = .horizontal;
        stackView.distribution = .equalSpacing;
        stackView.alignment = .leading;
        stackView.spacing = 10;
        
        addSubview(stackView)
        
        profileImageView.anchor(top: topAnchor , left: leftAnchor, bottom: nil, right: nil,paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 0, width: 50, height: 50)
        usernameLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil,paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 0, width: 0, height: 30)
        
        stackView.anchor(top: usernameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor  , paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
        
    }
    
    @objc func usernameLabelTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if let uid = userRecord?.objectID {
            //self.delegate?.didTapUserNameLabel(uid: uid)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var userView: MapleUser? {
        didSet {
            guard let profileImageUrl = userView?.profileImageUrl else { return }
            profileImageView.loadImage(urlString: profileImageUrl)
            usernameLabel.text = userView?.username
            if let uid = userView?.uid  {
                userId = uid
            }
        }
    }
    
    
    let profileImageView : CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "userName"
        label.font = UIFont.systemFont(ofSize: 10)
        label.numberOfLines = 0
        return label
    }()
    
    
    fileprivate func getNumberOfPosts() {
        if let postCount = userView?.postCount {
            self.postsLabel.attributedText = NSMutableAttributedString(string:     "Posts\t\t : \(postCount)" , attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        }}
    
    fileprivate func getNumberOfFollowers()
    {
        // Followers
        if let followersCount = userView?.followersCount {
            self.followersLabel.attributedText = NSMutableAttributedString(string: "Followers\t : \(followersCount)" , attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        }
    }
    
    
    fileprivate func getNumberOfFollowing()
    {
        // Following
        if let followingCount = userView?.followedCount {
            self.followingLabel.attributedText = NSMutableAttributedString(string: "Followed\t : \(followingCount)" , attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        }
    }
    
    
    /*
     Possibly it would be good to have number of posts for each user which could be added in the backend for number of likes etc.
     This would give people and indication of the activity of the users.
     */
    
    
    let postsLabel: UILabel = {
        let label = UILabel()
        var strPosts =  "0\n"
        let attributedText = NSMutableAttributedString(string: "Posts : \(strPosts)" , attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        label.attributedText = attributedText
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    // Return number of posts from : getNumberOfPosts()
    
    let followersLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "Followers : 0", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        label.attributedText = attributedText
        
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    let followingLabel: UILabel  = {
        let label  = UILabel()
        let attributedText = NSMutableAttributedString(string: "Following : 0", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    var userRecord: UserRecord? {
        didSet {
            
            if let name = userRecord?.name {
                usernameLabel.attributedText = NSMutableAttributedString(string: "\(name)" , attributes: attributeTitle)
            }
            
            if let imageUrl = userRecord?.profileURL {
                profileImageView.loadImage(urlString: imageUrl)
            }
            
        }
    }
}

