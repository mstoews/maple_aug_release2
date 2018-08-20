//
//  UserGridPostCell.swift
//  maple-release
//
//  Created by Murray Toews on 2018/02/04.
//  Copyright © 2018 Murray Toews. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import BadgeSwift
import MaterialComponents


protocol UserGridPostCellDelegate {
    func didTapComment(post: FSPost)
    func didLike(for cell: UserGridPostCell)
    func didTapModify(post: FSPost)
    func didTapBookmark(for cell : UserGridPostCell)
    func didTapImage(for cell : PostImage, post: FSPost)
    func didSharePost(post: FSPost, imageObject: ImageObject)
    func didTapUserNameLabel(uid: String)
    func didTapImageCell(for cell:  UserImageCell, post: FSPost)
}


class UserListPostCell : UserGridPostCell {
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (frame.size.width / 3)
        return CGSize(width: width , height: width)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    
    override func setupCollectionCell ()
    {
        imageCollectionView.register(UserImageCell.self, forCellWithReuseIdentifier: horizontalCellId)
        
        
        backgroundColor = UIColor.white
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor.collectionCell()
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor.collectionCell()
        
        let leftDivider = UIView()
        leftDivider.backgroundColor = UIColor.collectionCell()
        
        let rightDivider = UIView()
        rightDivider.backgroundColor = UIColor.collectionCell()
        
        let topDivider = UIView()
        topDivider.backgroundColor = UIColor.collectionCell()
        
        
        
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        
        addSubview(usernameLabel)
        addSubview(imageCollectionView)
        addSubview(editButton)
        addSubview(likeButton)
        addSubview(commentButton)
        addSubview(bookmarkButton)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        addSubview(captionLabel)
        addSubview(timeAgoLabel)
        addSubview(likeBadge)
        addSubview(bookMarkBadge)
        addSubview(commentBadge)
        addSubview(leftDivider)
        addSubview(rightDivider)
        addSubview(topDivider)
        
        usernameLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil,right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: frame.size.width - 100 , height: 30)
        
        // 30
        
        topDivider.anchor(top: usernameLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0 , paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        // 1.5
        
        print("what is the width : \(frame.width)")
        
        imageCollectionView.anchor(top: topDivider.bottomAnchor,
                                   left: leftAnchor,
                                   bottom: nil ,
                                   right: rightAnchor,
                                   paddingTop: 2,
                                   paddingLeft: 4,
                                   paddingBottom: 0,
                                   paddingRight: 4,
                                   width: 0,
                                   height: frame.width / 3)
        
        // 375
        
        topDividerView.anchor(top: imageCollectionView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor,paddingTop: 2 , paddingLeft: 2, paddingBottom: 0, paddingRight: 2, width: 0, height: 0.5)
        
        // 1.5
        
        likeButton.anchor     (top: imageCollectionView.bottomAnchor, left: leftAnchor,                 bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: -15 , width: 50, height: 40)
        // 40
        commentButton.anchor  (top: imageCollectionView.bottomAnchor, left: likeButton.rightAnchor,     bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: -15 , width: 50, height: 40)
        bookmarkButton.anchor (top: imageCollectionView.bottomAnchor, left: commentButton.rightAnchor,  bottom: nil, right: nil, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: -15 , width: 50, height: 40)
        editButton.anchor     (top: imageCollectionView.bottomAnchor, left: bookmarkButton.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: -15 , width: 50, height: 40)
        timeAgoLabel.anchor   (top: imageCollectionView.bottomAnchor, left: editButton.rightAnchor,     bottom: nil, right: nil, paddingTop: 0, paddingLeft: 45, paddingBottom: 0, paddingRight: 0 , width: 0, height: 20)
        
        
        commentBadge.anchor(top: topDividerView.topAnchor, left: commentButton.rightAnchor, bottom: nil, right: nil, paddingTop: 2, paddingLeft: -20, paddingBottom: 0, paddingRight: 0 , width: 0, height: 0)
        
        likeBadge.anchor(top: topDividerView.topAnchor, left: likeButton.rightAnchor, bottom: nil, right: nil, paddingTop: 2, paddingLeft: -20, paddingBottom: 0, paddingRight: 0 , width: 0, height: 0)
        
        bookMarkBadge.anchor(top: topDividerView.topAnchor, left: bookmarkButton.rightAnchor, bottom: nil, right: nil, paddingTop: 2, paddingLeft: -22, paddingBottom: 0, paddingRight: 0 , width: 0, height: 0)
        captionLabel.anchor(top: likeButton.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 2, paddingLeft: 4, paddingBottom: 4, paddingRight: 0 , width: 0, height: 0)
        //bottomDividerView.anchor(top: captionLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0 , paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
}



class UserGridPostCell: MDCCardCollectionCell , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    public var imageConstraint: NSLayoutConstraint?
    let attributeTitle = [NSAttributedStringKey.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .title)]
    let attributeCaption = [NSAttributedStringKey.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .body2 )]
    let attributeSubline = [NSAttributedStringKey.font: UIFont.mdc_preferredFont(forMaterialTextStyle:  .subheadline )]
    
    override func updateConstraints() {
        super.updateConstraints()
        
        let constant = MDCCeil((self.bounds.width - 2) * 0.65)
        if imageConstraint == nil {
            imageConstraint = imageCollectionView.heightAnchor.constraint(equalToConstant: constant)
            imageConstraint?.isActive = true
        }
        imageConstraint?.constant = constant
    }
    
    var horizontalCellId = "postImageCellId"
    var images = [ImageObject]()
    
    var delegate : UserGridPostCellDelegate?
    
//    var post: FSPost? {
//        didSet {
//            images.removeAll()
//            bookmarkButton.setImage(post?.hasBookmark == true ? #imageLiteral(resourceName: "ic_bookmark_border").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "ic_bookmark").withRenderingMode(.alwaysOriginal), for: .normal)
//            if post?.hasLiked == true {
//                print ("Post liked \(String(describing: post?.hasLiked))")
//                likeButton.setImage(#imageLiteral(resourceName: "like_selected-1").withRenderingMode(.alwaysOriginal), for: .normal)
//            }
//            else {
//                print ("Post unliked \(String(describing: post?.hasLiked))")
//                likeButton.setImage(#imageLiteral(resourceName: "Heart_Unselected-1").withRenderingMode(.alwaysOriginal), for: .normal)
//            }
//
//
//            if let caption = post?.product {
//                var attributedText: NSMutableAttributedString?
//                attributedText = NSMutableAttributedString(string: caption , attributes: attributeTitle)
//                usernameLabel.attributedText = attributedText
//            }
//
//            if let count = post?.imageUrlArray.count {
//                if count > 0 {
//                    for url in (post?.imageUrlArray)! {
//                        print(url)
//                        let obj = ImageObject(postid: (post?.id)!, imageid: "" , url: url)
//                        images.append(obj)
//                    }
//                }
//            }
//
//            if let postId = post?.id {
//                Database.fetchNumberOfLikesByPostId(postid: postId, { (totalLikes) in
//                    self.setNumberOfLikes(likes: totalLikes)
//                })
//            }
//
//            if let postId = post?.id {
//                Database.fetchPostNumberOfComments(postid: postId, { (totalComments) in
//                    self.setNumberOfComments(likes: totalComments)
//                })
//            }
//
//            if let postId = post?.id {
//                Database.fetchPostNumberofBookmarks(postid: postId, { (totalBookmarks) in
//                    self.setNumberOfBookmarks(likes: totalBookmarks)
//                })
//            }
//
//            setupAttributedCaption()
//
//            self.imageCollectionView.reloadData()
//        }
//    }
//

    var post: FSPost? {
        
        didSet {
            if post == nil
            {
                return
            }
            images = []
            
            var isLikedByUid = false
            var isBookMarkedByUid = false
            
            if let postId = post?.id {
                if let uid = post?.uid {
                    Firestore.isPostLikeByUser(postId: postId, uid: uid,  { (isLiked) in
                        if isLiked == true {
                            self.likeButton.setImage(#imageLiteral(resourceName: "ic_favorite").withRenderingMode(.alwaysOriginal), for: .normal)
                            isLikedByUid = true
                        }
                        else
                        {
                            self.likeButton.setImage(#imageLiteral(resourceName: "ic_favorite_border").withRenderingMode(.alwaysOriginal), for: .normal)
                            isLikedByUid = false
                        }
                        
                    })
                    
                    Firestore.isPostBoookMarkedByUser(postId: postId, uid: uid,  { (isBookmarked) in
                        //self.bookmarkButton.setImage(fs_post?.hasBookmark == true ? #imageLiteral(resourceName: "ic_bookmark").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "ic_bookmark_border").withRenderingMode(.alwaysOriginal), for: .normal)
                        self.bookmarkButton.setImage(isBookmarked == true ? #imageLiteral(resourceName: "ic_bookmark").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "ic_bookmark_border").withRenderingMode(.alwaysOriginal), for: .normal)
                        isBookMarkedByUid = isBookmarked
                    })
                    
                    
                }
            }
            
            if let uid = post?.uid {
                if uid != Auth.auth().currentUser?.uid {
                    self.editButton.isHidden = true
                }
            }
            
            post?.isLiked = isLikedByUid
            post?.isBookmarked = isBookMarkedByUid
            self.hideLikesBadge(0)
            self.hideMarkBadge(0)
            self.hideCommentBadge(0)
            
            usernameLabel.text = "TEST USERNAME"
            if let userName = post?.userName {
                if let product = post?.product {
                    usernameLabel.attributedText = setUserName(userName: userName, caption: product)
                }
                
            }
            
            if let profileURL = post?.profileURL {
                self.userProfileImageView.loadImage(urlString: profileURL)
            }
            
            
            if let postid = post?.id {
                if let count = post?.imageUrlArray.count {
                    if count > 0 {
                        for url in (post?.imageUrlArray)! {
                            let obj = ImageObject(postid: postid, imageid: url , url: url)
                            images.append(obj)
                        }
                    }
                }
            }
            
            if let likes = post?.noOfLikes {
                    self.putNumberOfLikes(likes: likes )
            }
            
            if let comments = post?.noOfLikes {
                    self.putNumberOfComments(likes: comments)
            }
            
//            if let postId = post?.id {
//                Firestore.getPostCollectionCount(collection: "bookmarked", postId: postId,  { (bookmarkCount) in
//                    self.putNumberOfBookmarks(likes: bookmarkCount)
//                })
//            }
            
            if let description = post?.description {
                let attributedText = NSMutableAttributedString(string: description, attributes: attributeCaption)
                captionLabel.attributedText = attributedText
            }
            
            if let timeAgoDisplay = post?.creationDate.timeAgoDisplay() {
                let timeAttributedText = NSMutableAttributedString(string: timeAgoDisplay, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 8)])
                timeAgoLabel.attributedText = timeAttributedText
            }
            
            self.imageCollectionView.reloadData()
        }
        
    }
    
    fileprivate func setUserName(userName: String, caption: String) -> NSMutableAttributedString
    {
        var attributedText: NSMutableAttributedString?
        attributedText = NSMutableAttributedString(string: "" , attributes: attributeCaption)
        //attributedText?.append(NSMutableAttributedString(string: userName , attributes: [NSAttributedStringKey.font: font as Any]))
        attributedText?.append(NSMutableAttributedString(string: userName , attributes:attributeCaption))
        attributedText?.append(NSMutableAttributedString(string: " : " , attributes: attributeCaption))
        attributedText?.append(NSMutableAttributedString(string: caption , attributes: attributeCaption))
        
        return attributedText!
    }
    
    fileprivate func hideLikesBadge(_ likes: Int) {
        if (likes > 0 ) { self.likeBadge.isHidden = false } else { self.likeBadge.isHidden = true }
    }
    
    fileprivate func putNumberOfLikes(likes: Int)
    {
        self.likeBadge.isHidden = true
        var attributedText: NSMutableAttributedString?
        let sLikes = "\(likes)"
        attributedText = NSMutableAttributedString(string: sLikes , attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 8)])
        self.likeBadge.attributedText = attributedText
        hideLikesBadge(likes)
    }
    
    fileprivate func hideCommentBadge(_ likes: Int) {
        if (likes > 0 ) { self.commentBadge.isHidden = false } else { self.commentBadge.isHidden = true }
    }
    
    fileprivate func putNumberOfComments(likes: Int)
    {
        self.commentBadge.isHidden = true
        var attributedText: NSMutableAttributedString?
        let sLikes = "\(likes)"
        attributedText = NSMutableAttributedString(string: sLikes , attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 8)])
        self.commentBadge.attributedText = attributedText
        hideCommentBadge(likes)
    }
    
    
    
    fileprivate func hideMarkBadge(_ likes: Int) {
        if (likes > 0 ) { self.bookMarkBadge.isHidden = false } else { self.bookMarkBadge.isHidden = true }
    }
    
    fileprivate func putNumberOfBookmarks(likes: Int)
    {
        self.bookMarkBadge.isHidden = true
        var attributedText: NSMutableAttributedString?
        let sLikes = "\(likes)"
        attributedText = NSMutableAttributedString(string: sLikes , attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 8)])
        self.bookMarkBadge.attributedText = attributedText
        hideMarkBadge(likes)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: horizontalCellId, for: indexPath) as! UserImageCell
        let  item = indexPath.item
        
        if images.count > 0, item <=  images.count{
            cell.imageObject = images[item]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = frame.size.width
        return CGSize(width: width , height: width)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: horizontalCellId, for: indexPath) as! UserImageCell
        if images.count > 0 {
            cell.imageObject = images[indexPath.item]
        }
        delegate?.didTapImageCell(for: cell, post: post!)
    }
    
    fileprivate func setNumberOfLikes(likes: Int)
    {
        var attributedText: NSMutableAttributedString?
        let sLikes = "\(likes)"
        attributedText = NSMutableAttributedString(string: "" , attributes: attributeCaption)
        attributedText = NSMutableAttributedString(string: sLikes , attributes:  attributeCaption)
        self.likeBadge.attributedText = attributedText
        if (likes > 0 ) { self.likeBadge.isHidden = false } else { self.likeBadge.isHidden = true }
    }
    
    fileprivate func setNumberOfComments(likes: Int)
    {
        var attributedText: NSMutableAttributedString?
        let sLikes = "\(likes)"
        attributedText = NSMutableAttributedString(string: "" , attributes: attributeCaption)
        attributedText = NSMutableAttributedString(string: sLikes , attributes: attributeCaption)
        self.commentBadge.attributedText = attributedText
        if (likes > 0 ) { self.commentBadge.isHidden = false } else { self.commentBadge.isHidden = true }
    }
    fileprivate func setNumberOfBookmarks(likes: Int)
    {
        var attributedText: NSMutableAttributedString?
        let sLikes = "\(likes)"
        attributedText = NSMutableAttributedString(string: "" , attributes: attributeCaption)
        attributedText = NSMutableAttributedString(string: sLikes , attributes: attributeCaption)
        self.bookMarkBadge.attributedText = attributedText
        if (likes > 0 ) { self.bookMarkBadge.isHidden = false } else { self.bookMarkBadge.isHidden = true }
    }
    
    
    fileprivate func setupAttributedCaption() {
        guard let post = self.post else { return }
        let attributedText = NSMutableAttributedString(string: "", attributes: attributeTitle)
        attributedText.append(NSAttributedString(string: post.description))
        
        captionLabel.attributedText = attributedText
        let timeAgoDisplay = post.creationDate.timeAgoDisplay()
        
        let timeAttributedText = NSMutableAttributedString(string: timeAgoDisplay, attributes: attributeCaption )
        timeAgoLabel.attributedText = timeAttributedText
        print (timeAgoLabel.text!)
    }
    
    let userProfileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        return iv
    }()
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        return label
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_favorite_border").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    @objc func handleLike() {
        delegate?.didLike(for: self)
    }
    
    lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_share").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_edit").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleEditMenu), for: .touchUpInside)
        return button
    }()
    
    
    lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_comment").withRenderingMode(.alwaysOriginal), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()
    
    lazy var bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_bookmark_border").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleBookmark), for: .touchUpInside)
        return button
    }()
    
    lazy var mapButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_map").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleEditButton), for: .touchUpInside)
        return button
    }()
    
    
    
    
    lazy var commentBadge : BadgeSwift = {
        let badge = BadgeSwift()
        badge.text = ""
        badge.insets = CGSize(width: 2, height: 2)
        badge.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
        badge.textColor = UIColor.white
        badge.badgeColor = UIColor.red
        badge.shadowOpacityBadge = 0.5
        badge.shadowOffsetBadge = CGSize(width: 0, height: 0)
        badge.shadowRadiusBadge = 0.5
        badge.shadowColorBadge = UIColor.black
        badge.shadowOpacityBadge = 0
        badge.borderWidth = 1.0
        badge.borderColor = UIColor.white
        return badge
    }()
    
    lazy var likeBadge : BadgeSwift = {
        let badge = BadgeSwift()
        badge.text = ""
        badge.insets = CGSize(width: 2, height: 2)
        badge.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
        badge.textColor = UIColor.white
        badge.badgeColor = UIColor.red
        badge.shadowOpacityBadge = 0.5
        badge.shadowOffsetBadge = CGSize(width: 0, height: 0)
        badge.shadowRadiusBadge = 0.5
        badge.shadowColorBadge = UIColor.black
        badge.shadowOpacityBadge = 0
        badge.borderWidth = 1.0
        badge.borderColor = UIColor.white
        return badge
    }()
    lazy var bookMarkBadge : BadgeSwift = {
        let badge = BadgeSwift()
        badge.text = ""
        badge.insets = CGSize(width: 2, height: 2)
        badge.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
        badge.textColor = UIColor.white
        badge.badgeColor = UIColor.red
        badge.shadowOpacityBadge = 0.5
        badge.shadowOffsetBadge = CGSize(width: 0, height: 0)
        badge.shadowRadiusBadge = 0.5
        badge.shadowColorBadge = UIColor.black
        badge.shadowOpacityBadge = 0
        badge.borderWidth = 1.0
        badge.borderColor = UIColor.white
        return badge
    }()
    
    @objc func handleComment() {
        print("Trying to show comments...")
        //uard let post = post else { return }
        delegate?.didTapComment(post: post!)
    }
    
    
    @objc func handleBookmark() {
        print("Handle the bookmarks ...")
        bookmarkButton.setImage(post?.hasBookmark == true ? #imageLiteral(resourceName: "ic_bookmark").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "ic_check").withRenderingMode(.alwaysOriginal), for: .normal)
        delegate?.didTapBookmark(for: self)
    }
    
    
  
    
    @objc func handleEditButton() {
        //delegate?.didTapModify(post: post!)
    }
    
    let imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(hue: 30/360, saturation: 2/100, brightness: 99/100, alpha: 0.8)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    
    let captionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    let timeAgoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "icons8-Edit Property-b_w").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleEditMenu), for: .touchUpInside)
        return button
    }()
    
    @objc func handleEditMenu()
    {
        print ("Handle Edit Menu")
        guard let post = post else { return }
        delegate?.didTapModify(post: post)
    }
    
   


  
    
    func setupCollectionCell ()
    {
        imageCollectionView.register(UserImageCell.self, forCellWithReuseIdentifier: horizontalCellId)
        
        backgroundColor = UIColor.collectionCell()
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor.collectionCell()
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor.collectionCell()
        
        let leftDivider = UIView()
        leftDivider.backgroundColor = UIColor.collectionCell()
        
        let rightDivider = UIView()
        rightDivider.backgroundColor = UIColor.collectionCell()
        
        let topDivider = UIView()
        topDivider.backgroundColor = UIColor.collectionCell()
        
        
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        
        addSubview(usernameLabel)
        addSubview(imageCollectionView)
        addSubview(editButton)
        addSubview(likeButton)
        addSubview(commentButton)
        addSubview(bookmarkButton)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        addSubview(captionLabel)
        addSubview(timeAgoLabel)
        addSubview(likeBadge)
        addSubview(bookMarkBadge)
        addSubview(commentBadge)
        addSubview(leftDivider)
        addSubview(rightDivider)
        addSubview(topDivider)
        
        usernameLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil,right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: frame.size.width - 100 , height: 30)
        
        // 30
        
        topDivider.anchor(top: usernameLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0 , paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        // 1.5
        
        print("what is the width : \(frame.width)")
        
        imageCollectionView.anchor(top: topDivider.bottomAnchor,
                                   left: leftAnchor,
                                   bottom: nil ,
                                   right: rightAnchor,
                                   paddingTop: 2,
                                   paddingLeft: 4,
                                   paddingBottom: 0,
                                   paddingRight: 4,
                                   width: 0,
                                   height: frame.width)
        
        // 375
        
        topDividerView.anchor(top: imageCollectionView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor,paddingTop: 2 , paddingLeft: 2, paddingBottom: 0, paddingRight: 2, width: 0, height: 0.5)
        
        // 1.5
        
        likeButton.anchor     (top: imageCollectionView.bottomAnchor, left: leftAnchor,                 bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: -15 , width: 50, height: 40)
        // 40
        commentButton.anchor  (top: imageCollectionView.bottomAnchor, left: likeButton.rightAnchor,     bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: -15 , width: 50, height: 40)
        bookmarkButton.anchor (top: imageCollectionView.bottomAnchor, left: commentButton.rightAnchor,  bottom: nil, right: nil, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: -15 , width: 50, height: 40)
        editButton.anchor     (top: imageCollectionView.bottomAnchor, left: bookmarkButton.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: -15 , width: 50, height: 40)
        timeAgoLabel.anchor      (top: imageCollectionView.bottomAnchor, left: editButton.rightAnchor,     bottom: nil, right: nil, paddingTop: 0, paddingLeft: 70, paddingBottom: 0, paddingRight: 0 , width: 0, height: 20)
        
        
        commentBadge.anchor(top: topDividerView.topAnchor, left: commentButton.rightAnchor, bottom: nil, right: nil, paddingTop: 2, paddingLeft: -20, paddingBottom: 0, paddingRight: 0 , width: 0, height: 0)
        
        likeBadge.anchor(top: topDividerView.topAnchor, left: likeButton.rightAnchor, bottom: nil, right: nil, paddingTop: 2, paddingLeft: -20, paddingBottom: 0, paddingRight: 0 , width: 0, height: 0)
        
        bookMarkBadge.anchor(top: topDividerView.topAnchor, left: bookmarkButton.rightAnchor, bottom: nil, right: nil, paddingTop: 2, paddingLeft: -22, paddingBottom: 0, paddingRight: 0 , width: 0, height: 0)
        
        captionLabel.anchor(top: likeButton.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 2, paddingLeft: 4, paddingBottom: 4, paddingRight: 0 , width: 0, height: 0)
        
        
        //bottomDividerView.anchor(top: captionLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0 , paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        //leftDivider.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil,  paddingTop: 0 , paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 1.5, height: 0 )
        //rightDivider.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor , paddingTop: 0 , paddingLeft: 0, paddingBottom: 0, paddingRight: -1.5, width: 1.5, height: 0 )
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

