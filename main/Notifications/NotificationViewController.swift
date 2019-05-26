//
//  NotificationViewController.swift
//  maple_release
//
//  Created by Murray Toews on 2018/05/26.
//  Copyright © 2018 Murray Toews. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import MaterialComponents

class NotificationViewController: MDCCollectionViewController , NotificationDelegate {
    
    let cellId = "cellId"
    var sizingCell: NotificationPostCell!
    var insets: UIEdgeInsets!
    
    var userId: String?
    var followers: [String] = []
    var user: MapleUser?
    var allNotifications: [NotificationFireObject] = []
    
    func didSave(for cell: NotificationPostCell) {
        
    }
    
    func didClear(for cell: NotificationPostCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        if Firestore.removeNotification(notificationItem: indexPath.item) == true {
            print("Removed")
        }
    }
    
    var notification: NotificationObject? {
        didSet {
            if  let sender = notification?.sender {
                Firestore.fetchUserWithUID(uid: sender, completion: { (user) in
                    self.usernameLabel.text = user.username
                    let profileImageUrl = user.profileImageUrl
                    self.profileImageView.loadImage(urlString: profileImageUrl)
                    self.contentLabel.text = self.notification?.content
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy/MM/dd"
                    let date = Date(timeIntervalSince1970: (self.notification?.date)!)
                    let timeAgoDisplay = date.timeAgoToDisplay()
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
        
        self.allNotifications = notificationsFire
        
        //NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: NSNotification.Name(rawValue : "Got Values"), object: nil)
        
        if #available(iOS 10.0, *) {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self,
                                     action: #selector(refreshOptions(sender:)),
                                     for: .valueChanged)
            collectionView?.refreshControl = refreshControl
        }
        self.observeNotifications()
        if notificationsFire.count > 0 {
            let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
            mainTabBarController?.setNotificationBadgeCount(count: notificationsFire.count)
        }
    }
    
    @objc private func refreshOptions(sender: UIRefreshControl) {
        sender.beginRefreshing()
        self.observeNotifications()
        sender.endRefreshing()
    }
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        if Firestore.removeNotification(notificationItem: indexPath.item) == true {
            // notificationsFire.remove(at: indexPath.item)
            collectionView.deleteItems(at: [indexPath])
        }
    }
    
    deinit {
        listener?.remove()
    }
    
    private var listener: ListenerRegistration?
    
    fileprivate func observeNotifications()
    {
        stopObserving()
        
        if let uid = Auth.auth().currentUser?.uid {
            self.listener =
                Firestore.firestore().collection("users").document(uid).collection("events").order(by: "timestamp", descending: true)
                //Firestore.firestore().collection("users").document(uid).collection("events").whereField("deleted", isEqualTo: false)
                    .addSnapshotListener{  (snapshot, error) in
                        guard let snapshot = snapshot else {
                            print("Error fetching snapshot results: \(error!)")
                            return
                        }
                        notificationsFire.removeAll()
                        for document in snapshot.documents {
                            if let notification = NotificationFireObject(dictionary: document.data()) {
                                if notification.interactionUser != uid {
                                    notificationsFire.append(notification)
                                }
                                self.collectionView?.reloadData()
                            }
                        }
            }
        }
    }
    
    
    fileprivate func stopObserving() {
        listener?.remove()
    }
    

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        mainTabBarController?.setNotificationBadgeCount(count: 0)
        return  notificationsFire.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(7, 7, 7, 7)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NotificationPostCell
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = NotificationPostCell(frame: frame)
        dummyCell.notification = notificationsFire[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        if Firestore.removeNotification(notificationItem: indexPath.item) == true {
            print("Removed")
        }
        
        let height = CGFloat(70.0)
        return CGSize(width: view.frame.width - 30, height: height)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NotificationPostCell
        let notificationObj = notificationsFire[indexPath.item]
        cell.delegate = self
        cell.populateCell(from: notificationObj , isDryRun: false )
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
            Firestore.fetchUserWithUID(uid: uid) { (user) in
                self.user = user
                let username = self.user?.username
                self.navigationItem.title = "Notifications - " + username!
                self.collectionView?.reloadData()
            }
        }
    }
    
    fileprivate func openPost(_ postId: String) {
        Firestore.fetchPostByPostId(postId: postId) { (post) in
            Firestore.fetchUserWithUID(uid: post.uid) { (user) in
                let userProductController = UserProductController(collectionViewLayout: UICollectionViewFlowLayout())
                userProductController.setPostId(postId: postId)
                userProductController.user = user
                self.navigationController?.pushViewController(userProductController, animated: true)
            }
        }
    }
    
    fileprivate func openUserPage(_ senderUid: String) {
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        Firestore.fetchUserWithUID(uid: senderUid, completion: { (user) in
            userProfileController.user = user
            self.navigationController?.pushViewController(userProfileController, animated: true)
        })
    }
    
    func openPageByKind(_ senderUid: String, _ notificationType: String, _ postId: String){
        
        let backItem = UIBarButtonItem(title: "Back", style: .plain , target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        let transition = CATransition()
        transition.duration = 0.1
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.navigationController?.view.layer.add(transition, forKey: nil)
        _ = self.navigationController?.popToRootViewController(animated: false)

        
        switch notificationType {
        case "following":
            openUserPage(senderUid)
            break
        case "followers":
            openUserPage(senderUid)
            break
        case "likes":
            openPost(postId)
            break
        case "comment":
            openPost(postId)
            break
        default:
            return
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let notification = notificationsFire[indexPath.item]
        print("Notification reference \(notification.interactionRef)")
        openPageByKind(notification.interactionUser, notification.kind, notification.interactionRef)
    }
    
    
}

