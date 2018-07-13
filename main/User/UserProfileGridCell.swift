//
//  HomePostCell.swift
//  InstagramFirebase
//
//  Created by Murray Toews on 6/3/17.
//  Copyright © 2017 maple.com

import UIKit
import Firebase
import MaterialComponents

protocol UserProfileDelegate {
    func didTapComment(post: Post)
    func didTapProduct(post: Post)
    func didLike(for cell: UserProfileGridCell)
    func didTapModify(post: Post)
    func didTapBookmark(for cell : UserProfileGridCell)
    func didTapCellProduct (post: Post)
}



class ScreenshotImageCell: MDCCardCollectionCell {
    
    var imageObject: ImageObject?  {
        didSet {
            guard let imageUrl = imageObject?.url else { return }
               photoImageView.loadImage(urlString: imageUrl)
        }
    }
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
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

class UserProfileGridCell: MDCCardCollectionCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var delegate: UserProfileDelegate?
    var cellImages = [UIImage]()
    let horizontalCell = "horizontalCell"
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = post?.imageUrlArray.count
        {
            if count > 0 {
                return count
            }
        }
        return  0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 8, 8, 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item <=  (post?.imageUrlArray.count)! {
            post?.imageUrl = (post?.imageUrlArray[indexPath.item])!
            delegate?.didTapProduct(post: post!)
        }
    }
    
    let iv: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = false
        return iv
    }()
    
    /*
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! AppCell
     cell.app = appCategory?.apps?[indexPath.item]
     return cell
     }
     */
    
    
    private func fetchImagesByUid(uid: String)
    {
        Database.database().reference().child("imagebypost").child(uid).observeSingleEvent(of: .value, with: {
            (snapshot) in
            guard let data = snapshot.value as? [String: Any] else { return }
            data.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else { return }
                dictionary.forEach({ (key,value) in
                    guard let urldata = value as? [String: Any] else { return }
                    let urlstring = urldata["url"] as! String
                    if urlstring.count > 0 {
                        print(urlstring)
                    }
                })
                
            })
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellA = collectionView.dequeueReusableCell(withReuseIdentifier: horizontalCell, for: indexPath)as! ScreenshotImageCell
        if let count = post?.imageUrlArray.count
        {
            if count > 0 {
                let obj = ImageObject(postid: (post?.id)!, imageid: "" , url: (post?.imageUrlArray[indexPath.item])! )
                cellA.imageObject = obj
            }
        }
        
        return cellA
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = frame.width / 2
        return CGSize(width: width, height: width)
    }
    
    var imageObject =  [ImageObject]()
    
    var post: Post? {
        didSet {
            imageObject = []
            
            likeButton.setImage(post?.hasLiked == true ? #imageLiteral(resourceName: "Heart_Selected").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "Heart_Unselected").withRenderingMode(.alwaysOriginal), for: .normal)
            bookmarkButton.setImage(post?.hasBookmark == true ? #imageLiteral(resourceName: "bookmarkFilled").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "bookmark").withRenderingMode(.alwaysOriginal), for: .normal)
            
            usernameLabel.text = post?.user.username
            
            if let count  = post?.imageUrlArray.count {
                if count > 0 {
                    for url in (post?.imageUrlArray)! {
                        let obj = ImageObject(postid: (post?.id)!, imageid: "" , url: url )
                        imageObject.append(obj)
                    }
                }
            }
            setupAttributedCaption()
            guard let profileImageUrl = post?.user.profileImageUrl else { return }
            userProfileImageView.loadImage(urlString: profileImageUrl)
            self.imageCollectionView.reloadData()
        }
    }
    
    /*
     ref.child("rooms").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
     
     if snapshot.hasChild("room1"){
     
     print("true rooms exist")
     
     }else{
     
     print("false room doesn't exist")
     }
     
     
     })
     */
    
//    private func loadImages(_ postid: String, _ imageObject: inout [ImageObject] ) {
//        let ref = Database.database().reference()
//        ref.child("imagesbypost").child(postid).observeSingleEvent(of: .value, with: { (snapshot) in
//            let data = snapshot.value as? NSDictionary
//            data?.forEach({ (key, value) in
//                guard let urlData = value as? [String: Any] else { return }
//                let urlstring = urlData["imageUrl"] as! String
//                let imgObject = ImageObject()
//                imgObject.postid = postid
//                imgObject.url = urlstring
//                imageObject.append(imgObject)
//            })
//        }){(error) in
//            print(error.localizedDescription)
//        }
//    }
    
    fileprivate func setupAttributedCaption() {
        guard let post = self.post else { return }
        
        let attributedText = NSMutableAttributedString(string: "商品名:\t\(post.caption)", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string:   "\n\(post.description)", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)]))
        //attributedText.append(NSAttributedString(string:   "\n購入場所:\t\(post.location)", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)]))
        //attributedText.append(NSAttributedString(string:   "\n種類:\t\(post.category)", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)]))
        attributedText.append(NSAttributedString(string:   "\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 4)]))
        
        let timeAgoDisplay = post.creationDate.timeAgoDisplay()
        attributedText.append(NSAttributedString(string: timeAgoDisplay, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12), NSAttributedStringKey.foregroundColor: UIColor.gray]))
        captionLabel.attributedText = attributedText
    }
    
    fileprivate func setupActionButtons() {
        addSubview(userProfileImageView)
        addSubview(usernameLabel)
        addSubview(imageCollectionView)
        addSubview(productButton)
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        
        
        userProfileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        userProfileImageView.layer.cornerRadius = 40 / 2
        
        usernameLabel.anchor(top: topAnchor, left: userProfileImageView.rightAnchor, bottom: userProfileImageView.topAnchor, right: nil, paddingTop: 16, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 200, height: 40)
        
        
        imageCollectionView.anchor(top: userProfileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 200)
        
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, bookmarkButton])
        
        stackView.distribution = .fillProportionally
        addSubview(stackView)
        stackView.anchor(top: imageCollectionView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0 , width: 0, height: 40)
        
        
        let stackView2 = UIStackView(arrangedSubviews: [productButtonSmall,captionLabel])
        stackView2.distribution = .fillProportionally
        addSubview(stackView2)
        stackView2.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 20 , width: 0, height: 40)
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        addSubview(separatorView)
        separatorView.anchor(top: nil, left: stackView2.leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    
    let userProfileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    
    let imageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        //iv.contentMode = .sc
        iv.clipsToBounds = true
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    /*
     func handleOptions() {
     print("Handling options ...")
     delegate?.didOptions(for: self)
     }
     */
    
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
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5 )
        return button
    }()
    
    @objc func handleComment() {
        print("Trying to show comments...")
        guard let post = post else { return }
        delegate?.didTapComment(post: post)
    }
    
    lazy var bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "bookmark").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleBookmark), for: .touchUpInside)
        return button
    }()
    
    lazy var productButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "icons8-Buying-50").withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        
        //button.setTitle("Text", for: .focused)
        button.addTarget(self, action: #selector(handleTapProduct), for: .touchUpInside)
        return button
    }()
    
    lazy var productButtonSmall: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "Instagram_logo_white").withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        //button.isSpringLoaded = true
        //button.setTitle("Text", for: .focused)
        button.addTarget(self, action: #selector(handleTapProduct), for: .touchUpInside)
        return button
    }()
    
    
    @objc func handleTapProduct()
    {
        if let count = post?.imageUrlArray.count  {
            if count > 0 {
                post?.imageUrl = (post?.imageUrlArray[0])!
                delegate?.didTapProduct(post: post!)
            }
        }
    }
    
    @objc func handleBookmark() {
        print("Handle the bookmarks ...")
        
        bookmarkButton.setImage(post?.hasBookmark == true ? #imageLiteral(resourceName: "bookmarkFilled").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "bookmark").withRenderingMode(.alwaysOriginal), for: .normal)
        
        delegate?.didTapBookmark(for: self)
    }
    
    
    let captionLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.isEnabled = false
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
    
    let imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cellWidth : CGFloat = 200
        let cellheight : CGFloat = 200
        let cellSize = CGSize(width: cellWidth , height:cellheight)
        layout.scrollDirection = .horizontal
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.minimumLineSpacing = 1.0
        layout.minimumInteritemSpacing = 4.0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.clear
        cv.setCollectionViewLayout(layout, animated: true)
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        setupActionButtons()
        imageCollectionView.register(ScreenshotImageCell.self, forCellWithReuseIdentifier: horizontalCell)
        
        
        //addSubview(captionLabel)
        //captionLabel.anchor(top: likeButton.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        //photoImageView.anchor(top: userProfileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 300)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




