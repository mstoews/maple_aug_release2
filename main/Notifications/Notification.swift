//
//  Notification.swift
//  maple
//
//  Created by Dragon on 9/14/17.
//  Copyright © 2017 mapleon. All rights reserved.
//

import Foundation

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

var notifications = [NotificationObject]()
