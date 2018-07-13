//
//  UserSearchCell.swift
//  InstagramFirebase
//
//  Created by Murray Toews on 6/3/17.
//  Copyright © 2017 maple.com
import UIKit

class CategorySearchCell: UICollectionViewCell {
   
    var post: Post? {
        didSet {
            postnameLabel.text = post?.caption
            detailTextLabel.text = post?.category
            usernameLabel.text = "User : " + (post?.user.username)!
            guard let postfileImageURL = post?.imageUrl else {return}
            postImageView.loadImage(urlString: postfileImageURL)
        }
    }
    
    
    let postImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
       label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
   
    
    let postnameLabel: UILabel = {
        let label = UILabel()
        label.text = "Post"
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    
    let detailTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Detailed Text"
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(postImageView)
        addSubview(postnameLabel)
        addSubview(detailTextLabel)
        addSubview(usernameLabel)
        
        postImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        postImageView.layer.cornerRadius = 40 / 2
        postImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        postnameLabel.anchor(top: topAnchor, left: postImageView.rightAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 80, height: 0)
        
        detailTextLabel.anchor(top: topAnchor, left: postnameLabel.rightAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 80, height: 0)
       
        usernameLabel.anchor(top: topAnchor, left: detailTextLabel.rightAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 100, height: 0)
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        addSubview(separatorView)
        separatorView.anchor(top: nil, left: postnameLabel.leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
