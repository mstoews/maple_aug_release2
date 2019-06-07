//
//  FirestoreUtilities.swift
//  maple
//
//  Created by Murray Toews on 2018/06/17.
//  Copyright © 2018 Murray Toews. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import GoogleMaps
import GooglePlaces


extension Firestore {
    
    static func fetchUserWithUID(uid: String, completion: @escaping (MapleUser) -> ()) {
        let docRef = firestore().collection("users").document(uid).collection("profile").document(uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let user = MapleUser(uid: uid,  dictionary: document.data()!)
                completion(user)
            } else {
                print("Document  nb bbbbbdoes not exist")
            }
        }
     }
    
    //MARK:- Notification
    static func fetchNotifications(uid : String, completion: @escaping ([NotificationObject]) -> () )
    {
        var notificationArray = [NotificationObject]()
        let docRef = firestore().collection("notification").whereField("uid", isEqualTo: uid)
        docRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if let obj = NotificationObject(dictionary: document.data(), postId: document.documentID) {
                        notificationArray.append(obj)
                    }
                }
                completion(notificationArray)
            }
        }
    }
    
    
    static func removeNotification (notificationItem: Int) -> Bool {
        if notificationsFire.count > 0 {
            let notificationObj = notificationsFire[notificationItem]
            if let uid = Auth.auth().currentUser?.uid {
                let docRef = firestore().collection("users").document(uid).collection("events").whereField("interactionRef", isEqualTo: notificationObj.interactionRef)
                docRef.getDocuments()
                    { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            if querySnapshot!.count > 0 {
                                for document in querySnapshot!.documents {
                                    let docID = document.documentID
                                    print(docID)
                                     let values: [String: Any] = ["deleted": true as Bool]
                                    firestore().collection("users").document(uid).collection("events").document(document.documentID).updateData(values)
                                }
                                    
                            }
                        }
                }
               return true
            }
        }
        return false
    }
    
   
   
    
    /*******  updateUserProfile  *******/
    static func updateUserProfile(user: MapleUser) {
        var bDocExists  = false
        
        var followedCount = 0
        var followerCount = 0
        var postCount = 0
        
        followedCount = getFollowedCount(user: user)
        followerCount = getFollowerCount(user: user)
        postCount = getPostCount(user: user)
            
        let values: [String: Any] = ["profileImageUrl": user.profileImageUrl,
                                     "username": user.username,
                                     "followCount": followedCount  ,
                                     "followerCount": followerCount ,
                                     "postCount": postCount  ,
                                     "_search_index": ["full_name": user.username.lowercased(),
                                                       "reversed_full_name": user.username.components(separatedBy: " ")
                                                        .reversed().joined(separator: "")]]
        
        let docRef = firestore().collection("users").document(user.uid).collection("profile").document(user.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                bDocExists = true
            } else {
                bDocExists = false
            }
        }
        if bDocExists == true {
            firestore().collection("users").document(user.uid).collection("profile").document(user.uid).updateData(values)
            { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Did successfully like : \(values) for user \(user.uid)")
                }
            }
        }
        else
        {
            firestore().collection("users").document(user.uid).collection("profile").document(user.uid).setData(values)
            { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Did successfully like : \(values) for user \(user.uid)")
                }
            }
        }
        
        let postDocs = firestore().collection("posts").whereField("uid", isEqualTo: user.uid)
        postDocs.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    print(data)
                }
            }
        }
       
    }
    
   
    //MARK:- Location
     /*******  fetchLocationByPostId  *******/
    static func fetchLocationByPostId(postId: String, _ completion: @escaping ([LocationObject]) -> () ){
        
        var locationObjects = [LocationObject]()
        let docRef = firestore().collection("posts").document(postId).collection("location")
        
        docRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    if let obj = LocationObject(dictionary: document.data()) {
                        locationObjects.append(obj)
                    }
                }
                completion(locationObjects)
            }
        }
        
    }
    
    static func fetchLocationByUserId(uid: String, _ completion: @escaping ([LocationObject]) -> () ){
        
        var locationObjects = [LocationObject]()
        let docRef = firestore().collection("location").whereField("uid", isEqualTo: uid)
        
        docRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    if let obj = LocationObject(dictionary: document.data()) {
                        locationObjects.append(obj)
                    }
                    
                }
                completion(locationObjects)
            }
        }
        
    }
    
    //MARK:- Follow
    /*******  didFollowUser  *******/
    static func didFollowUser(uid: String, uidFollow: String, didFollow: Bool) {
        let followedData = [
            "uid" : uid,
            "followUid" : uidFollow,
            "isFollowed" : didFollow
            ]
            as [String: Any]
        firestore().collection("users").document(uid).collection("followed").document(uidFollow).setData(followedData)
        { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Did successfully like : \(uid) for user \(uidFollow)")
            }
        }
        let followerData = [
            "uid" : uidFollow ,
            "followerUid" :uid,
            "isFollower" : didFollow
            ]
            as [String: Any]
        firestore().collection("users").document(uidFollow).collection("following").document(uid).setData(followerData)
        
    }
    
    static func getFollowerCount (user: MapleUser) -> Int {
        var followerCount = 0
        let followRef = firestore().collection("users").document(user.uid).collection("following").whereField("isFollower", isEqualTo: true)
        followRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                followerCount = querySnapshot!.documents.count
                if followerCount > 0 {
                    let values: [String: Any] = ["followerCount": followerCount as Int]
                    firestore().collection("users").document(user.uid).collection("profile").document(user.uid).updateData(values)
                    { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Did successfully update from getFollowerCount : \(values) for user \(user.uid)")
                        }
                    }
                    
                }
            }
        }
        return followerCount
    }
    
    
    static func getFollowedCount (user: MapleUser) -> Int {
        var followedCount = 0
        
        let followRef = firestore().collection("users").document(user.uid).collection("followed").whereField("isFollowed", isEqualTo: true)
        followRef.getDocuments()
            { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    followedCount = querySnapshot!.documents.count
                    if followedCount > 0 {
                        let values: [String: Any] = ["followedCount": followedCount as Int]
                        firestore().collection("users").document(user.uid).collection("profile").document(user.uid).updateData(values)
                        { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Did successfully update from getFollowedCount : \(values) for user \(user.uid)")
                            }
                        }
                    }
                }
        }
        return followedCount
    }

    static func getFollowedUsers (user: MapleUser) -> Int {
        var followedCount = 0
        
        let followRef = firestore().collection("users").document(user.uid).collection("followed").whereField("isFollowed", isEqualTo: true)
        followRef.getDocuments()
            { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    followedCount = querySnapshot!.documents.count
                    if followedCount > 0 {
                        let values: [String: Any] = ["followedCount": followedCount as Int]
                        firestore().collection("users").document(user.uid).collection("profile").document(user.uid).updateData(values)
                        { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Did successfully update from getFollowedCount : \(values) for user \(user.uid)")
                            }
                        }
                    }
                }
        }
        return followedCount
    }
    

    //MARK:- didLikePost
    
    static func didLikePost(postId: String, uidLiked: String, didLike: Bool) {
        let values = [ "Liked" : didLike ] as [String: Any]
        firestore().collection("posts").document(postId).collection("likes").document(uidLiked).setData(values)
        { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Did successfully like : \(postId) for user \(uidLiked)")
            }
        }
    }
    
    // MARK : -  isPostLikeByUser
    static func isPostLikeByUser(postId: String, uid: String, _ completion: @escaping (Bool) -> () ) {
        
        let docRef = firestore().collection("posts").document(postId).collection("likes").document(uid)
        docRef.getDocument { (document, error) in
            if let error = error {
                print ("Error in data structure : \(error)")
                completion(false)
            }
            if let document = document, document.exists {
                print ("Post: \(postId) user id : \(uid)")
                var isBookMarked: Bool
                isBookMarked = (document["Liked"] != nil)
                if isBookMarked == false {
                    completion(false)
                }
                else
                {
                    completion(true)
                }
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    
    //MARK:- Bookmark
    
    static func didBookmarkedPost(post: FSPost, didBookmark: Bool) {
        
        if let postId = post.id {
            let values =
                [
                    "creationDate": post.creationDate,
                    "description": post.description,
                    "name" : post.userName,
                    "numberOfComments": post.noOfComments,
                    "numberOfLikes": post.noOfLikes,
                    "postid": post.id!,
                    "product": post.product,
                    "profileUrl": post.profileURL,
                    "thumbImages": post.imageUrlArray,
                    "uid": post.uid,
                    "bookMarked" : didBookmark
                    ]
                    as [String: Any]
            
            if let uid = Auth.auth().currentUser?.uid  {
                
                firestore().collection("users").document(uid).collection("bookmarked").document(postId).setData(values)
                { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Did successfully bookmark : \(postId) for user \(post.uid)")
                    }
                }
            }
            
            let Booked = [ "BookMarked" : didBookmark ] as [String: Any]
            firestore().collection("posts").document(postId).collection("bookmarked").document(post.uid).setData(Booked)
            { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Did successfully like : \(postId) for user \(post.uid)")
                }
            }
        }
    }
    
    
   
    static func isPostBookMarkedByUser(postId: String, uid: String, _ completion: @escaping (Bool) -> () ) {
        let docRef = firestore().collection("posts").document(postId).collection("bookmarked").document(uid)
        
        docRef.getDocument { (document, error) in
            if let error = error {
                print ("Error in data structure : \(error)")
                completion(false)
            }
            if let document = document, document.exists {
                guard let isBookMarked = document["BookMarked"] else
                {
                    completion(false)
                    return
                }
                completion(isBookMarked as! Bool)
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    //MARK:- Comment
    
    /*******  addPostComments  *******/
    static func addPostComment(postId: String, comment: String, uid: String)
    {
        let values = ["text": comment,
                      "creationDate": Date().timeIntervalSince1970,
                      "uid": uid] as [String : Any]
        
        firestore().collection("posts").document(postId).collection("comments").document().setData(values)
        {
                err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully postId: " + postId)
                }
        }
    }
    
    static func fetchCommentByPost(postId: String , user: MapleUser , _ completion: @escaping ([Comment])->() )
    {
        var commentsArray = [Comment]()
        firestore().collection("posts").document(postId).collection("comments").getDocuments() {
            (querySnapshot, err) in
            if let err = err  {
                print("Error getting documents: \(err)");
            }
            else  {
                for document in querySnapshot!.documents {
                   let doc = Comment(user: user, dictionary: document.data())
                   commentsArray.append(doc)
                }
                completion(commentsArray)
            }
        }
    }
    
    //MARK:- Post
    static func deletePost(postId : String){
          firestore().collection("posts").document(postId).delete()
    }
    
    static func fetchPostByPostId (postId: String, _ completion: @escaping (FSPost) -> () ) {
        let docRef = firestore().collection("posts").document(postId)
        docRef.getDocument { (document, error) in
            if let post = document.flatMap({
                $0.data().flatMap({ (data) in
                    let post = FSPost( dictionary: data, postId: postId)
                    completion(post!)
                })
            })
            {
                print("OKD \(post)")
                
            } else {
                
                print("Not okay")
            }
        }
    }
    
    
    
    static func getPostCount (user: MapleUser) -> Int {
        var postCount = 0
        let followRef = firestore().collection("posts").whereField("uid", isEqualTo: user.uid)
        followRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                postCount = querySnapshot!.documents.count
                if postCount > 0 {
                    let values: [String: Any] = ["postCount": postCount as Int]
                    firestore().collection("users").document(user.uid).collection("profile").document(user.uid).updateData(values)
                    { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Did successfully update from getPostCount : \(values) for user \(user.uid)")
                        }
                    }
                    
                }
            }
        }
        return postCount
    }
    
   
    
    //MARK:- Algolia
    static func updateAlgoliaPost(postId: String) {
        firestore().collection("posts").document(postId).getDocument() { (snapshot, error) in
            if let error = error  {
                print("Error getting documents: \(error)");
            }
            else  {
                if snapshot != nil {
                    let postId = snapshot!["postid"] as! String
                    if let post = FSPost(dictionary: (snapshot?.data())!, postId: postId) {
                        let values : [String: Any] = ["userid" : post.uid,
                                                      "name" : post.userName,
                                                      "profileUrl" : post.imageUrl,
                                                      "product": post.product ,
                                                      "description" : post.description,
                                                      "urlArray" : post.imageUrlArray,
                                                      "creationDate": Date().timeIntervalSince1970]
                        
                        AlgoliaManager.sharedInstance.posts.addObject(values, withID: post.id! , completionHandler: { (content, error) -> Void in
                            if error == nil {
                                if let objectID = content!["objectID"] as? String {
                                    print("Object ID: \(objectID)")
                                }
                            }
                        })
                    }
                }
            }
        }
    }

    static func updateAlgoliaPost(post: FSPost) {
        if let postId = post.id {
            let values : [String: Any] = ["userid" : post.uid,
                                          "name" : post.userName,
                                          "profileUrl" : post.imageUrl,
                                          "product": post.product ,
                                          "description" : post.description,
                                          "urlArray" : post.imageUrlArray,
                                          "creationDate": Date().timeIntervalSince1970]
            
            AlgoliaManager.sharedInstance.posts.addObject(values, withID: postId, completionHandler: { (content, error) -> Void in
                if error == nil {
                    if let objectID = content!["objectID"] as? String {
                        print("Object ID: \(objectID)")
                    }
                }
            })
        }
    }
    
    //MARK:- DocCounts
    static func updateDocCounts()
    {
        
        firestore().collection("posts").getDocuments() {
            (querySnapshot, err) in
            if let err = err  {
                print("Error getting documents: \(err)");
            }
            else  {
                var likeCount = 0
                var commentCount = 0
                for document in querySnapshot!.documents {
                    let post = FSPost(dictionary: document.data(), postId: document.documentID)
                    if let postId = post?.id {
                        getPostCollectionCount(collection: "likes", postId: postId,  { (likes) in
                            likeCount = likes
                            
                            getPostCollectionCount(collection: "comments", postId: postId,  { (comments) in
                                commentCount = comments
                                
                            })
                        })
                        
                    }
                }
            }
        }
    }
    
    /*******  getPostCollectionCount  *******/
    static func getPostCollectionCount(collection: String, postId: String, _ completion: @escaping (Int) -> () )
    {
        var count = 0
        firestore().collection("posts").document(postId).collection(collection).getDocuments() {
            (querySnapshot, err) in
            if let err = err  {
                print("Error getting documents: \(err)");
            }
            else  {
                for document in querySnapshot!.documents {
                    
                    switch collection
                    {
                    case "bookmarked":
                        let bBookmarked  = document["BookMark"] as! Int
                        if bBookmarked == 1 {
                            count += 1
                        }
                        break
                    case "likes":
                        let bLiked  = document["Liked"] as! Int
                        if bLiked == 1 {
                            count += 1
                        }
                        break
                    case "comments":
                        count += 1
                        break
                    default:
                        count = 0
                    }
                }
                print("Count = \(count)");
                completion(count)
            }
        }
    }
    
   
}

