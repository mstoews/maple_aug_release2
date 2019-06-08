    //
    //
    //  Created by Murray Toews on 6/3/17.
    //  Copyright © 2017 maple.com

    import UIKit
    import Firebase
    import MaterialComponents
    import ActiveLabel
    import BadgeSwift

    fileprivate class PostImageCell: BaseCell
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
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            return iv
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(photoImageView)
            photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor )
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


    class UserCategoryCell: BaseCell
    {
        var  categoryButtonCount: Int?  {
            didSet {
                let cnt = categoryButtonCount!
                for _ in 0...cnt {
                    categoryButtons.append(categoryButton)
                }
            }
        }
        
        let categoryButton : UIButton = {
            var cb = UIButton()
            return cb
        }()
        
        
        var categoryButtons = [UIButton]()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
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
  
   class UserGridCell: MDCCardCollectionCell , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    var postImagesCellId = "postImagesCellId"
    var images = [ImageObject]()
    
//    var post: Post? {
//        didSet {
//            images = []
//            bookmarkButton.setImage(post?.hasBookmark == true ? #imageLiteral(resourceName: "bookmarkFilled").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "bookmark").withRenderingMode(.alwaysOriginal), for: .normal)
//            if post?.hasLiked == true {
//                print ("Post liked \(String(describing: post?.hasLiked))")
//                likeButton.setImage(#imageLiteral(resourceName: "Heart_Selected").withRenderingMode(.alwaysOriginal), for: .normal)
//            }
//            else {
//                print ("Post unliked \(String(describing: post?.hasLiked))")
//                likeButton.setImage(#imageLiteral(resourceName: "Heart_Unselected").withRenderingMode(.alwaysOriginal), for: .normal)
//            }
//
//            usernameLabel.text = "TEST USERNAME"
//            usernameLabel.text = (post?.user.username)! + " : " + (post?.caption)!
//            guard let profileImageUrl = post?.user.profileImageUrl else { return }
//            userProfileImageView.loadImage(urlString: profileImageUrl)
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
//            //getNumberOfLikes(likes: (post?.noOfLikes)!)
//            //getNumberOfComments(likes: (post?.noOfComments)!)
//            //getNumberOfBookmarks(likes: (post?.noOfBookMarks)!)
//            setupAttributedCaption()
//            self.imageCollectionView.reloadData()
//        }
//    }
    
    public var imageConstraint: NSLayoutConstraint?
    public var imageWidthContraint: NSLayoutConstraint?
    
    let attributeTitle = [NSAttributedString.Key.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .title)]
    let attributeCaption = [NSAttributedString.Key.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .body2 )]
    let attributeSubline = [NSAttributedString.Key.font: UIFont.mdc_preferredFont(forMaterialTextStyle:  .subheadline )]

    var uid : String?
    
    var post: FSPost? {
        
        didSet {
            if post == nil
            {
                return
            }
            images = []
            
            self.setButtonImage(button: self.likeButton, btnName: "ic_favorite_border", color: UIColor.red)
            self.uid = post?.uid
            
            isLikedByUid(uid: self.uid!, postId: self.post!.id!) { (isLiked) in
                if isLiked == true {
                    self.setButtonImage(button: self.likeButton, btnName: "ic_favorite", color: UIColor.red)
                }
                else{
                    self.setButtonImage(button: self.likeButton, btnName: "ic_favorite_border", color: UIColor.red)
                }
            }
            
            
            isBookMarkedByUid(uid: self.uid!, postId: self.post!.id!) { (isBookmarked) in
                if isBookmarked == true {
                    self.setButtonImage(button: self.bookmarkButton, btnName: "ic_bookmark", color: UIColor.orange)
                }
                else
                {
                    self.setButtonImage(button: self.bookmarkButton, btnName: "ic_bookmark_border", color: UIColor.orange)
                }
            }
            
            self.hideLikesBadge(0)
            self.hideMarkBadge(0)
            self.hideCommentBadge(0)
            
            usernameLabel.text = "TEST USERNAME"
            if let userName = post?.userName {
                //if let product = fs_post?.product {
                usernameLabel.attributedText = setUserName(userName: userName, caption: "")
                //}
                
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
            
            if let likeCount = post?.likeCount {
                self.putNumberOfLikes(likes: likeCount)
            }
            
            if let commentCount = post?.commentCount {
                self.putNumberOfComments(likes: commentCount)
            }
            
            
            if let timeAgoDisplay = post?.creationDate.timeAgoToDisplay() {
                let timeAttributedText = NSMutableAttributedString(string: timeAgoDisplay, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)])
                timeAgoLabel.attributedText = timeAttributedText
            }
            
            configurePostCaption()
            
            self.imageCollectionView.reloadData()
        }
        
    }
    
    let timeAgoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    
    lazy var commentBadge : BadgeSwift = {
        let badge = BadgeSwift()
        badge.text = ""
        badge.insets = CGSize(width: 2, height: 2)
        badge.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
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
        badge.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
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
        badge.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
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
    
    
    fileprivate func setUserName(userName: String, caption: String) -> NSMutableAttributedString
    {
        var attributedText: NSMutableAttributedString?
        attributedText = NSMutableAttributedString(string: "" , attributes: attributeCaption)
        attributedText?.append(NSMutableAttributedString(string: userName , attributes:attributeCaption))
        attributedText?.append(NSMutableAttributedString(string: "" , attributes: attributeCaption))
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
        attributedText = NSMutableAttributedString(string: sLikes , attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 8)])
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
        attributedText = NSMutableAttributedString(string: sLikes , attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 8)])
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
        attributedText = NSMutableAttributedString(string: sLikes , attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 8)])
        self.bookMarkBadge.attributedText = attributedText
        hideMarkBadge(likes)
    }
    
    
    
    let captionLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.numberOfLines = 3
        return label
    }()
    
    func configurePostCaption() {
        guard let post = self.post else { return }
        guard let caption = self.post?.description else { return }
        guard let product = self.post?.product else { return }
        guard let username = self.post?.userName else { return }
        
        // look for username as pattern
        let customType = ActiveType.custom(pattern: "^\(username)\\b")
        
        // enable username as custom type
        captionLabel.enabledTypes = [.mention, .hashtag, .url, customType]
        
        // configure usnerame link attributes
        captionLabel.configureLinkAttribute = { (type, attributes, isSelected) in
            var atts = attributes
            
            switch type {
            case .custom:
                atts[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 12)
            default: ()
            }
            return atts
        }
    }
        
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
        
        
        // MARK: - Is Liked
        fileprivate func isLikedByUid(uid: String, postId: String, completion: @escaping (Bool)->() ) {
            Firestore.isPostLikeByUser(postId: postId, uid: uid,  { (isLiked) in
                completion(isLiked)
            })
        }
        
        // MARK: - Is Bookmarked
        fileprivate func isBookMarkedByUid(uid: String, postId: String, completion: @escaping (Bool)->() ){
            Firestore.isPostBookMarkedByUser(postId: postId, uid: uid,  { (isBookmarked) in
                completion(isBookmarked)
            })
        }
        
        
        func setButtonImage(button: UIButton, btnName: String,  color: UIColor)
        {
            let origImage = UIImage(named: btnName);
            let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            button.setImage(tintedImage, for: .normal)
            button.tintColor = color
        }
    
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return images.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postImagesCellId, for: indexPath) as! PostImageCell
            cell.imageObject = images[indexPath.item]
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 200, height: 200)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let cell : UICollectionViewCell = collectionView.cellForItem(at: indexPath as IndexPath)!
            cell.backgroundColor = UIColor.magenta
        }
        
        
//        fileprivate func setupAttributedCaption() {
//            guard let post = self.post else { return }
//            
//            let attributedText = NSMutableAttributedString(string: "\(post.caption)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)])
//            attributedText.append(NSAttributedString(string:   "\n\(post.description)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
//            attributedText.append(NSAttributedString(string:   "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 4)]))
//            
//            let timeAgoDisplay = post.creationDate.timeAgoToDisplay()
//            attributedText.append(NSAttributedString(string: timeAgoDisplay, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.gray]))
//            captionLabel.attributedText = attributedText
//        }
//        
        
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
            label.font = UIFont.boldSystemFont(ofSize: 14)
            return label
        }()
        
        lazy var likeButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(#imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
            button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
            return button
        }()
        
        @objc func handleLike() {
            print("Handling like from within cell...")
            //delegate?.didLike(for: self)
        }
        
        lazy var commentButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(#imageLiteral(resourceName: "comment").withRenderingMode(.alwaysOriginal), for: .normal)
            button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
            return button
        }()
        
        @objc func handleComment() {
            print("Trying to show comments...")
            guard post != nil else { return }
            //delegate?.didTapComment(post: post)
        }
        
        lazy var bookmarkButton: UIButton = {
            let button = UIButton(type: .system)
            //button.setImage(#imageLiteral(resourceName: "bookmark").withRenderingMode(.alwaysOriginal), for: .normal)
            button.addTarget(self, action: #selector(handleBookmark), for: .touchUpInside)
            return button
        }()
        
        
        
        @objc func handleBookmark() {
            print("Handle the bookmarks ...")
            bookmarkButton.setImage(post?.hasBookmark == true ? #imageLiteral(resourceName: "bookmarkFilled").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "bookmark").withRenderingMode(.alwaysOriginal), for: .normal)
            //delegate?.didTapBookmark(for: self)
        }
        
        
        
        let imageCollectionView: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.backgroundColor = UIColor(hue: 30/360, saturation: 2/100, brightness: 99/100, alpha: 0.8)
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            return collectionView
        }()
    
    
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            addSubview(imageCollectionView)
            imageCollectionView.dataSource = self
            imageCollectionView.delegate = self
            
            imageCollectionView.register(PostImageCell.self, forCellWithReuseIdentifier: postImagesCellId)
            
            imageCollectionView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor )
            //, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
            
            let topDividerView = UIView()
            topDividerView.backgroundColor = UIColor.lightGray
            
            let bottomDividerView = UIView()
            bottomDividerView.backgroundColor = UIColor.lightGray
            addSubview(topDividerView)
            addSubview(bottomDividerView)
            
            topDividerView.anchor(top: imageCollectionView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor,
                                  paddingTop: 2 , paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 0, height: 0.5)
            
            addSubview(captionLabel)
            
            
            bottomDividerView.anchor(top: captionLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor,
                                     paddingTop: 5 , paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 0, height: 0.5)
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            
            fatalError("init(coder:) has not been implemented")
        }
}



