//
//  HomePostCell.swift
//  InstagramFirebase
//
//  Created by Murray Toews on 6/3/17.
//  Copyright © 2017 maple.com

import UIKit
import Firebase
import FirebaseFirestore
import BadgeSwift
import MaterialComponents

protocol HomePostCellDelegate {
    func didTapComment(post: FSPost)
    func didLike(for cell: HomePostCell)
    func didTapModify(post: FSPost)
    func didTapBookmark(for cell : HomePostCell)
    func didTapImage(for cell : PostImage, post: FSPost)
    func didSharePost(post: FSPost, imageObject: ImageObject)
    func didTapUserNameLabel(uid: String)
    func didTapImageCell(for cell:  UserImageCell, post: FSPost)
}

class PostImage: BaseCell
{
    var  imageObject: ImageObject?  {
        didSet {
            if let imageUrl = imageObject {
                photoImageView.loadImage(urlString: imageUrl.url)
            }
        }
    }
    
    var photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleToFill
        iv.backgroundColor = UIColor.white
        iv.clipsToBounds = true
        return iv
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
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



class HomePostCell: MDCCardCollectionCell , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    
    var horizontalCellId = "horizontalCellId"
    var delegate: HomePostCellDelegate?
    var images = [ImageObject]()
    var uid : String?
    
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
    
    
    deinit {
        postCountListener?.remove()
    }
    
    private var postCountListener: ListenerRegistration?
    
    fileprivate func observeQuery()
    {
        stopObserving()
        
        self.postCountListener = Firestore.firestore().collection("posts")
            .whereField("uid", isEqualTo: uid)
            .addSnapshotListener{  (snapshot, error) in
                guard let snapshot = snapshot else {
                    print("Error fetching snapshot results: \(error!)")
                    return
                }
                
                let models = snapshot.documents.map { (document) -> FSPost in
                    if let model = FSPost(dictionary: document.data(), postId: document.documentID) {
                        //Firestore.updateAlgoliaPost(post: model)
                        return model
                    }
                    else {
                        // Don't use fatalError here in a real app.
                        fatalError("Unable to initialize type \(FSPost.self) with dictionary \(document.data())")
                    }
                }
        }
    }
    
    
    fileprivate func stopObserving() {
        postCountListener?.remove()
    }
    
    
    var fs_post: FSPost? {
        
        didSet {
            if fs_post == nil
            {
                return
            }
            images = []
            
            self.likeButton.setImage(#imageLiteral(resourceName: "ic_favorite_border").withRenderingMode(.alwaysOriginal), for: .normal)
            self.uid = fs_post?.uid
            var isLikedByUid = false
            var isBookMarkedByUid = false
            
            if let postId = fs_post?.id {
                if let uid = fs_post?.uid {
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
                             self.bookmarkButton.setImage(isBookmarked == true ? #imageLiteral(resourceName: "ic_bookmark").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "ic_bookmark_border").withRenderingMode(.alwaysOriginal), for: .normal)
                             isBookMarkedByUid = isBookmarked
                    })
                    
                    
                }
            }
            
            fs_post?.isLiked = isLikedByUid
            fs_post?.isBookmarked = isBookMarkedByUid
            self.hideLikesBadge(0)
            self.hideMarkBadge(0)
            self.hideCommentBadge(0)
            
            usernameLabel.text = "TEST USERNAME"
            if let userName = fs_post?.userName {
                if let product = fs_post?.product {
                    usernameLabel.attributedText = setUserName(userName: userName, caption: product)
                }
                
            }
            
            if let profileURL = fs_post?.profileURL {
                    self.userProfileImageView.loadImage(urlString: profileURL)
            }
            
            
            if let postid = fs_post?.id {
                if let count = fs_post?.imageUrlArray.count {
                    if count > 0 {
                        for url in (fs_post?.imageUrlArray)! {
                            let obj = ImageObject(postid: postid, imageid: url , url: url)
                            images.append(obj)
                        }
                    }
                }
            }
            
            if let postId = fs_post?.id {
               Firestore.getPostCollectionCount(collection: "likes", postId: postId,  { (totalLikes) in
                    self.putNumberOfLikes(likes: totalLikes )
                })
            }
            
            if let postId = fs_post?.id {
                Firestore.getPostCollectionCount(collection: "comments", postId: postId,  { (commentCount) in
                    self.putNumberOfComments(likes: commentCount)
                })
            }
            
            if let postId = fs_post?.id {
               Firestore.getPostCollectionCount(collection: "bookmarked", postId: postId,  { (bookmarkCount) in
                    self.putNumberOfBookmarks(likes: bookmarkCount)
                })
            }
            
            if let description = fs_post?.description {
                let attributedText = NSMutableAttributedString(string: description, attributes: attributeCaption)
                captionLabel.attributedText = attributedText
            }
            
            if let timeAgoDisplay = fs_post?.creationDate.timeAgoDisplay() {
            let timeAttributedText = NSMutableAttributedString(string: timeAgoDisplay, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)])
                timeAgoLabel.attributedText = timeAttributedText
            }
            
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
        delegate?.didTapImage(for: cell, post: fs_post!)
    }
    
    
    fileprivate func setUserName(userName: String, caption: String) -> NSMutableAttributedString
    {
        var attributedText: NSMutableAttributedString?
        attributedText = NSMutableAttributedString(string: "" , attributes: attributeCaption)
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
        //button.setImage(#imageLiteral(resourceName: "Heart_Unselected-1").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    @objc func handleLike() {
        delegate?.didLike(for: self)
    }
    
    lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_share").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleShare), for: .touchUpInside)
        return button
    }()
    
    @objc func handleShare()
    {
        print("Share")
        delegate?.didSharePost(post: fs_post!, imageObject: images[0])
    }

   
    
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
    
    @objc func handleComment() {
        print("Trying to show comments...")
        guard let post = fs_post else { return }
        delegate?.didTapComment(post: post)
    }
    
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
    
    
    lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_edit").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleEditButton), for: .touchUpInside)
        return button
    }()
    
    @objc func handleBookmark() {
        print("Handle the bookmarks ...")
        delegate?.didTapBookmark(for: self)
    }

    @objc func handleEditButton() {
        delegate?.didTapModify(post: fs_post!)
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
    
    
    
    @objc func usernameLabelTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        delegate?.didTapUserNameLabel(uid: fs_post!.uid)
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
        addSubview(mapButton)
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
        mapButton.anchor (top: imageCollectionView.bottomAnchor, left: bookmarkButton.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: -15  , width: 50, height: 40)
        
        timeAgoLabel.anchor (top: imageCollectionView.bottomAnchor, left: bookmarkButton.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 120, paddingBottom: 0, paddingRight: 0 , width: 0, height: 20)
       
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


