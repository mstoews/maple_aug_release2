//
//  SearchTableCell.swift
//  maple-release
//
//  Created by Murray Toews on 2018/03/06.
//  Copyright © 2018 Murray Toews. All rights reserved.
//

//import AFNetworking
import UIKit
import Firebase
import FirebaseFirestore
import AlgoliaSearch
import InstantSearchCore


class SearchTableCell: UITableViewCell {
    
    static let placeholder = UIImage(named: "placeholder")!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //let tapFollowers = UITapGestureRecognizer(target: self, action: #selector(usernameLabelTapped(tapGestureRecognizer: )))
        //usernameLabel.isUserInteractionEnabled = true
        //usernameLabel.addGestureRecognizer(tapFollowers)
        
        addSubview(posterImageView)
        addSubview(titleLabel)
        addSubview(detailLabel)
 
        posterImageView.anchor( top: topAnchor ,             left: leftAnchor,                  bottom: nil,          right: nil,           paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 0, width: 30, height: 30)
        titleLabel.anchor(      top: topAnchor,              left: posterImageView.rightAnchor, bottom: nil,          right: nil,           paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 0, width: 0, height: 12)
        detailLabel.anchor(     top: titleLabel.bottomAnchor,left: posterImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor ,  paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 0, width: 0, height: 12)
    }
    
    
    @objc func usernameLabelTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
            // Database.fetchPostByUidPostId(uid: (post?.userId!)!, postId: (post?.objectID!)!) { (postFound) in
            //self.delegate?.didTapUserNameLabel(post: postFound)
        //}
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    let posterImageView : CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        //iv.layer.cornerRadius = 30/2
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
    
    
    let detailLabel : UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        return lb
    }()
    
    var post: PostRecord? {
        didSet {
            if let product = post?.product {
                titleLabel.attributedText =  NSMutableAttributedString(string: product, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10)])
            }
            if let desc = post?.description {
                detailLabel.attributedText = NSMutableAttributedString(string: desc, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10)])
            }
            
            if let url = post?.imageUrl {
                posterImageView.loadImage(urlString: url.absoluteString)
            }
        }
    }
}
