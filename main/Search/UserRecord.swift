//
//  UserRecord.swift
//  maple_release
//
//  Created by Murray Toews on 2018/05/11.
//  Copyright © 2018 Murray Toews. All rights reserved.
//

import AlgoliaSearch
import InstantSearchCore
//import AFNetworking
import UIKit
import Firebase
import FirebaseFirestore


struct UserRecord {
    
    private let json: [String: Any]
    
    init(json: [String : Any]) {
        self.json = json
    }

    var full_name: String? {
        return json["full_name"] as? String
    }
    var reversed_full_name: String? {
        return json["reversed_full_name"] as? String
    }
    var followCount: Int? {
        return json["followCount"] as? Int
    }
    var followedCount: Int? {
        return json["followedCount"] as? Int
    }
    var followerCount: Int? {
        return json["followerCount"] as? Int
    }
    var notificationEnabled: String? {
        return json["notificationEnabled"] as? String
    }
    var postCount: Int? {
        return json["postCount"] as? Int
    }
    var profileImageUrl: String? {
        return json["profileImageUrl"] as? String
    }
    var username: String? {
        return json["username"] as? String
    }
    var objectID: String? {
        return json["objectID"] as? String
    }
}


/**
 "full_name": "asumi saito",
 "reversed_full_name": "SaitoAsumi",
 "followCount": 4,
 "followedCount": 2,
 "followerCount": 3,
 "messagingTokens": "dQtcqtfh6Ig:APA91bFPwwTocjif97zMhcAI1QEIGymZngoT4yxuL3_5HlKGaPu_kjANr6BCrxU5S_bbxF63vA9bQgPl4VlWhGTPQCepWNKAPy8J0R4aErr3ZCFzeN_R6iATPj5XZZbdknL5iiOgpUe-",
 "notificationEnabled": true,
 "postCount": 6,
 "profileImageUrl": "https://lh6.googleusercontent.com/-SjEC5SPZaXY/AAAAAAAAAAI/AAAAAAAAAAo/60OFKR6us9Y/s96-c/photo.jpg",
 "token": "dQtcqtfh6Ig:APA91bFPwwTocjif97zMhcAI1QEIGymZngoT4yxuL3_5HlKGaPu_kjANr6BCrxU5S_bbxF63vA9bQgPl4VlWhGTPQCepWNKAPy8J0R4aErr3ZCFzeN_R6iATPj5XZZbdknL5iiOgpUe-",
 "username": "Asumi Saito",
 "objectID": "qhEVhyp2FPcgtBbicAcAEf8XnQa2"
 **/

