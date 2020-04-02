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
    var followersCount : Int
    var followedCount : Int
    var postCount : Int
  
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"]  as? String ?? ""
        self.firstName = dictionary["firstName"] as? String ?? ""
        self.lastName = dictionary["lastName"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.followedCount = dictionary["followedCount"] as? Int  ?? 0
        self.followersCount = dictionary["followerCount"] as? Int  ?? 0
        self.postCount = dictionary["postCount"] as? Int ?? 0
    }
}

var followers: [MapleUser]?
var likers: [MapleUser]?
var commenters: [MapleUser]?

struct User {
    
    // defining our properties for our model layer
    var name: String?
    var age: Int?
    var profession: String?
//    let imageNames: [String]
    var imageUrl1: String?
    var imageUrl2: String?
    var imageUrl3: String?
    var uid: String?
    
    var minSeekingAge: Int?
    var maxSeekingAge: Int?
    
    init(dictionary: [String: Any]) {
        // we'll initialize our user here
        self.age = dictionary["age"] as? Int
        self.profession = dictionary["profession"] as? String
        self.name = dictionary["fullName"] as? String ?? ""
        self.imageUrl1 = dictionary["imageUrl1"] as? String
        self.imageUrl2 = dictionary["imageUrl2"] as? String
        self.imageUrl3 = dictionary["imageUrl3"] as? String
        self.uid = dictionary["uid"] as? String ?? ""
        self.minSeekingAge = dictionary["minSeekingAge"] as? Int
        self.maxSeekingAge = dictionary["maxSeekingAge"] as? Int
    }
    
//    func toCardViewModel() -> CardViewModel {
//        let attributedText = NSMutableAttributedString(string: name ?? "", attributes: [.font: UIFont.systemFont(ofSize: 32, weight: .heavy)])
//        
//        let ageString = age != nil ? "\(age!)" : "N\\A"
//        
//        attributedText.append(NSAttributedString(string: "  \(ageString)", attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .regular)]))
//
//        let professionString = profession != nil ? profession! : "Not available"
//        attributedText.append(NSAttributedString(string: "\n\(professionString)", attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .regular)]))
//
//        var imageUrls = [String]() // empty string array
//        if let url = imageUrl1 { imageUrls.append(url) }
//        if let url = imageUrl2 { imageUrls.append(url) }
//        if let url = imageUrl3 { imageUrls.append(url) }
//        
//        return CardViewModel(uid: self.uid ?? "", imageNames: imageUrls, attributedString: attributedText, textAlignment: .left)
//    }
}









