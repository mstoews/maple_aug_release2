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
    }
    
    class UserProfileHeader: MDCCardCollectionCell {
        
        var delegate: UserProfileHeaderDelegate?
        var userId = "USERID"
        var userPhotoURL = "USER PHOTO URL"
        var bSet = false
        
        fileprivate func getNumberOfPostsWithId(userId: String) {
            print("Get the number of User posts...")
            //var iProducts = 0
            //var value: NSDictionary?

            Database.getNumberOfPosts(userId: userId, { (iProducts) in
                let strPosts = "\(iProducts)\n"
                let attributedText = NSMutableAttributedString(string: strPosts, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
                attributedText.append(NSAttributedString(string: "posts",
                        attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray,
                                     NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))

                self.postsLabel.attributedText = attributedText
            })
            return
        }
        
        fileprivate func getNumberOfFollowersWithId(userId: String)
        {
            // Followers
            Database.getNumberOfFollowers(userId: userId,  { (iFollowers) in
            let strPosts = "\(iFollowers)\n"
            let attributedText = NSMutableAttributedString(string: strPosts , attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "followers",
                                                     attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
            self.followersLabel.attributedText = attributedText
            print("Followers: ", Int32((iFollowers)))
            })
            return
        }
        
        
        fileprivate func getNumberOfFollowingWithId(userId: String)
        {
            // Following
            Database.getNumberOfFollowing(userId: userId, { (iFollowing) in
            let strPosts = "\(iFollowing)\n"
            let attributedText = NSMutableAttributedString(string: strPosts , attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "following",
                                                     attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
            self.followingLabel.attributedText = attributedText
            })
            return
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
        
        
        fileprivate func setupEditFollowButton() {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            self.editProfileFollowButton.setImage(#imageLiteral(resourceName: "ic_favorite"), for: .normal) // solid heart
            self.editProfileFollowedButton.setImage(#imageLiteral(resourceName: "ic_favorite_border"), for: .normal) // heart outline
            
            if let userId = userView?.uid {
                if uid == userId {
                    self.editProfileFollowButton.isHidden = true
                    self.editProfileFollowedButton.isHidden = true
                    getNumberOfFollowersWithId(userId: uid)
                    getNumberOfPostsWithId(userId: uid)
                    getNumberOfFollowingWithId(userId: uid)
                } else {
                    Database.isUserBeingFollowedByUser(userId: uid, userFollowing: userId , { (isFollowed) in
                        if isFollowed.isEmpty {
                        self.userIsFollowed()
                    } else
                        {
                        self.userIsNotFollowed()
                    }
                })
                    getNumberOfFollowersWithId(userId: userId)
                    getNumberOfPostsWithId(userId: userId)
                    getNumberOfFollowingWithId(userId: userId)
                }
            }
        }
        
        func userIsFollowed()
        {
            self.editProfileFollowButton.isHidden = false
            self.editProfileFollowedButton.isHidden = true
        }
        
        func userIsNotFollowed() {
            
            self.editProfileFollowButton.isHidden = true
            self.editProfileFollowedButton.isHidden = false
            
        }
        
        @objc func handleEditProfileOrFollow() {
            print("Execute edit profile / follow / unfollow logic...")
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            if uid == userView?.uid {
                self.editProfileFollowedButton.isHidden = true
                self.editProfileFollowButton.isHidden = true
                return
            }
            /*
             If the id has been 'followed' then set to 'Unfollowed' and change the button to can 'follow'
             then vice versa.
             The button should be not shown if the user opens his own profile ...
             Check whether we are following or not and just change it the other way...
             if hidden turn the button on and vice versa
             */
            
            /* User is already followed so follow now */
            if editProfileFollowButton.isHidden == true {
                
                Database.updateFollowers(userId: userId, followingUserId: uid, follow: 1)
                Database.updateFollowing(userId: uid , followingUserId: userId, follow: 1)
                
                self.editProfileFollowedButton.isHidden = true
                self.editProfileFollowButton.isHidden = false
                
                
            } else {
                //follow
                Database.updateFollowers(userId: userId, followingUserId: uid, follow: 0)
                Database.updateFollowing(userId: uid , followingUserId: userId, follow: 0)
                self.editProfileFollowedButton.isHidden = false
                self.editProfileFollowButton.isHidden = true
            }
        }
        
        fileprivate func setupFollowStyle() {
            // self.editProfileFollowButton.setImage(#imageLiteral(resourceName: "cameraButtonHighlighted"), for: .normal)
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
            label.font = UIFont.boldSystemFont(ofSize: 14)
            return label
        }()
        
        let postsLabel: UILabel = {
            let label = UILabel()
            var strPosts =  "0\n"
            let attributedText = NSMutableAttributedString(string: strPosts , attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
            label.attributedText = attributedText
            label.textAlignment = .center
            label.numberOfLines = 0
            return label
        }()
        
        // Return number of posts from : getNumberOfPosts()
        
        let followersLabel: UILabel = {
            let label = UILabel()
            
            let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
            
            attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
            
            label.attributedText = attributedText
            
            label.textAlignment = .center
            label.numberOfLines = 0
            return label
        }()
        
        let followingLabel: UILabel  = {
            let label  = UILabel()
            let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
            
            attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
            
            var titleStr : String?
            
            //titleStr = attributedText
            
            label.attributedText = attributedText
            label.numberOfLines = 0
            label.textAlignment = .center
            return label
        }()
        
        lazy var editProfileFollowButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 30 / 2;
            button.setImage(#imageLiteral(resourceName: "ic_favorite"), for: .normal)
            button.clipsToBounds = true;
            button.tintColor = .red
            button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
            return button
        }()
        
        lazy var editProfileFollowedButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 30 / 2;
            button.setImage(#imageLiteral(resourceName: "ic_favorite"), for: .normal)
            button.clipsToBounds = true;
            button.tintColor = .red
            button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
            return button
        }()
        
         //setupEditFollowButton()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            let Width : CGFloat  = 80
            
            addSubview(profileImageView)
            addSubview(editProfileFollowButton)
            addSubview(editProfileFollowedButton)
            
            profileImageView.anchor(top: topAnchor, left: self.centerXAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: CGFloat(-Width/2) , paddingBottom: 0, paddingRight: 0, width: Width, height: Width)
            profileImageView.layer.cornerRadius = Width / 2
            profileImageView.clipsToBounds = true
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            
            //Add the recognizer to your view.
            profileImageView.isUserInteractionEnabled = true
            profileImageView.addGestureRecognizer(tapRecognizer)
            
            
            editProfileFollowButton.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 30, height: 30)
            
            editProfileFollowedButton.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 30, height: 30)
            
            editProfileFollowedButton.isHidden = true
            
            setupBottomToolbar()
            setupUserStatsView()
           

           
        }
        
        fileprivate func setupUserStatsView() {
            let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
            
            stackView.distribution = .fillEqually
            addSubview(stackView)
            stackView.anchor(top: profileImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 0, height: 50)
            
            let tapFollowers = UITapGestureRecognizer(target: self, action: #selector(followersTapped(tapGestureRecognizer: )))
            followersLabel.isUserInteractionEnabled = true
            followersLabel.addGestureRecognizer(tapFollowers)
            
            let tapFollowing = UITapGestureRecognizer(target: self, action: #selector(followingTapped(tapGestureRecognizer: )))
            followingLabel.isUserInteractionEnabled = true
            followingLabel.addGestureRecognizer(tapFollowing)
            
            let tapProducts = UITapGestureRecognizer(target: self, action: #selector(productsTapped(tapGestureRecognizer: )))
            postsLabel.isUserInteractionEnabled = true
            postsLabel.addGestureRecognizer(tapProducts)
            
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
            
            
            
            stackView.anchor(top: nil, left: leftAnchor, bottom: self.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
            
            topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
            
            bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
            
            handleChangeToGridView()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    
    
    //
    //    fileprivate func getNumberOfFollowers()
    //    {
    //        print("Get the number of followers...")
    //        var iPosts = 0
    //        // check if there are a number of followerds
    //
    ////        refDatabase.child("following").observeSingleEvent(of: .value, with: { (snapshot) in
    //            guard let dictionaries = snapshot.value as? [String: Any] else { return }
    //            //value = snapshot.value as? NSDictionary
    //            dictionaries.forEach({ (key, value) in
    //                if key == Auth.auth().currentUser?.uid {
    //                    print("Found myself, omit from list")
    //                }
    //                else
    //                {
    //                    guard let userDictionary = value as? [String: Any] else { return }
    //                    userDictionary.forEach({(key, value) in
    //                        if key == Auth.auth().currentUser?.uid {
    //                            print("Found myself as a follower")
    //                            iPosts = iPosts + 1
    //                        }
    //                    })
    //                }
    //            })
    //            // compare the value to the currentLoggedInUserId to see if that person is a follower
    //            let strPosts = "\(iPosts)\n"
    //            let attributedText = NSMutableAttributedString(string: strPosts , attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
    //            attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
    //            self.followersLabel.attributedText = attributedText
    //            print("followers: ", Int32((iPosts)))
    //        }, withCancel: { (err) in
    //            print("Failed to check if followers:", err)
    //        })
    //
    //
    //        refDatabase.child("following").observe(.childChanged, with: { (snapshot) in
    //            guard let dictionaries = snapshot.value as? [String: Any] else { return }
    //            //value = snapshot.value as? NSDictionary
    //
    //            dictionaries.forEach({ (key, value) in
    //                if key == Auth.auth().currentUser?.uid {
    //                    print("Found myself, omit from list")
    //                }
    //                else
    //                {
    //                    guard let userDictionary = value as? [String: Any] else { return }
    //                    userDictionary.forEach({(key, value) in
    //                        if key == Auth.auth().currentUser?.uid {
    //                            print("Found myself as a follower", key)
    //                            iPosts = iPosts + 1
    //                        }
    //                    })
    //                }
    //            })
    //
    //            // compare the value to the currentLoggedInUserId to see if that person is a follower
    //            let strPosts = "\(iPosts)\n"
    //            let attributedText = NSMutableAttributedString(string: strPosts , attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
    //            attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
    //            self.followersLabel.attributedText = attributedText
    //            print("followers: ", Int32((iPosts)))
    //        }, withCancel: { (err) in
    //            print("Failed to check if followers:", err)
    //        })
    //        iPosts = 0
    //        return
    //    }
    
    
    
    //    private func observeMessages() {
    //        var iPosts = 0
    //
    //        refDatabase.child("following").observe(.value, with: { (snapshot) in
    //            guard let dictionaries = snapshot.value as? [String: Any] else { return }
    //            iPosts = 0
    //            dictionaries.forEach({ (key, value) in
    //                if key == Auth.auth().currentUser?.uid {
    //                    print("Found myself, omit from list")
    //                }
    //                else
    //                {
    //                    guard let userDictionary = value as? [String: Any] else { return }
    //                    userDictionary.forEach({(key, value) in
    //                        if key == Auth.auth().currentUser?.uid {
    //                            print("Found myself as a follower")
    //                            iPosts = iPosts + 1
    //                        }
    //                    })
    //                }
    //            })
    //            // compare the value to the currentLoggedInUserId to see if that person is a follower
    //            let strPosts = "\(iPosts)\n"
    //            let attributedText = NSMutableAttributedString(string: strPosts , attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
    //            attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
    //            self.followersLabel.attributedText = attributedText
    //            print("Realtime Update Followers: ", Int32((iPosts)))
    //        }, withCancel: { (err) in
    //            print("Failed to check if followers:", err)
    //        })
    //        iPosts = 0
    //    }
    //
    //    deinit {
    //        if let refHandle = channelRefHandle {
    //            channelRef.removeObserver(withHandle: refHandle)
    //        }
    //    }
    
