//
//  Post.swift
//  InstagramFirebase
//
//  Created by Murray Toews on 6/3/17.
//  Copyright © 2017 maple.com

import Foundation
import Firebase


struct PostSearch {
    
    var id: String?
    
    var userId: String
    var caption: String
    let situation: String
    let category: String
    let description: String
    var creationDate: Date
    
    init(userId: String, dictionary: [String: Any]) {
        self.userId = userId
        self.caption = dictionary["product"] as? String ?? ""
        self.category = dictionary["category"] as? String ?? ""
        self.situation = dictionary["situation"]  as? String ?? ""
        self.description = dictionary["description"] as? String ?? ""
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}


struct PostStruct {
    var id: String?
    var user: User
    var caption: String
    let location: String
    let situation: String
    let category: String
    let description: String
    
    var imageUrlArray : [String]
    var hasLiked = false
    var hasBookmark = false
    var hasComment = false 
    var creationDate: Date
    var noOfLikes: Int?
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.location = dictionary["location"] as? String ?? ""
        self.caption = dictionary["product"] as? String ?? ""
        self.category = dictionary["category"] as? String ?? ""
        self.situation = dictionary["situation"]  as? String ?? ""
        self.description = dictionary["description"] as? String ?? ""
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.imageUrlArray = dictionary["imageUrlArray"] as? [String] ?? [""]
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}

class  Post {
    var id: String?
    
    var user: MapleUser
    var imageUrl: String
    var caption: String
    var creationDate: Date
    var description: String
    var related_product = ""
    
    var noOfLikes: Int = 0
    var noOfComments: Int = 0
    var noOfBookMarks: Int = 0
    
    var imageUrlArray = [String]()
    var largeUrlArray = [String]()
    var imageObjects = [ImageObject]()
    var locationObjects = [LocationObject]()
    //var comments : [FPComment]
    
    var hasLiked = false
    var hasBookmark = false
    var hasComments = false
    
    var isLiked = false
    var mine = false
    var likeCount = 0
    
    
    init(user: MapleUser , dictionary: [String: Any])
    {
        self.user = user
        //self.id = dictionary["id"] as? String ?? ""
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.caption = dictionary["product"] as? String ?? ""
        self.description = dictionary["description"] as? String ?? ""
        self.related_product = dictionary["related_product"] as? String ?? ""
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        let imageUrlData = dictionary["imagesUrl"] as? [String:AnyObject]
        //self.comments = comments
    
        if imageUrlData != nil {
            imageUrlData?.forEach({ (key, value) in
                let urldata = value as! [String: AnyObject]
                let url = urldata["url"] as! String
                self.imageUrlArray.append(url)
            })
        }
        
        let largeImageData = dictionary["imagesLarge"] as? [String:AnyObject]
        if largeImageData != nil {
            largeImageData?.forEach({(key,value) in
                let urlData = value as! [String : AnyObject]
                let url = urlData["url"] as! String
                self.largeUrlArray.append(url)
            })
        }
        
        let locationData = dictionary["locations"] as? [String:AnyObject]
        if  locationData != nil {
            locationData?.forEach({ (key, value) in
                let locData = value as! [String: AnyObject]
                self.locationObjects.append(LocationObject(postid: key , dictionary: locData)!)
            })
        }
        
        if let likesData = dictionary["likes"] as? [String: Any] {
            likesData.forEach({ (key,value) in
                self.hasLiked = true
                self.noOfLikes = self.noOfLikes + 1
            })
        }
        else{
            self.hasLiked = false
        }
        
        if let Data = dictionary["comments"] as? [String: Any] {
                Data.forEach({ (key,value) in
                    self.noOfComments = self.noOfComments + 1
            })
        }
        else{
            self.hasComments = false
        }
        
        if let Data = dictionary["bookmarked"] as? [String: Any] {
                Data.forEach({ (key,value) in
                self.hasBookmark = true
                self.noOfBookMarks = self.noOfBookMarks + 1
            })
        }
        else{
            self.hasBookmark = false
        }
    
    }
    
    init(user: MapleUser, uid: String, dictionary: [String: Any])
    {
        self.user = user
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.caption = dictionary["product"] as? String ?? ""
        self.description = dictionary["description"] as? String ?? ""
        self.related_product = dictionary["related_product"] as? String ?? ""
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        let imageUrlData = dictionary["imagesUrl"] as? [String:AnyObject]
        //self.comments = comments
        
        
        if imageUrlData != nil {
            imageUrlData?.forEach({ (key, value) in
                let urldata = value as! [String: AnyObject]
                let url = urldata["url"] as! String
                self.imageUrlArray.append(url)
            })
        }
        
        let largeImageData = dictionary["imagesLarge"] as? [String:AnyObject]
        if largeImageData != nil {
            largeImageData?.forEach({(key,value) in
                let urlData = value as! [String : AnyObject]
                let url = urlData["url"] as! String
                self.largeUrlArray.append(url)
            })
        }
        
        let locationData = dictionary["locations"] as? [String:AnyObject]
        if  locationData != nil {
            locationData?.forEach({ (key, value) in
                let locData = value as! [String: AnyObject]
                self.locationObjects.append(LocationObject(postid: key , dictionary: locData)!)
            })
        }
        
        if let likesData = dictionary["likes"] as? [String: Any] {
            likesData.forEach({ (key,value) in
                self.hasLiked = true
                self.noOfLikes = self.noOfLikes + 1
            })
        }
        else{
            self.hasLiked = false
        }
        
        if let Data = dictionary["comments"] as? [String: Any] {
            Data.forEach({ (key,value) in
                self.noOfComments = self.noOfComments + 1
            })
        }
        else{
            self.hasComments = false
        }
        
        if let Data = dictionary["bookmarks"] as? [String: Any] {
            Data.forEach({ (key,value) in
                self.hasBookmark = true
                self.noOfBookMarks = self.noOfBookMarks + 1
            })
        }
        else{
            self.hasBookmark = false
        }
        
    }
}


struct FSPost {
    var id: String?
    
    var imageUrl: String
    var product: String
    var creationDate: Date
    var description: String
    var related_product = ""
    var profileURL : String
    var userName : String
    var category : String
    
    var noOfLikes = 0
    var noOfComments = 0
    var noOfBookMarks = 0
    
    var imageUrlArray = [String]()
    var largeUrlArray = [String]()
    var imageObjects = [ImageObject]()
    var locationObjects = [LocationObject]()
    //var comments : [FPComment]
    
    var hasLiked = false
    var hasBookmark = false
    var hasComments = false
    
    var isLiked = false
    var isBookmarked = false
    var mine = false
    var likeCount = 0
    var commentCount = 0
    var uid: String
    
    
}

extension FSPost: DocumentSerializable {
    init?(dictionary: [String: Any], postId : String)
    {
        self.id = postId
        self.userName = dictionary["name"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.product = dictionary["product"] as? String ?? ""
        self.description = dictionary["description"] as? String ?? ""
        self.related_product = dictionary["related_product"] as? String ?? ""
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        self.profileURL = dictionary["profileUrl"] as? String ??  ""
        self.category = dictionary["category"] as? String ?? "General"
        self.likeCount = dictionary["numberOfLikes"] as? Int ?? 0
        self.commentCount = dictionary["numberOfComments"] as? Int ?? 0
        
        dictionary.forEach({ (key, value) in
            guard let dict = value as? [String] else { return }
            if key == "thumbImages" {
                for url in dict {
                    //print("Key: \(key) URL: \(url)")
                    self.imageUrlArray.append(url)
                }
            }

            if key == "originalImages" {
                for url in dict {
                    //print("Key: \(key) URL: \(url)")
                    self.largeUrlArray.append(url)
                }
            }
        })
    }
}
    
extension Post: Equatable {
    static func ==(lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }
}

var  postbyUser: [Post]?

extension FSPost: Equatable {
    static func ==(lhs: FSPost, rhs: FSPost) -> Bool {
        return lhs.id == rhs.id
    }
}


