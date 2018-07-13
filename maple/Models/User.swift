//
//  User.swift
//  InstagramFirebase
//
//  Created by Murray Toews on 6/3/17.
//  Copyright © 2017 maple.com
import Foundation

struct MapleUser {
    
    var uid: String
    var username: String
    var profileImageUrl: String
    var firstName: String
    var lastName : String
    var email : String
  
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"]  as? String ?? ""
        self.firstName = dictionary["firstName"] as? String ?? ""
        self.lastName = dictionary["lastName"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
    }
}

var followers: [MapleUser]?
var likers: [MapleUser]?
var commenters: [MapleUser]?






