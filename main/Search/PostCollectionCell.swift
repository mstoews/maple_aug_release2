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
    
    let attributeTitle = [NSAttributedStringKey.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .title)]
    let attributeCaption = [NSAttributedStringKey.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .body2 )]
    let attributeSubline = [NSAttributedStringKey.font: UIFont.mdc_preferredFont(forMaterialTextStyle:  .subheadline )]
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.collectionCell()
        
        addSubview(posterImageView)
        addSubview(titleLabel)
        addSubview(detailLabel)
        addSubview(usernameLabel)
        
        posterImageView.anchor(top: topAnchor , left: leftAnchor, bottom: nil, right: nil,paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 0, width: 50, height: 50)
        titleLabel.anchor(top: topAnchor, left: posterImageView.rightAnchor, bottom: nil, right: nil ,paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 0, width: 0, height: 25)
        usernameLabel.anchor(top: titleLabel.bottomAnchor, left: posterImageView.rightAnchor, bottom: nil, right: nil,paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 0, width: 0, height: 15)
        detailLabel.anchor(top: usernameLabel.bottomAnchor, left: posterImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor ,paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 0, width: 0, height: 0)
    }
    
    
    @objc func usernameLabelTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        Database.fetchPostByUidPostId(uid: (post?.userId!)!, postId: (post?.objectID!)!) { (postFound) in
            //self.delegate?.didTapUserNameLabel(post: postFound)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    let posterImageView : CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        //iv.layer.cornerRadius = 40/2
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
        label.font = UIFont.systemFont(ofSize: 10)
        label.numberOfLines = 0
        return label
    }()
    
    
    let detailLabel : UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        return lb
    }()
    
    
    var post: PostRecord? {
        didSet {
            if let name = post?.name {
                usernameLabel.attributedText = NSMutableAttributedString(string: "User Name : \(name)" , attributes: attributeCaption)
            }
            
            if let product = post?.product {
                titleLabel.attributedText =  NSMutableAttributedString(string: (product) , attributes: attributeTitle)
            }
            if let desc = post?.description {
                detailLabel.attributedText = NSMutableAttributedString(string: desc, attributes: attributeCaption)
            }
            
            if  let url = post?.productImagineUrl {
                posterImageView.loadImage(urlString: url)
            }
        }
    }
}


