//
//  PostRecord.swift
//  maple-release
//
//  Created by Murray Toews on 2018/02/27.
//  Copyright © 2018 Murray Toews. All rights reserved.
//

import AlgoliaSearch
import InstantSearchCore
//import AFNetworking
import UIKit
import Firebase
import FirebaseFirestore

struct PostRecord {
    private let json: [String: Any]
    
    init(json: [String : Any]) {
        self.json = json
    }
    
    var product: String? {
        return json["product"] as? String
    }
    
    /**
        This little bit was put in only to handle the previous ios update to Algolia.
        The server functions should handle this going forward.
     
        Then we could just remove the top bit of the function for urlArray field in Algolia.
     **/
    
    
    var imageUrl: URL? {
        if let urlString = json["urlArray"] as? String {
             return URL(string: urlString)
        }
        else
        {
            return nil
        }
       
    }
    
    var objectID : String? {
        return json["objectID"] as? String
    }
    
    var description: String? {
        return json["description"] as? String
    }
    
    var name: String? {
        var rc  = "name"
        var bFound = false
        if let  name = json["name"] as? String {
            rc = name
            bFound = true
        }
        if bFound == false {
            if let name = json["product"] as? String {
                rc = name
                bFound = true
            }
        }
        return rc
    }
    
    var userId: String? {
        return json["userid"] as? String
    }
    
}

