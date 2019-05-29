    //
    //
    //  Created by Murray Toews on 6/3/17.
    //  Copyright © 2017 maple.com

    import UIKit
    import Firebase
    import MaterialComponents

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
    
    var post: Post? {
        didSet {
            images = []
            bookmarkButton.setImage(post?.hasBookmark == true ? #imageLiteral(resourceName: "bookmarkFilled").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "bookmark").withRenderingMode(.alwaysOriginal), for: .normal)
            if post?.hasLiked == true {
                print ("Post liked \(String(describing: post?.hasLiked))")
                likeButton.setImage(#imageLiteral(resourceName: "Heart_Selected").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            else {
                print ("Post unliked \(String(describing: post?.hasLiked))")
                likeButton.setImage(#imageLiteral(resourceName: "Heart_Unselected").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            
            usernameLabel.text = "TEST USERNAME"
            usernameLabel.text = (post?.user.username)! + " : " + (post?.caption)!
            guard let profileImageUrl = post?.user.profileImageUrl else { return }
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
            //getNumberOfLikes(likes: (post?.noOfLikes)!)
            //getNumberOfComments(likes: (post?.noOfComments)!)
            //getNumberOfBookmarks(likes: (post?.noOfBookMarks)!)
            setupAttributedCaption()
            self.imageCollectionView.reloadData()
        }
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
        
        
        fileprivate func setupAttributedCaption() {
            guard let post = self.post else { return }
            
            let attributedText = NSMutableAttributedString(string: "\(post.caption)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)])
            attributedText.append(NSAttributedString(string:   "\n\(post.description)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
            attributedText.append(NSAttributedString(string:   "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 4)]))
            
            let timeAgoDisplay = post.creationDate.timeAgoToDisplay()
            attributedText.append(NSAttributedString(string: timeAgoDisplay, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.gray]))
            captionLabel.attributedText = attributedText
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
        
        
        let captionLabel: UILabel = {
            let label = UILabel()
            label.numberOfLines = 0
            return label
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



