    //
    //  UserProfileHeader.swift
    //  InstagramFirebase
    //
    //  Created by Murray Toews on 6/3/17.
    //  Copyright © 2017 maple.com
    
    import UIKit
    import Firebase
    import MaterialComponents
    
    protocol UserProfileHeaderDelegate {
        func didChangeToListView()
        func didChangeToGridView()
        func didMapViewOpen()
        func didFavoritesOpen()
        func didChangeSignUpFoto()
        func didOpenFollowersList()
        func didOpenFollowingList()
        func didOpenProductsList()
        func didEditPost()
        func didOpenSettings()
    }
    
    class UserProfileHeader: MDCCardCollectionCell {
        
        var delegate: UserProfileHeaderDelegate?
        var userId = "USERID"
        var userPhotoURL = "USER PHOTO URL"
        var bSet = false
        
        fileprivate func getNumberOfPosts() {
            if let postCount = userView?.postCount {
                self.postsLabel.attributedText = NSMutableAttributedString(string:     "Posts\t\t : \(postCount)" , attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
            }}
        
        fileprivate func getNumberOfFollowers()
        {
            // Followers
            if let followersCount = userView?.followersCount {
                self.followersLabel.attributedText = NSMutableAttributedString(string: "Followers\t : \(followersCount)" , attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
            }
        }
        
        
        fileprivate func getNumberOfFollowing()
        {
            // Following
            if let followingCount = userView?.followedCount {
                self.followingLabel.attributedText = NSMutableAttributedString(string: "Followed\t : \(followingCount)" , attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
            }
        }
        
        var userView: MapleUser? {
            didSet {
                if bSet == false {
                    guard let profileImageUrl = userView?.profileImageUrl else { return }
                    profileImageView.loadImage(urlString: profileImageUrl)
                    usernameLabel.text = userView?.username
                    if let uid = userView?.uid  {
                        userId = uid
                    }
                    setupEditFollowButton()
                    bSet = true
                }
            }
        }
        
        
        
        @objc func handleFollow(){
            print("User has not been followed yet, so follow")
            userIsFollowed()
             guard let uid = Auth.auth().currentUser?.uid else { return }
             if let userId = userView?.uid {
                if userId == uid {
                    return
                }
                Firestore.didFollowUser(uid: uid , uidFollow: userId, didFollow: true)
              
            }
            
        }
        
        @objc func handleFollowed() {
            print("User has been followed already so unfollow")
            userIsNotFollowed()
            guard let uid = Auth.auth().currentUser?.uid else { return }
            if let userId = userView?.uid {
                if uid == userId {
                    return
                }
                Firestore.didFollowUser(uid: uid , uidFollow: userId, didFollow: false)
            }
        }
        
        
        fileprivate func setupEditFollowButton() {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            if let userId = userView?.uid {
                if uid == userId {
                    self.editProfileFollowButton.isHidden = true
                    self.editProfileFollowedButton.isHidden = true
                } else {
//                    Firestore.isUserBeingFollowedByUser(userId: uid, userFollowing: userId , { (isFollowed) in
//                        if isFollowed.isEmpty {
//                        self.userIsFollowed()
//                    } else
//                        {
//                        self.userIsNotFollowed()
//                    }
//                })
                }
                getNumberOfFollowers()
                getNumberOfPosts()
                getNumberOfFollowing()
            }
        }
        
        func userIsFollowed()
        {
            self.editProfileFollowButton.isHidden = true
            self.editProfileFollowedButton.isHidden = false
            self.editProfileSetupButton.isHidden = true
        }
        
        func userIsNotFollowed() {
            
            self.editProfileFollowButton.isHidden = false
            self.editProfileFollowedButton.isHidden = true
            self.editProfileSetupButton.isHidden = true
        }
        
        func userIsThisUser()
        {
            self.editProfileFollowButton.isHidden = true
            self.editProfileFollowedButton.isHidden = true
            self.editProfileSetupButton.isHidden = false
        }
        
        let profileImageView: CustomImageView = {
            let iv = CustomImageView()
            return iv
        }()
        
        @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
        {
            //let tappedImage = tapGestureRecognizer.view as! UIImageVie
            delegate?.didChangeSignUpFoto()
        }
        
        
        @objc func followersTapped(tapGestureRecognizer: UITapGestureRecognizer)
        {
            delegate?.didOpenFollowersList()
        }
        
        @objc func followingTapped(tapGestureRecognizer: UITapGestureRecognizer)
        {
            delegate?.didOpenFollowingList()
        }
        @objc func productsTapped(tapGestureRecognizer: UITapGestureRecognizer)
        {
            //delegate?.didOpenProductsList()
        }
        
        lazy var editProfileFollowButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("FOLLOW\t", for: .normal)
            button.setImage(#imageLiteral(resourceName: "ic_favorite_border"), for: .normal )
            button.tintColor = UIColor.themeColor()
            button.backgroundColor = .white
            button.addTarget(self, action: #selector(handleFollow), for: .touchUpInside)
            return button
        }()
        
        lazy var editProfileFollowedButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("FOLLOWED\t", for: .normal)
            button.setImage(#imageLiteral(resourceName: "ic_favorite"), for: .normal )
            button.tintColor = UIColor.themeColor()
            button.backgroundColor = .white
            
            //button.tintColor = .white
            //button.backgroundColor = UIColor.themeColor()
            button.addTarget(self, action: #selector(handleFollowed), for: .touchUpInside)
            return button
        }()
        
        lazy var editProfileSetupButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Settings\t", for: .normal)
            button.setImage(#imageLiteral(resourceName: "ic_settings"), for: .normal )
            button.tintColor = UIColor.black
            button.backgroundColor = .white
            button.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
            return button
        }()
      
        @objc func handleSettings()
        {
            delegate?.didOpenSettings()
        }
        
        
        lazy var gridButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(#imageLiteral(resourceName: "ic_list_36pt"), for: .normal )
            button.backgroundColor = UIColor.collectionBackGround()
            button.addTarget(self, action: #selector(handleChangeToGridView), for: .touchUpInside)
            return button
        }()
        
        lazy var bookmarkButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(#imageLiteral(resourceName: "ic_bookmark"), for: .normal)
            button.backgroundColor = UIColor.collectionBackGround()
            button.addTarget(self, action: #selector(handleBookmarkButton), for: .touchUpInside)
            return button
        }()
        
        
        lazy var editButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(#imageLiteral(resourceName: "ic_edit"), for: .normal)
            button.backgroundColor = UIColor.collectionCell()
            button.addTarget(self, action: #selector(handleEditPost), for: .touchUpInside)
            return button
        }()
        
        
        lazy var mapButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(#imageLiteral(resourceName: "ic_place"), for: .normal)
            //MDCTextButtonThemer.applyScheme(buttonScheme, to: button)
            button.backgroundColor = UIColor.collectionBackGround()
            button.addTarget(self, action: #selector(handleOpenMapView), for: .touchUpInside)
            button.tintColor = buttonNotPressed()
            return button
        }()
        
        
        lazy var listButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(#imageLiteral(resourceName: "ic_grid_on"), for: .normal)
            button.backgroundColor = UIColor.collectionBackGround()
            button.tintColor = buttonNotPressed()
            button.addTarget(self, action: #selector(handleChangeToListView), for: .touchUpInside)
            return button
        }()
        
        //  Four buttons
        
        
        fileprivate func buttonNotPressed() -> UIColor {
            return UIColor.gray 
        }
        
        fileprivate func buttonPressed() -> UIColor {
            return UIColor.themeColor()
        }
        
        @objc func handleChangeToGridView() {
            print("Changing to list view")
            listButton.tintColor = buttonNotPressed()
            gridButton.tintColor = buttonPressed()
            mapButton.tintColor = buttonNotPressed()
            bookmarkButton.tintColor = buttonNotPressed()
            delegate?.didChangeToGridView()
        }
        
        @objc func handleChangeToListView() {
            print("Changing to list view")
            listButton.tintColor = buttonPressed()
            mapButton.tintColor = buttonNotPressed()
            bookmarkButton.tintColor = buttonNotPressed()
            gridButton.tintColor = buttonNotPressed()
            delegate?.didChangeToListView()
        }
        
        @objc func handleOpenMapView()
        {
            print("Open the map view")
            gridButton.tintColor = buttonNotPressed()
            listButton.tintColor = buttonNotPressed()
            bookmarkButton.tintColor = buttonNotPressed()
            mapButton.tintColor = buttonPressed()
            delegate?.didMapViewOpen()
        }
        
        @objc func handleBookmarkButton()
        {
            print("Open the favorites controller")
            gridButton.tintColor = buttonNotPressed()
            listButton.tintColor = buttonNotPressed()
            mapButton.tintColor = buttonNotPressed()
            bookmarkButton.tintColor = buttonPressed()
            delegate?.didFavoritesOpen()
        }
        
        @objc func handleEditPost()
        {
            print("Open the favorites controller")
            delegate?.didEditPost()
        }
        
        let usernameLabel: UILabel = {
            let label = UILabel()
            label.text = "username"
            label.font = UIFont.boldSystemFont(ofSize: 24)
            return label
        }()
        
        let postsLabel: UILabel = {
            let label = UILabel()
            var strPosts =  "0\n"
            let attributedText = NSMutableAttributedString(string: "Posts : \(strPosts)" , attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
            label.attributedText = attributedText
            label.textAlignment = .left
            label.numberOfLines = 0
            return label
        }()
        
        // Return number of posts from : getNumberOfPosts()
        
        let followersLabel: UILabel = {
            let label = UILabel()
            let attributedText = NSMutableAttributedString(string: "Followers : 0", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
            label.attributedText = attributedText
            
            label.textAlignment = .left
            label.numberOfLines = 0
            return label
        }()
        
        let followingLabel: UILabel  = {
            let label  = UILabel()
            let attributedText = NSMutableAttributedString(string: "Following : 0", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
            label.attributedText = attributedText
            label.numberOfLines = 0
            label.textAlignment = .left
            return label
        }()
        
        
       
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            let Width : CGFloat  = 80
            addSubview(usernameLabel)
            addSubview(profileImageView)
            addSubview(editProfileFollowButton)
            addSubview(editProfileFollowedButton)
            addSubview(editProfileSetupButton)
            
            usernameLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil , right: rightAnchor, paddingTop: 15, paddingLeft: 10 , paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
            profileImageView.anchor(top: usernameLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 10 , paddingBottom: 0, paddingRight: 0, width: Width, height: Width)
            profileImageView.layer.cornerRadius = Width / 2
            profileImageView.clipsToBounds = true
            
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            //Add the recognizer to your view.
            profileImageView.isUserInteractionEnabled = true
            profileImageView.addGestureRecognizer(tapRecognizer)
            
            setupFavoriteButtons()
            setupBottomToolbar()
            setupUserStatsView()
        }
        
        fileprivate func setupFavoriteButtons()
        {
            //let stackView = UIStackView(arrangedSubviews: [editProfileSetupButton, editProfileFollowButton, editProfileFollowedButton])
            
//            stackView.axis = .vertical;
//            stackView.distribution = .equalSpacing;
//            stackView.alignment = .leading;
//            stackView.spacing = 10;
            
            self.addSubview(editProfileSetupButton)
            self.addSubview(editProfileFollowButton)
            self.addSubview(editProfileFollowedButton)
            
            editProfileSetupButton.anchor(top: usernameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 170, paddingBottom: 0, paddingRight: 0, width: 120, height: 0)
            editProfileFollowButton.anchor(top: usernameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 170, paddingBottom: 0, paddingRight: 0, width: 120, height: 0)
            editProfileFollowedButton.anchor(top: usernameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 170, paddingBottom: 0, paddingRight: 0, width: 120, height: 0)
            
            
        }
        
        fileprivate func setupUserStatsView() {
            
            let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
            
            stackView.axis = .vertical;
            stackView.distribution = .equalSpacing;
            stackView.alignment = .leading;
            stackView.spacing = 10;
        
            addSubview(stackView)
            stackView.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: profileImageView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 120, height: 0)
            
            let tapFollowers = UITapGestureRecognizer(target: self, action: #selector(followersTapped(tapGestureRecognizer: )))
            followersLabel.isUserInteractionEnabled = true
            followersLabel.addGestureRecognizer(tapFollowers)
            
            let tapFollowing = UITapGestureRecognizer(target: self, action: #selector(followingTapped(tapGestureRecognizer: )))
            followingLabel.isUserInteractionEnabled = true
            followingLabel.addGestureRecognizer(tapFollowing)
            
//            let tapProducts = UITapGestureRecognizer(target: self, action: #selector(productsTapped(tapGestureRecognizer: )))
//            postsLabel.isUserInteractionEnabled = true
//            postsLabel.addGestureRecognizer(tapProducts)
            
        }
        
        fileprivate func setupBottomToolbar() {
            
            let topDividerView = UIView()
            topDividerView.backgroundColor = UIColor.darkGray
            
            let bottomDividerView = UIView()
            bottomDividerView.backgroundColor = UIColor.lightGray
            
            let stackView = UIStackView(arrangedSubviews: [gridButton,listButton, mapButton , bookmarkButton])
            
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            
            addSubview(stackView)
            addSubview(topDividerView)
            addSubview(bottomDividerView)
            
            stackView.anchor(top: nil, left: leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0,
                                paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 50)
            
            topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor,
                                paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
            
            bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor,
                                paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
            
            handleChangeToGridView()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    
    
  
