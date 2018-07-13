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
    
    var objectID : String? {
        return json["objectID"] as? String
    }
    
    var name : String? {
    return json["name"] as? String
    }
    
    var profileURL : String? {
    return json["profileImageUrl"] as? String
    }
}


/**
 **/

