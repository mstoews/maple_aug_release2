//  UserPostsController.swift
//  maple-release
//
//  Created by Murray Toews on 2018/01/20.
//  Copyright © 2018 Murray Toews. All rights reserved.
//
import UIKit
import Firebase
import FirebaseFirestore
import MaterialComponents

class UserFollowersController : UserFollowingController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Following"
        
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.register(UserFollowingCell.self, forCellWithReuseIdentifier: cellId)
        fetchData()
        
    }
    
    override func fetchData()
    {
        if let uid = Auth.auth().currentUser?.uid {
            if uid != user?.uid {
                return
            }
            Firestore.fetchUserFollowedByUserId(uid: uid) { (userList) in
                for uid in userList {
                    print(uid)
                    Firestore.fetchUserWithUID(uid: uid) {  [weak self] (user) in
                        guard let strongSelf = self else {return}
                        DispatchQueue.main.async {
                            strongSelf.userFollowing.append(user)
                            strongSelf.collectionView?.reloadData()
                        }
                    }
                }
            }
        }
    }
}

class UserFollowingController: MDCCollectionViewController {
    
    var user: MapleUser?
    
    var userFollowing = [MapleUser]()
    var userList = [String]()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Followed"
        
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.register(UserFollowingCell.self, forCellWithReuseIdentifier: cellId)
        fetchData()
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userFollowing.count
    }
    
    func fetchData()
    {
        if let uid = Auth.auth().currentUser?.uid {
            if uid != user?.uid {
                return
            }
            Firestore.fetchUserFollowingByUserId(uid: uid) { (userList) in
                for uid in userList {
                    print(uid)
                    Firestore.fetchUserWithUID(uid: uid) {  [weak self] (user) in
                        guard let strongSelf = self else {return}
                        DispatchQueue.main.async {
                            strongSelf.userFollowing.append(user)
                            strongSelf.collectionView?.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = UserFollowingCell(frame: frame)
        dummyCell.user = userFollowing[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40 + 8 + 8, estimatedSize.height)
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserFollowingCell
        cell.user = self.userFollowing[indexPath.item]
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}


class UserFollowingCell: MDCCollectionViewCell {
    
    var user: MapleUser? {
        didSet {
            guard let user = user else {return}
            let attributedText = NSMutableAttributedString(string: " \(user.username)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10)])
            textView.attributedText = attributedText
            profileImageView.loadImage(urlString: user.profileImageUrl)
        }
    }
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 12)
        textView.isScrollEnabled = false
        return textView
    }()
    
    let timeView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 10)
        textView.isScrollEnabled = false
        return textView
    }()
    
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .blue
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        addSubview(textView)
        textView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
