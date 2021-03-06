//
//  PostCollectionCell.swift
//  maple_release
//
//  Created by Murray Toews on 2018/05/04.
//  Copyright © 2018 Murray Toews. All rights reserved.
//

//
//  PostTableCell.swift
//  maple-release
//
//  Created by Murray Toews on 2018/02/27.
//  Copyright © 2018 Murray Toews. All rights reserved.
//

import AlgoliaSearch
import InstantSearchCore
//import AFNetworking
import UIKit
import Firebase
import FirebaseFirestore
import MaterialComponents



class PostCollectionCell: MDCCardCollectionCell  {
    
    static let placeholder = UIImage(named: "placeholder")!
    
    public var imageConstraint: NSLayoutConstraint?
    public var imageWidthContraint: NSLayoutConstraint?
    
    let attributeTitle = [NSAttributedString.Key.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .title)]
    let attributeCaption = [NSAttributedString.Key.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .body2 )]
    let attributeSubline = [NSAttributedString.Key.font: UIFont.mdc_preferredFont(forMaterialTextStyle:  .subheadline )]
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.collectionCell()
        
        addSubview(posterImageView)
        //addSubview(titleLabel)
        //addSubview(detailLabel)
        //addSubview(usernameLabel)
        
        //titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil ,paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 0, width: 0, height: 25)
        
        //posterImageView.anchor(top: titleLabel.bottomAnchor , left: leftAnchor, bottom: nil, right: nil,paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 0, width: 100, height: 100)
        posterImageView.anchor(top: topAnchor , left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        
        //usernameLabel.anchor(top: titleLabel.bottomAnchor, left: posterImageView.rightAnchor, bottom: nil, right: nil,paddingTop: 4, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        
        //detailLabel.anchor(top: usernameLabel.bottomAnchor, left: posterImageView.rightAnchor, bottom: nil, right: rightAnchor ,paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 5 , width: 0, height: 0)
    }
    
    
    @objc func usernameLabelTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        //Database.fetchPostByUidPostId(uid: (post?.userId!)!, postId: (post?.objectID!)!) { (postFound) in
            //self.delegate?.didTapUserNameLabel(post: postFound)
        //}
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    let posterImageView : CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        //iv.layer.cornerRadius = 40/8
        iv.clipsToBounds = true
        return iv
    }()
    
    let titleLabel : UILabel = {
        let lb = UILabel()
        lb.text = "titleLable"
        lb.font = UIFont.systemFont(ofSize: 10)
        lb.numberOfLines = 0
        return lb
    }()
    
    //    let postImageView: CustomImageView = {
    //        let iv = CustomImageView()
    //        iv.contentMode = .scaleAspectFill
    //        iv.clipsToBounds = true
    //        return iv
    //    }()
    //
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "userName"
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        return label
    }()
    
    
    let detailLabel : UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        lb.textAlignment = NSTextAlignment.left;
        lb.sizeToFit()
       
        return lb
    }()
    
    
    var post: PostRecord? {
        didSet {
            if let name = post?.name {
                usernameLabel.attributedText = NSMutableAttributedString(string: "\(name)" , attributes: attributeTitle)
            }
            
            
            
            if let product = post?.product {
                titleLabel.attributedText =  NSMutableAttributedString(string: (product) , attributes: attributeTitle)
            }
            
            if let desc = post?.description {
                let nsString = desc as NSString
                if nsString.length >= 190
                {
                    let desc = nsString.substring(with: NSRange(location: 0, length: nsString.length > 190 ? 190 : nsString.length))
                    detailLabel.attributedText = NSMutableAttributedString(string: desc as String , attributes: attributeCaption)
                }
                else
                {
                     detailLabel.attributedText = NSMutableAttributedString(string: desc, attributes: attributeCaption)
                }
               
            }
            
            if  let url = post?.imageUrl {
                posterImageView.loadImage(urlString: url.absoluteString)
            }
        }
    }
}


