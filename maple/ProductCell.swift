//
//  ProductCell.swift
//  maple
//
//  Created by Murray Toews on 2018/05/23.
//  Copyright © 2018 Murray Toews. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import BadgeSwift
import MaterialComponents

protocol ProductCellDelegate {
    func didTapComment(post: FSPost)
    func didLike(for cell: ProductCell)
    func didTapModify(post: FSPost)
    func didTapBookmark(for cell : ProductCell)
    func didTapImage(for cell : PostImage, post: FSPost)
    func didSharePost(post: FSPost, imageObject: ImageObject)
    func didTapUserNameLabel(uid: String)
    func didTapImageCell(for cell:  UserImageCell, post: FSPost)
}

protocol ProductHeaderCardDelegate {
    func didShowTopUsers()
    func didShowFollowersPosts()
    
}


class ProductHeaderCard: BaseCell
{
    var  imageObject: ImageObject?  {
        didSet {
            if let imageUrl = imageObject {
                postImageView.loadImage(urlString: imageUrl.url)
            }
        }
    }
    
    
    var delegate: ProductHeaderCardDelegate?
    
    var postImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        return iv
    }()
    
    
    var postTitle : UILabel = {
       let ui = UILabel()
        ui.text = "title of the products"
        return ui
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(postImageView)
        addSubview(postTitle)
        postTitle.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
        postImageView.anchor(top: postTitle.bottomAnchor , left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 200)
        backgroundColor = UIColor.collectionCell()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? UIColor.gray : UIColor.clear
        }
    }
    
}

class ProductCell: MDCCardCollectionCell , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    
    var horizontalCellId = "horizontalCellId"
    var delegate: ProductCellDelegate?
    var images = [ImageObject]()
    
    public var imageConstraint: NSLayoutConstraint?
    public var imageWidthContraint: NSLayoutConstraint?
    
    let attributeTitle = [NSAttributedStringKey.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .title)]
    let attributeCaption = [NSAttributedStringKey.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .body2 )]
    let attributeSubline = [NSAttributedStringKey.font: UIFont.mdc_preferredFont(forMaterialTextStyle:  .subheadline )]
    
    
    override func updateConstraints() {
        super.updateConstraints()
        
        let constant = MDCCeil((self.bounds.width - 2) * 0.65)
        let widthConstant = MDCCeil((self.bounds.width - 2) * 0.9)
        if imageConstraint == nil {
            imageConstraint = imageCollectionView.heightAnchor.constraint(equalToConstant: constant)
            imageConstraint?.isActive = true
        }
        if imageWidthContraint == nil {
            imageWidthContraint = imageCollectionView.widthAnchor.constraint(equalToConstant: widthConstant)
            imageWidthContraint?.isActive = true
        }
        imageConstraint?.constant = constant
        imageWidthContraint?.constant = widthConstant
    }

    var post: FSPost? {
        didSet {
            if post == nil
            {
                return
            }
            images = []
            
            bookmarkButton.setImage(post?.hasBookmark == true ? #imageLiteral(resourceName: "bookmarkFilled").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "bookmark").withRenderingMode(.alwaysOriginal), for: .normal)
            
            if let postId = post?.id {
                if let uid = post?.uid {
                    print ("Post id: " + postId + " :Uid " + uid )
//                    Firestore.IsPostLiked(postId,uid, completion: { (isLiked) in
//                        if isLiked == 1 {
//                            self.likeButton.setImage(#imageLiteral(resourceName: "like_selected-1").withRenderingMode(.alwaysOriginal), for: .normal)
//                        }
//                        else{
//                            self.likeButton.setImage(#imageLiteral(resourceName: "Heart_Unselected-1").withRenderingMode(.alwaysOriginal), for: .normal)
//                        }
//                        
//                    })
                }
            }
            
            self.hideLikesBadge(0)
            self.hideMarkBadge(0)
            self.hideCommentBadge(0)
            
            usernameLabel.text = "TEST USERNAME"
            if let user = post?.userName {
                if let caption = post?.product {
                    usernameLabel.attributedText = setUserName(userName: user, caption: caption)
                }
                
            }
            guard let profileImageUrl = post?.profileURL else { return }
            userProfileImageView.loadImage(urlString: profileImageUrl)
            
            if let count = post?.imageUrlArray.count {
                if count > 0 {
                    for url in (post?.imageUrlArray)! {
                        print(url)
                        let obj = ImageObject(postid: (post?.id)!, imageid: "" , url: url)
                        images.append(obj)
                    }
                }
            }
            
            //MARK: Fetch
            /*
            if let postId = post?.id {
                Firestore.fetchNumberOfLikesByPostId(postid: postId, { (totalLikes) in
                    self.putNumberOfLikes(likes: totalLikes )
                })
            }
            
            if let postId = post?.id {
                Firestore.fetchPostNumberOfComments(postid: postId, { (totalComments) in
                    self.putNumberOfComments(likes: totalComments)
                })
            }
            
            if let postId = post?.id {
                Firestore.fetchPostNumberofBookmarks(postid: postId, { (totalBookmarks) in
                    self.putNumberOfBookmarks(likes: totalBookmarks)
                })
            }
            */
            
            setupAttributedCaption()
            
            self.imageCollectionView.reloadData()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: horizontalCellId, for: indexPath) as! PostImage
        cell.imageObject = images[indexPath.item]
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: horizontalCellId, for: indexPath) as! PostImage
        delegate?.didTapImage(for: cell, post: post!)
    }
    
    
    
    fileprivate func setCaption(caption: String) -> NSMutableAttributedString
    {
        var attributedText: NSMutableAttributedString?
        //        let systemDynamicFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyle.body)
        //        let size = systemDynamicFontDescriptor.pointSize
        //        let font = UIFont(name: "Arial", size: size)
        attributedText = NSMutableAttributedString(string: caption , attributes: attributeCaption)
        return attributedText!
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
    
    
    
    fileprivate func getNumberOfLikes(postid: String)
    {
        print("Get the number of likes \(postid)")
        var attributedText: NSMutableAttributedString?
        attributedText = NSMutableAttributedString(string: "" , attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 8)])
        Database.database().reference().child("likes").child(postid).child("likes").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                let iLikes = value.count
                let sLikes = "\(iLikes)"
                attributedText = NSMutableAttributedString(string: sLikes , attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 8)])
                if (iLikes > 0) {
                    self.likeBadge.attributedText = attributedText
                    self.likeBadge.isHidden = false
                } else { self.likeBadge.isHidden = true }
            }
        }, withCancel: { (err) in
            print("Failed to check if following:", err)
        })
        return
    }
    
    fileprivate func getNumberOfComments(postid: String)
    {
        print("Get the number of comments...\(postid)")
        var attributedText: NSMutableAttributedString?
        attributedText = NSMutableAttributedString(string: "" , attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 8)])
        Database.database().reference().child("comments").child(postid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                let iLikes = value.count
                let sLikes = "\(iLikes)"
                
                attributedText = NSMutableAttributedString(string: sLikes , attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 8)])
                if (iLikes > 0) {
                    self.commentBadge.attributedText = attributedText
                    self.commentBadge.isHidden = false
                }
                else {
                    self.commentBadge.isHidden = true
                }
            }
        }, withCancel: { (err) in
            print("Failed to check if following:", err)
        })
        return
    }
    
    
    
    
    fileprivate func getNumberOfBookMarks(postid: String)
    {
        print("Get the number of bookmarks...")
        var attributedText: NSMutableAttributedString?
        guard let uid = Auth.auth().currentUser?.uid else { return }
        attributedText = NSMutableAttributedString(string: "" , attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 8)])
        Database.database().reference().child("bookmarks").child(uid).child(postid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                let sCount = "\(value.count)"
                attributedText = NSMutableAttributedString(string: sCount , attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 8)])
                self.bookMarkBadge.attributedText = attributedText
                if (value.count > 0 ) {
                    self.bookMarkBadge.isHidden = false
                }
                else {
                    self.bookMarkBadge.isHidden = true
                }
            }
        }, withCancel: { (err) in
            print("Failed to check if following:", err)
        })
        return
    }
    
    
    
    fileprivate func setupAttributedCaption() {
        guard let post = self.post else { return }
        let attributedText = NSMutableAttributedString(string: post.description, attributes: attributeCaption)
        captionLabel.attributedText = attributedText
        let timeAgoDisplay = post.creationDate.timeAgoDisplay()
        let timeAttributedText = NSMutableAttributedString(string: timeAgoDisplay, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 8)])
        timeAgoLabel.attributedText = timeAttributedText
        print (timeAgoLabel.text!)
    }
    
    
    let userProfileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleToFill
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
    
    let usernameLabel: UITextField = {
        let label = UITextField()
        label.text = "Username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        //label.numberOfLines = 0
        return label
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "Heart_Unselected-1").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    @objc func handleLike() {
        delegate?.didLike(for: self)
    }
    
    lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "Share").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleShare), for: .touchUpInside)
        return button
    }()
    
    @objc func handleShare()
    {
        print("Share")
        delegate?.didSharePost(post: post!, imageObject: images[0])
    }
    
    lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "comment1").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
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
        badge.borderColor = UIColor.themeColor()
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
        badge.borderColor = UIColor.themeColor()
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
        badge.borderColor = UIColor.themeColor()
        return badge
    }()
    
    
    //configureBadge(badge)
    //positionBadge(badge)
    
    @objc func handleComment() {
        print("Trying to show comments...")
        guard let post = post else { return }
        delegate?.didTapComment(post: post)
    }
    
    lazy var bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        //button.setImage(#imageLiteral(resourceName: "bookmark").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleBookmark), for: .touchUpInside)
        return button
    }()
    
    
    lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "icons8-Edit Property-b_w").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleEditButton), for: .touchUpInside)
        return button
    }()
    
    @objc func handleBookmark() {
        print("Handle the bookmarks ...")
        delegate?.didTapBookmark(for: self)
    }
    
    @objc func handleEditButton() {
        delegate?.didTapModify(post: post!)
    }
    
    let imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.collectionCell()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    
    let captionLabel: UILabel = {
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
    
    @objc func usernameLabelTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        delegate?.didTapUserNameLabel(uid: post!.uid)
    }
    
    let timeAgoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.collectionCell()
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor.collectionCell()
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor.collectionCell()
        
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        
        let tapFollowers = UITapGestureRecognizer(target: self, action: #selector(usernameLabelTapped(tapGestureRecognizer: )))
        usernameLabel.isUserInteractionEnabled = true
        usernameLabel.addGestureRecognizer(tapFollowers)
        
        
        addSubview(userProfileImageView)
        addSubview(usernameLabel)
        addSubview(imageCollectionView)
        addSubview(shareButton)
        addSubview(likeButton)
        addSubview(timeAgoLabel)
        
        addSubview(commentButton)
        addSubview(bookmarkButton)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        addSubview(captionLabel)
        addSubview(likeBadge)
        addSubview(bookMarkBadge)
        addSubview(commentBadge)
        
        imageCollectionView.register(PostImage.self, forCellWithReuseIdentifier: horizontalCellId)
        
        
        userProfileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil,
                                    right: nil, paddingTop: 8, paddingLeft: 8,
                                    paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        
        userProfileImageView.layer.cornerRadius = 40 / 2
        
        usernameLabel.anchor(top: userProfileImageView.topAnchor, left: userProfileImageView.rightAnchor, bottom: nil,right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: frame.size.width - 100 , height: 40)
        shareButton.anchor(top: userProfileImageView.topAnchor, left: nil, bottom: nil,right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 35, height: 35)
        
        
        //usernameLabel.anchor(top: userProfileImageView.topAnchor, left: userProfileImageView.rightAnchor, bottom: nil,right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: frame.size.width - 100 , height: 40)
        shareButton.anchor(top: userProfileImageView.topAnchor, left: nil, bottom: nil,right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 35, height: 35)
        
        imageCollectionView.anchor(top: userProfileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: frame.width )
        topDividerView.anchor(top: imageCollectionView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor,paddingTop: 2 , paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 0, height: 0.5)
        likeButton.anchor(top: imageCollectionView.bottomAnchor , left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: -15 , width: 50, height: 40)
        commentButton.anchor(top: imageCollectionView.bottomAnchor, left: likeButton.rightAnchor, bottom: nil, right:nil , paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: -15 , width: 50, height: 40)
        bookmarkButton.anchor (top: imageCollectionView.bottomAnchor, left: commentButton.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: -15  , width: 50, height: 40)
        timeAgoLabel.anchor (top: imageCollectionView.bottomAnchor, left: bookmarkButton.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 150, paddingBottom: 0, paddingRight: 0 , width: 0, height: 20)
        
        commentBadge.anchor(top: topDividerView.topAnchor, left: commentButton.rightAnchor, bottom: nil, right: nil, paddingTop: 2, paddingLeft: -20, paddingBottom: 0, paddingRight: 0 , width: 0, height: 0)
        likeBadge.anchor(top: topDividerView.topAnchor, left: likeButton.rightAnchor, bottom: nil, right: nil, paddingTop: 2, paddingLeft: -20, paddingBottom: 0, paddingRight: 0 , width: 0, height: 0)
        bookMarkBadge.anchor(top: topDividerView.topAnchor, left: bookmarkButton.rightAnchor, bottom: nil, right: nil, paddingTop: 2, paddingLeft: -22, paddingBottom: 0, paddingRight: 0 , width: 0, height: 0)
        
        captionLabel.anchor(top: likeButton.bottomAnchor    , left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        bottomDividerView.anchor(top: captionLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor,paddingTop: 5 , paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 0, height: 0.5)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


//            Database.fetchImageByPost( uid: (post?.user.uid)!, postId: (post?.id)!) { (urlImages)  in
//                for image in urlImages {
//                    let imageObj = ImageObject(postid: image.postid!, url: image.url)
//                    print(imageObj)
//                    self.horizontalCellImages.append(imageObj)
//                }
//
//            }
//            for urls in (post?.imageUrlArray)! {
//                let imageObj = ImageObject(postid: (post?.id)!, url: urls)
//                self.horizontalCellImages.append(imageObj)
//            }


