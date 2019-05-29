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
    
    let attributeTitle = [NSAttributedString.Key.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .title)]
    let attributeCaption = [NSAttributedString.Key.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .body2 )]
    let attributeSubline = [NSAttributedString.Key.font: UIFont.mdc_preferredFont(forMaterialTextStyle:  .subheadline )]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.collectionCell()
        addSubview(profileImageView)
        addSubview(usernameLabel)
        addSubview(explanationLabel)
        
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        
        stackView.axis = .vertical;
        stackView.distribution = .equalSpacing;
        stackView.alignment = .leading;
        stackView.spacing = 5;
        
        addSubview(stackView)
        
        profileImageView.anchor(top: topAnchor , left: leftAnchor, bottom: nil, right: nil,paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 0, width: 100, height: 100)
        
        usernameLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil,paddingTop: 1,
            paddingLeft: 3, paddingBottom: 5, paddingRight: 0, width: 0, height: 30)
        
        stackView.anchor(top: usernameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor  , paddingTop: 4, paddingLeft: 3, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        explanationLabel.anchor(top: stackView.topAnchor, left: stackView.rightAnchor, bottom: nil, right: rightAnchor  , paddingTop: 0, paddingLeft: 3, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
   
    
    let profileImageView : CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 40/8
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
    
    let explanationLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 10)
        label.numberOfLines = 0
        return label
    }()
    
    
    
    let postsLabel: UILabel = {
        let label = UILabel()
        var strPosts =  "0\n"
   
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    // Return number of posts from : getNumberOfPosts()
    
    let followersLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    let followingLabel: UILabel  = {
        let label  = UILabel()
        let attributedText = NSMutableAttributedString(string: "Following : 0", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    var userRecord: UserRecord? {
        didSet
        {
            if let postCount = userRecord?.postCount {
                postsLabel.attributedText = NSMutableAttributedString(string: "Posts : \(postCount)" , attributes: attributeCaption)
            }
            
            if let followedCount = userRecord?.followedCount {
                followersLabel.attributedText = NSMutableAttributedString(string: "Followers : \(followedCount)" , attributes: attributeCaption)
            }
            
            if let followerCount = userRecord?.followerCount {
                followingLabel.attributedText = NSMutableAttributedString(string: "Following : \(followerCount)" , attributes: attributeCaption)
            }
            
            if let name = userRecord?.username {
                usernameLabel.attributedText = NSMutableAttributedString(string: "\(name )" , attributes: attributeTitle)
            }
            
            if let imageUrl = userRecord?.profileImageUrl {
                profileImageView.loadImage(urlString: imageUrl)
            }
            
            
        }
    }
}

