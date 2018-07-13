//
//  NotificationViewController.swift
//  maple_release
//
//  Created by Murray Toews on 2018/05/26.
//  Copyright © 2018 Murray Toews. All rights reserved.
//

import UIKit
import Firebase
import MaterialComponents

class NotificationViewController: MDCCollectionViewController {
    
    var notification: NotificationObject? {
        didSet {
            if  let sender = notification?.sender {
                Database.fetchUserWithUID(uid: sender, completion: { (user) in
                    self.usernameLabel.text = user.username
                    let profileImageUrl = user.profileImageUrl
                    self.profileImageView.loadImage(urlString: profileImageUrl)
                    self.contentLabel.text = self.notification?.content
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy/MM/dd"
                    let date = Date(timeIntervalSince1970: (self.notification?.date)!)
                    let timeAgoDisplay = date.timeAgoDisplay()
                    self.timeLabel.text = timeAgoDisplay
                })
            }
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        //label.backgroundColor = UIColor.veryLightGray()
        return label
    }()
    
//    let contentLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Content"
//        label.textColor = .darkGray
//        label.font = UIFont.systemFont(ofSize: 12)
//        label.numberOfLines = 0
//        return label
//    }()
    
    
    let contentLabel:  MDCMultilineTextField = {
        let TextField =  MDCMultilineTextField()
        TextField.placeholder = "Description"
        TextField.font = UIFont.systemFont(ofSize: 15)
        TextField.translatesAutoresizingMaskIntoConstraints = true
        TextField.textColor = UIColor.black
        TextField.backgroundColor =  UIColor.collectionCell()
        TextField.isEnabled = false 
        TextField.tag = 2
        return TextField
    }()
    
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "Date"
        label.font = UIFont.systemFont(ofSize: 8)
        label.textColor = .lightGray
        return label
    }()
    
    
    let cellId = "cellId"
    var sizingCell: NotificationPostCell!
    var insets: UIEdgeInsets!
    
    var userId: String?
    var followers: [String] = []
    var user: MapleUser?
    var allNotifications: [NotificationObject] = []

    
    @objc func reloadTable() {
        self.allNotifications = notifications
        collectionView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Notifications"
        collectionView?.backgroundColor = UIColor.veryLightGray()
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        
        collectionView?.register(NotificationPostCell.self, forCellWithReuseIdentifier: cellId)
        sizingCell = NotificationPostCell()
        
        styler.cellStyle = .card
        styler.gridColumnCount = 1
        styler.cellLayoutType = .grid
        styler.gridPadding = 8
        
        self.allNotifications = notifications
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: NSNotification.Name(rawValue : "Got Values"), object: nil)
        
        self.fetchUser()
        
        if #available(iOS 10.0, *) {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self,
                                     action: #selector(refreshOptions(sender:)),
                                     for: .valueChanged)
            collectionView?.refreshControl = refreshControl
        }
        
         self.fetchNotification()
    }
    
    
    @objc private func refreshOptions(sender: UIRefreshControl) {
         self.fetchNotification()
        sender.endRefreshing()
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  notifications.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(7, 7, 7, 7)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = NotificationPostCell(frame: frame)
        dummyCell.notification = notifications[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width  , height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = CGFloat(56.0)
        return CGSize(width: view.frame.width - 30, height: height)
    }

    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NotificationPostCell
        let notification = self.allNotifications[indexPath.item]
        
        Database.fetchUserWithUID(uid: notification.sender, completion: { (user) in
            cell.populateContent(from: user, text: notification.content, date: notification.date, index: indexPath.item, isDryRun: false )
        })
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
    
    
    fileprivate func fetchUser() {
        if let uid = Auth.auth().currentUser?.uid {
            Database.fetchUserWithUID(uid: uid) { (user) in
                self.user = user
                let username = self.user?.username
                self.navigationItem.title = "Notifications - " + username!
                self.collectionView?.reloadData()
            }
        }
    }
    
    fileprivate func fetchNotification() {
    if let uid = Auth.auth().currentUser?.uid {
    //            Firestore.fetchNotifications(uid: uid) { _ in (notification)
    //
    //
    //            }
        }
    }
    
    fileprivate func removeNotification(_ item: Int) {
        let uid = userId ?? (Auth.auth().currentUser?.uid ?? "")
        Database.removeNotification(uid, allNotifications[item]) { message in
            if message == "success" {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue : "Badge Changed"), object: nil)
            }
        }
        notifications.remove(at: item)
        self.allNotifications = notifications
        self.collectionView?.reloadData()
    }
    
    func openUserProfile(_ senderUid: String, _ notification: NotificationObject){
        
        let backItem = UIBarButtonItem(title: "Back", style: .plain , target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        let transition = CATransition()
        transition.duration = 0.75
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.navigationController?.view.layer.add(transition, forKey: nil)
        _ = self.navigationController?.popToRootViewController(animated: false)
        
        
        switch notification.type {
        case "following":
            let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
            Database.fetchUserWithUID(uid: senderUid, completion: { (user) in
                userProfileController.user = user
                self.navigationController?.pushViewController(userProfileController, animated: true)
            })
            break
        case "followers":
            let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
            Database.fetchUserWithUID(uid: senderUid, completion: { (user) in
                userProfileController.user = user
                self.navigationController?.pushViewController(userProfileController, animated: true)
            })
            break
        case "likes":
            let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
            Database.fetchUserWithUID(uid: senderUid, completion: { (user) in
                userProfileController.user = user
                self.navigationController?.pushViewController(userProfileController, animated: true)
            })
            break
        case "comments":
            let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
            
            Database.fetchPostByUidPostId(uid: senderUid, postId: notification.postid, completion: { (Post) in
                if let postId = Post.id {
                    if postId.count > 0 {
                        //todo
                        //commentsController.post = Post
                        self.navigationController?.pushViewController(commentsController, animated: true)
                    }
                }
            })
            break
        default:
            return
        }
        
    }

}

