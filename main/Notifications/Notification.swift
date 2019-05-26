//
//  Notification.swift
//  maple
//
//  Created by Dragon on 9/14/17.
//  Copyright © 2017 mapleon. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct NotificationObject {
    let date: Double
    let type: String
    let key: String
    let sender: String
    let content: String
    let postid: String
}

extension NotificationObject: DocumentSerializable {
    init?(dictionary: [String : Any], postId: String) {
        self.date = dictionary["date"] as? Double ?? 0.0
        self.type = dictionary["type"] as? String ?? ""
        self.key = dictionary["key"] as? String ?? ""
        self.sender = dictionary["sender"] as? String ?? ""
        self.content = dictionary["content"] as? String ?? ""
        self.postid = postId
    }
}

struct NotificationFireObject {
    let interactionRef : String                 //  "Lo5NKzTejmN7D97XcBKf"
    let interactionUser : String                // "7DCErnwbuDVSCPgHyOv3N6QmdcA3"
    let interactionUserProfilePicture : String  // "https://scontent.xx.fbcdn.net/v/t1.0-1/s100x100/12249987_10153692040753416_8783935911322461092_n.jpg?oh=2b713a5e8a2b7a65fd44baa733101ec7&oe=5A1A32B2"
    let interactionUserUsername : String        //"Murray Sinclair Toews"
    let kind : String                           //"like"
    let timestamp : Timestamp                   //August 6, 2018 at 2:09:47 PM UTC+9
}

extension NotificationFireObject: NotificationSerializable {
    init?(dictionary:  [String: Any] )
    {
        self.interactionRef = dictionary["interactionRef"] as? String ?? ""
        self.interactionUser = dictionary["interactionUser"] as? String ?? ""
        self.interactionUserProfilePicture = dictionary["interactionUserProfilePicture"] as? String ?? ""
        self.interactionUserUsername = dictionary["interactionUserUsername"] as? String ?? ""
        self.kind = dictionary["kind"] as? String ?? ""
        let date = Date.init()
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: date)
    }
    
}

var notifications = [NotificationObject]()
var notificationsFire = [NotificationFireObject]()


/*
interactionRef "Lo5NKzTejmN7D97XcBKf"
interactionUser "7DCErnwbuDVSCPgHyOv3N6QmdcA3"
interactionUserProfilePicture "https://scontent.xx.fbcdn.net/v/t1.0-1/s100x100/12249987_10153692040753416_8783935911322461092_n.jpg?oh=2b713a5e8a2b7a65fd44baa733101ec7&oe=5A1A32B2"
interactionUserUsername "Murray Sinclair Toews"
kind "like"
timestamp : August 6, 2018 at 2:09:47 PM UTC+9
*/
