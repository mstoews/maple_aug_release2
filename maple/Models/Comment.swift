//
//  Comment.swift
//  InstagramFirebase
//
//  Created by Murray Toews on 6/3/17.
//  Copyright © 2017 maple.com

import Foundation
import Firebase
struct Comment {
    
    let user: MapleUser
    let text: String
    let uid: String
    let username : String
    let profileImageUrl : String
    let creationDate: Date
    
    init(user: MapleUser, dictionary: [String: Any]) {
        self.user = user
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.username = user.username
        self.profileImageUrl = user.profileImageUrl
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
    
    init(dictionary: [String: Any]){
        let uid = dictionary["uid"] as! String
        self.user = MapleUser(uid: uid, dictionary: dictionary )
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["imageProfileUrl"] as? String ?? ""
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
