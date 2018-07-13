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
    
    public var imageConstraint: NSLayoutConstraint?
    public var imageWidthContraint: NSLayoutConstraint?
    
    let attributeTitle = [NSAttributedStringKey.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .title)]
    let attributeCaption = [NSAttributedStringKey.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .body2 )]
    let attributeSubline = [NSAttributedStringKey.font: UIFont.mdc_preferredFont(forMaterialTextStyle:  .subheadline )]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.collectionCell()
        addSubview(posterImageView)
        addSubview(usernameLabel)
        
        posterImageView.anchor(top: topAnchor , left: leftAnchor, bottom: nil, right: nil,paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 0, width: 50, height: 50)
        usernameLabel.anchor(top: topAnchor, left: posterImageView.rightAnchor, bottom: nil, right: nil,paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 0, width: 0, height: 40)
        
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
    
    let posterImageView : CustomImageView = {
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
    
    /*
     Possibly it would be good to have number of posts for each user which could be added in the backend for number of likes etc.
     This would give people and indication of the activity of the users.
     */
    
    
    var userRecord: UserRecord? {
        didSet {
            
            if let name = userRecord?.name {
                usernameLabel.attributedText = NSMutableAttributedString(string: "\(name)" , attributes: attributeTitle)
            }
            
            if let imageUrl = userRecord?.profileURL {
                posterImageView.loadImage(urlString: imageUrl)
            }
            
        }
    }
}

