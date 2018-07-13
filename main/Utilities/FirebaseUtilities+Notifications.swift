//
//  FirebaseUtilities+Notifications.swift
//  maple
//
//  Created by Murray Toews on 2018/04/21.
//  Copyright © 2018 Murray Toews. All rights reserved.
//

import Foundation
import Firebase
import GoogleMaps
import GooglePlaces


extension Database {
    /*****************      Notification       *****************
     Notifications are triggered by :
     fetchNotificastion (currentUserID)
     which contains one function for each type of notification:
     1. Users that the current user is following
     2. User that are following the current user
     3. Comments made by other users
     4. Likes made by users on the following user's post.
     **********************************************************/
    
    static func fetchNotification(uid: String, completion: @escaping (String) -> ()) {
        
        var loaded = 0
        let maxLoad = 30
        var success = true
        notifications = []
        
        if let currentUid = Auth.auth().currentUser?.uid {
            if currentUid == uid {
                completion("fail")
            }
        }
        
        self.fetchFollowingUsersWithUID(uid, completion:{
            message in
            loaded += 1
            if message != "success" {
                success = false
            }
            
            if loaded == maxLoad {
                if success {
                    completion("success")
                }
                else {
                    completion("fail")
                }
            }
        })
        
        self.fetchFollowersUsersWithUID(uid, completion:{
            message in
            loaded += 1
            if message != "success" {
                success = false
            }
            
            if loaded == maxLoad {
                if success {
                    completion("success")
                }
                else {
                    completion("fail")
                }
            }
        })
        
        self.fetchLikeUsersWithUID(uid, completion:{
            message in
            loaded += 1
            if message != "success" {
                success = false
            }
            
            if loaded == maxLoad {
                if success {
                    completion("success")
                }
                else {
                    completion("fail")
                }
            }
        })
        
        self.fetchCommentUsersWithUID(uid, completion:{
            message in
            loaded += 1
            if message != "success" {
                success = false
            }
            
            if loaded == maxLoad {
                if success {
                    completion("success")
                }
                else {
                    completion("fail")
                }
            }
        })
    }
    
    
    
    static func fetchFollowingUsersWithUID(_ uid: String, completion: @escaping (String) -> ()) {
        var followerUids: [String] = []
        Database.database().reference().child("following").child(uid).observe(.value, with: {
            (snapshot) in
            if let data = snapshot.value as? [String: AnyObject] {
                for followerUid in data.keys {
                    followerUids.append(followerUid)
                }
                self.fetchFollowingUsersWithFollowerUID(uid, followerUids, completion:{
                    message in
                    if message == "success"{
                         completion("success")
                    }
                })
            }
            else {
                completion("success")
            }
        })
    }
    
    static func newFetchFollowersUsersWithUID(_ uid: String, completion: @escaping (String) -> ()) {
        var maxFollower = 0
        var totalFollower = 0
        
        Database.database().reference().child("followers").child(uid).observe(.value, with: {
            (snapshot) in
            if let data = snapshot.value as? [String: AnyObject] {
                data.forEach({ (key, value) in
                    if value as! Int == 1 {
                        maxFollower += 1
                        self.fetchUserWithUID(uid: key, completion: { (follower) in
                            totalFollower += 1
                            followers?.append(follower)
                            let todayTimestamp = Int64(Date().timeIntervalSince1970)
                            let content = follower.username + " is now following you!"
                            let notification = NotificationObject(date: Double(todayTimestamp), type: "following", key: key, sender: uid, content: content, postid: "")
                            notifications.append(notification)
                            if maxFollower == totalFollower {
                                completion("success")
                            }
                        })
                    }
                    
                })
            }
            else {
                completion("success")
            }
        })
    }
    
    static func fetchFollowersUsersWithUID(_ uid: String, completion: @escaping (String) -> ()) {
        var followerUids: [String] = []
        Database.database().reference().child("followers").child(uid).observe(.value, with: {
            (snapshot) in
            if let data = snapshot.value as? [String: AnyObject] {
                for followerUid in data.keys {
                    followerUids.append(followerUid)
                }
                self.fetchFollowingUsersWithFollowerUID(uid, followerUids, completion:{
                    message in
                    if message == "success"{
                        completion("success")
                    }
                })
            }
            else {
                completion("success")
            }
        })
    }
    
    /*
     Listen for users who start to follow you.
     */
    static func fetchFollowingUsersWithFollowerUID(_ userUid: String, _ followerUids: [String], completion: @escaping (String) -> ()) {
        var totalFollower = 0
        var maxFollower = 0
        for followerUid in followerUids {
            Database.database().reference().child("following").child(followerUid).observe(.value, with: {
                (snapshot) in
                if let data = snapshot.value as? [String: AnyObject] {
                    for follower in data {
                        if follower.key == userUid && follower.value as! Int == 1 {
                            maxFollower += 1
                            self.fetchUserWithUID(uid: followerUid, completion: { (follower) in
                                totalFollower += 1
                                followers?.append(follower)
                                let todayTimestamp = Int64(Date().timeIntervalSince1970)
                                let content = follower.username + " is now following you!"
                                let notification = NotificationObject(date: Double(todayTimestamp), type: "following", key: followerUid, sender: follower.uid, content: content, postid: "")
                                notifications.append(notification)
                                if maxFollower == totalFollower {
                                    completion("success")
                                }
                            })
                        }
                    }
                }
            })
        }
    }
    
    static func fetchLikeUsersWithUID(_ uid: String, completion: @escaping (String) -> ()) {
        var postIds: [String] = []
        Database.database().reference().child("posts").child(uid).observeSingleEvent(of: DataEventType.value, with: {
            (snapshot) in
            if let data = snapshot.value as? [String: AnyObject] {
                for post in data.keys {
                    postIds.append(post)
                }
                self.fetchLikeUsersWithPostId(postIds, completion:{
                    message in
                    if message == "success"{
                        completion("success")
                    }
                })
            }
            else {
                completion("success")
            }
        })
    }
    
    static func removeNotification(_ uid: String, _ notification: NotificationObject, completion: @escaping (String) -> ()) {
        let type = notification.type as String
        let key = notification.key as String
        let sender = notification.sender
        
        switch type {
        case "following":
            Database.database().reference().child("following").child(key).child(uid).setValue(0, withCompletionBlock: { (error, ref) in
                completion("success")
            })
            break
        case "followers":
            Database.database().reference().child("follower").child(key).child(uid).setValue(0, withCompletionBlock: { (error, ref) in
                completion("success")
            })
            break
        case "likes":
            Database.database().reference().child("likes").child(key).child(sender).setValue(0, withCompletionBlock: { (error, ref) in
                completion("success")
            })
            break
        case "comments":
            //Database.database().reference().child("comments").child(key).child(sender.uid).setValue(0, withCompletionBlock: { (error, ref) in
            //    completion("success")
            //})
            completion("success")
            break
        default:
            completion("success")
        }
    }
    
   
    
}
