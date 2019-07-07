//
//  Situation.swift
//  Maple
//

import Foundation

struct NavigationStruct {
    var currentLocationLatitude: Double?
    var currentLocationLongitude: Double?
    
    var destinationLocationLatitude: Double?
    var destinationLocationLongitude: Double?
    
    var Title: String
    var SubTitle: String
    
    init(dictionary : [String: Any]) {
        self.currentLocationLatitude = dictionary["currentLat"] as? Double ?? 0.0
        self.currentLocationLongitude = dictionary["currentLng"] as? Double ?? 0.0
        self.destinationLocationLatitude = dictionary["destinationLat"] as? Double ?? 0.0
        self.destinationLocationLongitude = dictionary["destinationLng"] as? Double ?? 0.0
        self.Title = dictionary["Title"] as? String ?? ""
        self.SubTitle = dictionary["SubTitle"] as? String ?? ""
    }
    
}
