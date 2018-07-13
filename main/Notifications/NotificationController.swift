//
//  NotificationController.swift
//  maple
//
//  Created by Murray Toews on 2017-07-25.
//  Copyright © 2017 mapleon. All rights reserved.
//


import UIKit
import Firebase

class NotificationController: UITableViewController {
    
    let cellId = "cellId"
    var userId: String?
    var followers: [String] = []
    var user: MapleUser?
    var allNotifications: [NotificationObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.allNotifications = notifications
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: NSNotification.Name(rawValue : "Got Values"), object: nil)
        
        self.fetchUser()
    
        tableView.backgroundColor = .white
        tableView.register(NotificationPostCell.self, forCellReuseIdentifier: cellId)
        tableView.alwaysBounceVertical = true
        tableView.keyboardDismissMode = .onDrag
        self.fetchNotification()
    }
    
    @objc func reloadTable() {
        self.allNotifications = notifications
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allNotifications.count
    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        //let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! NotificationPostCell
//        //cell.notification = allNotifications[indexPath.row]
//        return cell
//    }
//    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.openUserProfile(allNotifications[indexPath.row].sender.uid, allNotifications[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.removeNotification(indexPath.row)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
    
    fileprivate func fetchUser() {
        if let uid = Auth.auth().currentUser?.uid {
            Database.fetchUserWithUID(uid: uid) { (user) in
                self.user = user
                let username = self.user?.username
                self.navigationItem.title = "Notifications - " + username!
                self.tableView.reloadData()
            }
        }
    }
    
    fileprivate func fetchNotification() {
        if let uid = Auth.auth().currentUser?.uid {
            Database.fetchNotification(uid: uid) { message in
                if message == "success" {
                    self.allNotifications = notifications
                    self.tableView.reloadData()
                }
            }
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
        self.tableView.reloadData()
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
            // todo 
//            Database.fetchPostByUidPostId(uid: senderUid, postId: notification.postid, completion: { (Post) in
//                if let postId = Post.id {
//                    if postId.count > 0 {
//                      commentsController.post = Post
//                      self.navigationController?.pushViewController(commentsController, animated: true)
//                    }
//                }
//            })
             break
        default:
            return
        }
    
    }

}

