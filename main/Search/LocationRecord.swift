
//
//  LocationReocrd.swift
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

struct LocationRecord {
    
    
    private let json: [String: Any]
    
    init(json: [String : Any]) {
        self.json = json
    }

    
    var objectID : String {
        return (json["objectID"] as? String)!
    }
    
    var phoneNumber : String?  {
        return json["phoneNumber"] as? String
    }
    
    var latitude : Double? {
        return json["latitude"] as? Double
    }
    
    var longitude : Double? {
    return json["longitude"] as? Double
    }
    
    var web : String? {
    return json["web"] as? String
    }
    
    var rating : Double? {
        return json["rating"] as? Double
    }
    
    var address : String? {
        return json["address"] as? String
    }
    
    var place : String? {
    return json["place"] as? String
    }
    
    var priceLevel : String? {
    return json["priceLevel"] as? String
    }
    
    var types : String? {
    return json["types"] as? String
    }
}


/**
 This little bit was put in only to handle the previous ios update to Algolia.
 The server functions should handle this going forward.
 
 Then we could just remove the top bit of the function for urlArray field in Algolia.
 
 JsonObject
 
 phoneNumber:+81 3-5244-4995
 latitude:35.69522
 longitude:139.766283
 web:http://ysroad.co.jp/ochanomizu-ladieskan/
 rating:3.200000047683716
 creationDate:1524519727.252961
 address:Japan, 〒101-0052 Tōkyō-to, Chiyoda-ku, Kanda Ogawamachi, 1 Chome, １ 丁目 １−６−１ ２F
 place:Y's Road
 priceLevel:Unkown
 types:bicycle_store, store, point_of_interest, establishment
 objectID:-LAoSD4DwptgyVaiZNcn
 
 **/

