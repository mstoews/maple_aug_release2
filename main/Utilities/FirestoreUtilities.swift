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
    
    /*******  updateUserProfile  *******/
    static func updateUserProfile(user: User) {
        let values: [String: Any] = ["profileImageUrl": user.photoURL?.absoluteString ?? "",
                                     "username": user.displayName ?? "",
                                     "_search_index": ["full_name": user.displayName?.lowercased(),
                                                       "reversed_full_name": user.displayName?.components(separatedBy: " ")
                                                        .reversed().joined(separator: "")]]
        
      firestore().collection("users").document(user.uid).collection("profile").document(user.uid).setData(values)
        { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Did successfully like : \(values) for user \(user.uid)")
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
    

    
    /*******  didLikePost  *******/
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
    
    /*******  isPostLikeByUser  *******/
    static func isPostLikeByUser(postId: String, uid: String, _ completion: @escaping (Bool) -> () ) {
        var isLiked = false
        let docRef = firestore().collection("posts").document(postId).collection("likes").document(uid)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                isLiked = true
                
            } else {
                print("Document does not exist")
            }
            completion(isLiked)
        }
        
    }
    
    
    /*******  didBookMarkPost  *******/
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
                    "uid": post.uid
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
        }
    }
    
    /*******  isPostBookMarkedByUser  *******/
    static func isPostBoookMarkedByUser(postId: String, uid: String, _ completion: @escaping (Bool) -> () ) {
        var isBookMarked = false
        let docRef = firestore().collection("posts").document(postId).collection("bookmarked").document(uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                let isBooked = document["BookMark"] as! Int
                if isBooked == 1 {
                    isBookMarked = true
                }
                else {
                    isBookMarked = false
                }
                
            } else {
                print("Document does not exist")
            }
            completion(isBookMarked)
        }
    }
    
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
    
    
    static func deletePost(postId : String){
          firestore().collection("posts").document(postId).delete()
    }
    
    
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

