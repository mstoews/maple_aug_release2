//
//  Locations.swift
//  Maple
//
//  Created by Murray Toews on 12/9/17.
//  Copyright © 2017 mapleon. All rights reserved.
//
import Foundation
import GooglePlaces

struct locObject {
    var place: GMSPlace?
}

extension locObject {
    init?(place : GMSPlace) {
        self.place = place
    }
}

struct  LocationObject {
    
    let postid: String?
    let location: String?
    let latitude: Double?
    let longitude: Double?
    let address: String?
    let creationDate: Date
    let phoneNumber: String?
    let priceLevel: String?
    let rating: String?
    let types: String?
    var place: GMSPlace?
    
}

extension LocationObject  {
    
    init?(postid: String,
         location: String,
         longitude: Double,
         latitude: Double,
         address: String,
         phoneNumber: String,
         priceLevel: String,
         rating: String,
         types: String)
    {
        self.postid     =  postid
        self.location   = location
        self.latitude   = latitude
        self.longitude  = longitude
        self.address    = address
        let secondsFrom1970 = 0.0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        self.phoneNumber  = phoneNumber
        self.priceLevel   = priceLevel
        self.rating       = rating
        self.types        = types
        
    }

    
    init?(dictionary : [String: Any]) {
        self.postid = dictionary["postId"]  as? String ?? ""
        self.location = dictionary["place"]  as? String ?? ""
        self.latitude = dictionary["latitude"]  as? Double ?? 0.0
        self.longitude = dictionary["longitude"]  as? Double ?? 0.0
        self.address    = dictionary["address"]  as? String ?? ""
        let secondsFrom1970 =  0.0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        self.phoneNumber  = dictionary["phoneNumber"]  as? String ?? ""
        self.priceLevel   = dictionary["priceLevel"]  as? String ?? ""
        self.rating       = dictionary["rating"]  as? String ?? ""
        self.types        = dictionary["types"]  as? String ?? ""
    }
    
    init?(postid: String, dictionary: [String: Any])
    {
        self.postid  = postid
        self.location = dictionary["place"]  as? String ?? ""
        self.latitude = dictionary["latitude"]  as? Double ?? 0.0
        self.longitude = dictionary["longitude"]  as? Double ?? 0.0
        self.address    = dictionary["address"]  as? String ?? ""
        let secondsFrom1970 =  0.0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        self.phoneNumber  = dictionary["phoneNumber"]  as? String ?? ""
        self.priceLevel   = dictionary["priceLevel"]  as? String ?? ""
        self.rating       = dictionary["rating"]  as? String ?? ""
        self.types        = dictionary["types"]  as? String ?? ""
    }
    
    init?(place: GMSPlace) {
        self.postid  = ""
        self.location = place.name
        self.latitude = place.coordinate.latitude
        self.longitude = place.coordinate.longitude
        self.address    = place.formattedAddress
        let secondsFrom1970 =  0.0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        self.phoneNumber  = place.phoneNumber
        self.priceLevel   = ""
        self.rating       = ""
        self.types        = ""
    }
    
}
