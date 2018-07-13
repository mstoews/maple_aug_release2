//
//  FirebaseUtils.swift
//  Toews Maple
//
//  Created by Murray  06/12/2017.
//  Copyright © 2017 MurrayToews. All rights reserved.
//

import Foundation
import Firebase
import GoogleMaps
import GooglePlaces


extension Database {
    
    static func fetchUserWithUID(uid: String, completion: @escaping (MapleUser) -> ()) {
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let userDictionary = snapshot.value as? [String: Any] else { return }
                    let user = MapleUser(uid: uid, dictionary: userDictionary)
                    completion(user)
        }) { (err) in
            print("Failed to fetch user for posts:", err)
        }
    }
    
   
    static func fetchAllUser(completion: @escaping ([MapleUser]) -> ()) {
        var userArray = [MapleUser]()
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            userDictionary.forEach({ (key,value) in
                guard let userData = value as? [String: Any] else {return}
                let user = MapleUser(uid: key,  dictionary: userData)
                userArray.append(user)
            })
             completion(userArray)
        }) { (err) in
            print("Failed to fetch user for posts:", err)
        }
    }
    
    
    
    static func fetchImageByUidPost(_ uid: String , _ postId: String, _ completion: @escaping ([ImageObject]) -> () ){
        var imageObjectArray = [ImageObject]()
        Database.database().reference().child("imagebypost").child(uid).child(postId).observeSingleEvent(of: .value, with: { (snapshot) in
             guard let imageObjectData = snapshot.value as? [String: Any] else { return }
             imageObjectData.forEach({ (key, value) in
                guard  let urldata = value as? [String: Any] else {return}
                let imageId = key as String
                let url = urldata["url"] as! String
                let imageObject = ImageObject(postid: postId, imageid: imageId,  url: url)
                imageObjectArray.append(imageObject)
             })
            completion(imageObjectArray)
        })
    }
    

    static func fetchImagesByRanking(completion: @escaping ([ImageObject]) -> () ){
        var imageObjectArray = [ImageObject]()
        var postId : String?
        Database.database().reference().child("imagebypost").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userData = snapshot.value as? [String: Any] else { return }
            userData.forEach({ (key, value) in
                print("User ID : \(key)")
                guard let imageData = value as? [String: Any] else { return }
                imageData.forEach({ (key,value) in
                    print("Post id \(key)")
                    postId = key
                    guard let imageObjectData = value as? [String: Any] else { return }
                    imageObjectData.forEach({ (key,value) in
                        guard  let urldata = value as? [String: Any] else {return}
                        let imageId = key as String
                        let url = urldata["url"] as! String
                        let imageObject = ImageObject(postid: postId!, imageid: imageId,  url: url)
                        imageObjectArray.append(imageObject)
                    })
                })
            })
            completion(imageObjectArray)
        })
    }
    
    
    func isPostLikebyUser (uid: String, postId: String, _ completion: @escaping (Int)->()) {
        Database.database().reference().child("likes").child(postId).child(uid).child("likes").observeSingleEvent(of: .value) {
            (snapshot) in
              var rc = 1
              guard let likeData = snapshot.value as? [String: Any] else { return }
              likeData.forEach({ (key, value) in
                rc = 0
              })
          completion(rc)
        }
    }
    
    
    /*
     Database.database().reference().child("followers").child(userId).observe( .value, with: { (snapshot) in
     if let data = snapshot.value as? [String: AnyObject] {
     */
    
    static func fetchNumberOfLikesByPostId(postid: String, _ completion: @escaping (Int)->()) {
        var likes = 0
        //Database.database().reference().child("likes").child(postid).observeSingleEvent(of: .value) { (snapshot) in
        Database.database().reference().child("likes").child(postid).observe( .value, with: { (snapshot) in
            likes = 0
            guard let likeData = snapshot.value as? [String: Any] else { return }
            likeData.forEach({ (key, value) in
                guard  let likedUser = value as? [String: Any] else {return}
                likedUser.forEach({ (key,value)  in
                    guard let liked = value as? [String : Any] else {return}
                    liked.forEach({ (key,value) in
                        let likedPost = value as? Bool
                        if likedPost == true {
                            likes = likes + 1
                        }
                    })
                })
            })
            completion(likes)
        })
    }
    
    static func fetchPostNumberOfComments(postid: String, _ completion: @escaping (Int)->()) {
        var numberOfComments = 0
        Database.database().reference().child("comments").child(postid).observe( .value, with: { (snapshot) in
            if let likeData = snapshot.value as? [String: Any] {
                numberOfComments = likeData.count
                completion(numberOfComments)
            }
            else
            {
                completion(numberOfComments)
            }
        })
    }
    
    static func fetchPostNumberofBookmarks(postid: String, _ completion: @escaping (Int)->()) {
        var numberOfBookmarks = 0
        Database.database().reference().child("bookmarks").child(postid).observe( .value, with: { (snapshot) in
            numberOfBookmarks = 0
             guard let likeData = snapshot.value as? [String: Any] else { return }
                likeData.forEach({ (key, value) in
                    let likes = value as! Int
                    numberOfBookmarks = numberOfBookmarks + likes
                })
             completion(numberOfBookmarks)
            })
            completion(numberOfBookmarks)
    }
    
    static func isPostBookMarked(postid: String, uid: String, _ completion: @escaping (String)->()) {
        Database.database().reference().child(uid).child("bookmarks").child(postid).observe( .value, with: {
            (snapshot) in
            let bookMarked = "NA"
            guard let likeData = snapshot.value as? [String: Any] else { return }
            likeData.forEach({ (key, value) in
                
            })
            completion(bookMarked)
        })
    }
    
    static func fetchLocationByPostId( _ postId: String, _ completion: @escaping ([LocationObject]) -> () ){
        var locationObjects = [LocationObject]()
        Database.database().reference().child("locations").child(postId).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let locationData = snapshot.value as? [String: Any] else { return }
            locationData.forEach({ (key, value) in
                if let data = value as? [String: Any] {
                    let imageObject = LocationObject(postid: key , dictionary: data)
                    locationObjects.append(imageObject!)
                }
            })
            completion(locationObjects)
        })
    }
    
   
    
//    static func fetchMapsByPostId( _ postId: String, _ completion: @escaping ([LocationObjects]) -> () ){
//        var mapObjects = [LocationObjects]()
//        Database.database().reference().child("locations").child(postId).observeSingleEvent(of: .value, with: { (snapshot) in
//            guard let locationData = snapshot.value as? [String: Any] else { return }
//            locationData.forEach({ (key, value) in
//                guard  let data = value as? [String: Any] else {return}
//                let location = data["place"] as! String
//                let latitude = data["latitude"] as! Double
//                let longitude = data["longitude"] as! Double
//                let gmsPlace = GMSPlace()
//                gmsPlace.name = location
//                gmsPlace.coordinate.latitude = Double(latitude)
//                gmsPlace.coordinate.longitude = Double(longitude)
//                let mapObject = LocationObject(postId: postId, place: gmsPlace )
//                mapObjects.append(LocationObject)
//            })
//            completion(mapObjects)
//        })
//    }
//    
//    
    
    
    static func fetchLocation(completion: @escaping ([LocationObject])-> ()) {
        var locationObjects = [LocationObject]()
        Database.database().reference().child("locations").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let locationData = snapshot.value as? [String: Any] else { return }
            locationData.forEach({ (key, value) in
                guard  let data = value as? [String: Any] else {return}
                let imageObject = LocationObject(postid: key, dictionary: data )
                locationObjects.append(imageObject!)
            })
        })
        completion(locationObjects)
    }
    
    
    static func fetchLocationByUser( _ uid : String , _ completion: @escaping ([LocationObject]) -> () ){
        var locationObjects = [LocationObject]()
        Database.database().reference().child("locationsByUid").child(uid).observeSingleEvent(of: .value, with: {(snapshot) in
            guard let PostData = snapshot.value as? [String: Any] else { return }
            PostData.forEach({ (key, value) in
                 guard  let data = value as? [String: Any] else { return }
                let imageObject = LocationObject(postid: key, dictionary: data)
                locationObjects.append(imageObject!)
            })
          completion(locationObjects)
        })
     }
    
    
    static func fetchImageByUidAndPost(_ uid: String , _ postId: String, _ completion: @escaping (NSDictionary) -> () ){
        Database.database().reference().child("imagebypost").child(uid).child(postId).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let imageObjectData = snapshot.value as? NSDictionary else { return }
            completion(imageObjectData)
        })
    }
   
    
    
    static func fetchPostSearchImageByUserPost( uid: String , postId: String, completion: @escaping (String) -> () )
    {
        let urlString = "urlString"
        print("User id: " + uid +  "  Post Id: " + postId)
        Database.database().reference().child("posts").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            dictionary.forEach({ (key, value) in
                guard value is [String: Any] else { return }
            })
        })
        completion(urlString)
}
    
    
    static func fetchImageByUid(_ user: User , completion: @escaping ([ImageObject]) -> () ){
        var images = [ImageObject]()
        Database.database().reference().child("imagebypost").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let imagesUrlData = snapshot.value as? [String: Any] else { return }
            imagesUrlData.forEach({ (key, value) in
                let postId = key
                guard  let urldata = value as? [String: Any] else {return}
                    urldata.forEach({ (key, value) in
                        guard let dictionary = value as? [String: Any] else { return }
                        let urlString = dictionary["url"] as! String
                        let io = ImageObject(postid: postId , imageid: key , url: urlString)
                        //io.thumb = io.createThumb(url: urlString)
                        images.append(io)
                    })
            })
            completion(images)
        })
    }
    
    
    static func fetchUserFollowingByUserId(userId: String, completion: @escaping ([String]) -> ())
    {
        var userList = [String]()
        Database.database().reference().child("following").child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            dictionaries.forEach({ (key, value) in
                if key == Auth.auth().currentUser?.uid {
                    print("Found myself, omit from list")
                }
                else {
                    let follow = value as! Int
                    if follow == 1 {
                        userList.append(key)
                    }
                }
            })  
            completion(userList)
        }) { (err) in
            print("Failed to fetch users for search:", err)
        }
        
        return
    }
    
    
    
    static func fetchUserFollowersByUserId(userId: String, completion: @escaping ([String]) -> ())
    {
        var userList = [String]()
        Database.database().reference().child("followers").child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            dictionaries.forEach({ (key, value) in
                if key == Auth.auth().currentUser?.uid {
                    print("Found myself, omit from list")
                }
                else {
                    let follow = value as! Int
                    if follow == 1 {
                        userList.append(key)
                    }
                }
            })
            completion(userList)
        }) { (err) in
            print("Failed to fetch users for search:", err)
        }
        
        return
    }
    
    static func fetchImageByUidDict(_ user: User , completion: @escaping ((NSDictionary)) -> () ){
        Database.database().reference().child("imagebypost").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let imagesUrlData = snapshot.value as? [String: Any] else { return }
            imagesUrlData.forEach({ (key, value) in
                //let postId = key
                guard  let urldata = value as? NSDictionary else {return}
                completion(urldata)

            })
        })
    }
    
    
    static func fetchPost(uid: String , postId: String, completion: @escaping (Post) -> () ){
        var post : Post?
        Database.fetchUserWithUID(uid: uid) { (user) in
            //var post = Post(user: user)
            let ref = Database.database().reference().child("posts/\(uid)/\(postId)")
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionaries = snapshot.value as? [String: Any] else { return }
                dictionaries.forEach({ (key, value) in
                    guard let dictionary = value as? [String: Any] else { return }
                    post = Post(user: user, dictionary: dictionary)
                    completion(post!)
                    })
            },withCancel: { (err) in
                print("Failed to fetch like info for post:", err)
            })
        }
    }
   

    
    static func fetchPostByUidPostId(uid: String , postId: String, completion: @escaping (FSPost) -> ()) {
        Database.fetchUserWithUID(uid: uid) { (user) in
            let postRef = Database.database().reference().child("posts/\(uid)/\(postId)")
              postRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                var post = FSPost( dictionary: dictionary, postId: postId)
                post?.id = postId
                completion(post!)
            })
        }
    }
    
    
    static func fetchSinglePostByUidPostId(uid: String , postId: String, completion: @escaping (FSPost) -> ()) {
        Database.fetchUserWithUID(uid: uid) { (user) in
                let postRef = Database.database().reference().child("posts/\(uid)/\(postId)")
                postRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                var post = FSPost( dictionary: dictionary, postId: postId)
                post?.id = postId
                completion(post!)
            })
        }
    }
    

    static func fetchPosts(completion: @escaping ([PostSearch]) ->()) {
        var posts = [PostSearch]()
        let ref = Database.database().reference().child("posts")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            dictionary.forEach({ (key, value) in
                guard let dict = value as? [String: Any] else {return }
                dict.forEach({(key,value) in
                    guard let postDict = value as? [String: Any] else {return }
                    let post = PostSearch(userId: key, dictionary: postDict)
                    posts.append(post)
                })
            })
            
        }, withCancel: { (err) in
            print("Failed to fetch like info for post:", err)
        })
        completion(posts)
        
    }

    
        
    static func getNumberOfFollowers(userId: String, _ completion: @escaping (Int) -> ())
    {
        print("Get the number of followers...", userId)
        var iFollowing = 0
        Database.database().reference().child("followers").child(userId).observe( .value, with: { (snapshot) in
            if let data = snapshot.value as? [String: AnyObject] {
                data.forEach({(key, value) in
                    if value as! Int == 1 {
                        iFollowing  = iFollowing + 1
                    }
                })
                completion(iFollowing)
            }
        }, withCancel: { (err) in
            print("Failed to check if followers:", err)
        })
    }

    static func getNumberOfPosts(userId: String, _ completion: @escaping (Int) -> ())
    {
        print("Get number of posts...", userId)
        var iPosts = 0
        var value: NSDictionary?

        Database.database().reference().child("posts").child(userId).observe( .value, with: { (snapshot) in
                value = snapshot.value as? NSDictionary
                if (value?.count != nil){
                    iPosts = (value?.count)!
                }
                else{
                    iPosts = 0

            }
            print("Adding followers for \(userId) : \(iPosts)" )
            completion(iPosts)
        }, withCancel: { (err) in
            print("Failed to check if posts:", err)
        })
        return
    }



    static func getNumberOfFollowing(userId: String, _ completion: @escaping (Int) -> ())
    {
        print("Get the number of followers...", userId)
        var iFollowing = 0
        Database.database().reference().child("following").child(userId).observe( .value, with: { (snapshot) in
            if let data = snapshot.value as? [String: AnyObject] {
                data.forEach({(key, value) in
                    if value as! Int == 1 {
                        iFollowing  = iFollowing + 1
                    }
                })
                completion(iFollowing)
            }
        }, withCancel: { (err) in
            print("Failed to check if followers:", err)
        })
    }
    
    static func updateFollowers(userId: String, followingUserId: String, follow: Int)
    {
        let ref = Database.database().reference().child("followers").child(userId)
        
        let values = [followingUserId: follow]
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                print("Failed to follow user:", err)
                return
            }
            print("Successfully \(userId) is following : \(followingUserId)")
        }
        
        Firestore.firestore().collection("users").document(userId).setData(values)
        { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Successfully \(userId) is following : \(followingUserId)")
            }
        }
        
    }

    
    static func isUserBeingFollowedByUser(userId : String, userFollowing: String, _ completion: @escaping (String) -> ())
    {
        Database.database().reference().child("following").child(userId).child(userFollowing).observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? [String: AnyObject] {
                data.forEach({(key, value) in
                    if value as! Int == 1 {
                       completion("Followed")
                    }
                })
                completion("")
            }
        }, withCancel: { (err) in
            print("Failed to check if following:", err)
        })
    }
    
    static func updateFollowing(userId: String, followingUserId: String, follow: Int)
    {
        let ref = Database.database().reference().child("following").child(userId)
        
        let values = [followingUserId: follow]
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                print("Failed to follow user:", err)
                return
            }
            print("Successfully \(userId) is following : \(followingUserId)")
        }
        
        Firestore.firestore().collection("users").document(userId).setData(values)
        { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Successfully \(userId) is following : \(followingUserId)")
            }
        }
        
    }
    
    
   
    
    static func fetchOccations(completion: @escaping ([String])->()) {
        var occationArray = [String]()
        
        Database.database().reference().child("occations").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if  let data = snapshot.value as? [String: Any]
            {
                data.forEach({ (key, value) in
                    guard let dictionary = value as? [String: Any] else { return }
                    let occation = dictionary["occation"] as! String
                    occationArray.append(occation)
                })
                completion(occationArray)
            }
        })
       
    }
    
    
    static func fetchProducts(completion: @escaping ([String])->()) {
        var productArray = [String]()
        Database.database().reference().child("products").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if let data = snapshot.value as? [String: Any]
            {
                data.forEach({ (key, value) in
                    guard let dictionary = value as? [String: Any] else { return }
                    let product = dictionary["product"] as! String
                    productArray.append(product)
                })
                completion(productArray)
            }
        })
        
    }
    
    static func fetchCategory(completion: @escaping ([String])->()) {
        var categoryArray = [String]()
        Database.database().reference().child("category").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if let data = snapshot.value as? [String: Any]
            {
                data.forEach({ (key, value) in
                    categoryArray.append(key)
                })
                completion(categoryArray)
            }
        })
        
    }
    
    
    
    static func IsPostLiked(_ postid: String, _ uid: String, completion: @escaping (Int)->()) {
        var liked = 0
        let ref = Database.database().reference().child("likes").child(postid).child("likes").child(uid)
        ref.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let like = (dictionary["likes"] as? Int)!
            
            if like == 1 {
                liked = 1
                completion(liked)
            }
            else
            {
                liked = 0
                completion(liked)
            }
            print ("Liked value for \(uid) is \(liked)")
            completion(liked)
        })
        { (err) in
            print("Failed to observe likes")
        }
    }

    func isBookMarked(_ postid: String, _ uid: String, completion: @escaping (Int)->()) {
        var bookmarked = 0
        let ref = Database.database().reference().child("bookmarks").child(uid).child(postid)
        ref.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let mark = (dictionary["bookMarked"] as? Int)!
            
            if mark == 1 {
                bookmarked = 1
            }
            else
            {
                bookmarked = 0
            }
            print("Bookmarked value :\(bookmarked)")
            completion(bookmarked)
        })
        { (err) in
            print("Failed to observe bookmarks")
        }
    }

    static func fetchLikeUsersWithPostId(_ postIds: [String], completion: @escaping (String) -> ()) {
        var totalLike = 0
        var maxLike = 0
        if let uid = Auth.auth().currentUser?.uid {
            for postId in postIds {
                Database.database().reference().child("likes").child(postId).child(uid).child("likes").observeSingleEvent(of: DataEventType.value, with: {
                    (snapshot) in
                    if let data = snapshot.value as? [String: AnyObject] {
                        for liker in data {
                            if liker.value as! Bool == true {
                                maxLike += 1
                                let likerUid = liker.key
                                self.fetchUserWithUID(uid: likerUid, completion: { (liker) in
                                    totalLike += 1
                                    likers?.append(liker)
                                    let todayTimestamp = Int64(Date().timeIntervalSince1970)
                                    let content = liker.username + " liked your post"
                                    let notification = NotificationObject(date: Double(todayTimestamp), type: "likes", key: postId, sender: liker.uid, content: content, postid: postId)
                                    notifications.append(notification)
                                    if maxLike == totalLike {
                                        completion("success")
                                    }
                                })
                            }
                        }
                    }
                })
            }
        }
    }
    
    static func fetchCommentUsersWithUID(_ uid: String, completion: @escaping (String) -> ()) {
        var postIds: [String] = []
        Database.database().reference().child("posts").child(uid).observeSingleEvent(of: DataEventType.value, with: {
            (snapshot) in
            if let data = snapshot.value as? [String: AnyObject] {
                for post in data.keys {
                    postIds.append(post)
                }
                self.fetchCommentUsersWithPostId(postIds, completion:{
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
    
    static func fetchCommentUsersWithPostId(_ postIds: [String], completion: @escaping (String) -> ()) {
        var totalComment = 0
        var maxComment = 0
        for postId in postIds {
            Database.database().reference().child("comments").child(postId).observeSingleEvent(of: DataEventType.value, with: {
                (snapshot) in
                if let data = snapshot.value as? [String: AnyObject] {
                    for item in data {
                        maxComment += 1
                        let comment = item.value as! [String: AnyObject]
                        var content = ""
                        var commenterUid = ""
                        var todayTimestamp = Int64(Date().timeIntervalSince1970)
                        comment.forEach({ (key, value) in
                            switch key {
                            case "text":
                                content = value as! String
                                break
                            case "uid":
                                commenterUid = value as! String
                                break
                            case "creationDate":
                                todayTimestamp = Int64(value as! Double)
                                break
                            default:
                                break
                            }
                        })
                        
                        self.fetchUserWithUID(uid: commenterUid, completion: { (commenter) in
                            totalComment += 1
                            commenters?.append(commenter)
                            let notification = NotificationObject(date: Double(todayTimestamp), type: "comments", key: postId, sender: commenter.uid, content: content, postid: postId)
                            notifications.append(notification)
                            if maxComment == totalComment {
                                completion("success")
                            }
                        })
                    }
                }
            })
        }
    }
    
  
}


