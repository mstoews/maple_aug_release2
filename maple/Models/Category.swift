//
//  Category.swift
//  Maple
//
//  Created by Murray Toews on 2017-10-12.
//  Copyright © 2017 mapleon. All rights reserved.
//

import Foundation


struct Category {
    var id: Int?
    var Category1: String
    var Category2: String
    var Category3: String
    var Category4: String
    var Category5: String
    
    init(dictionary : [String: Any]) {
        self.id = dictionary["id"] as? Int ?? 0
        self.Category1 = dictionary["Category1"] as? String ?? ""
        self.Category2 = dictionary["Category2"] as? String ?? ""
        self.Category3 = dictionary["Category3"] as? String ?? ""
        self.Category4 = dictionary["Category4"] as? String ?? ""
        self.Category5 = dictionary["Category5"] as? String ?? ""
    }
    
}

struct Location {
    var id: Int?
    var Category1: String
    var Category2: String
    var Category3: String
    var Category4: String
    var Category5: String
    
    init(dictionary : [String: Any]) {
        self.id = dictionary["id"] as? Int ?? 0
        self.Category1 = dictionary["Category1"] as? String ?? ""
        self.Category2 = dictionary["Category2"] as? String ?? ""
        self.Category3 = dictionary["Category3"] as? String ?? ""
        self.Category4 = dictionary["Category4"] as? String ?? ""
        self.Category5 = dictionary["Category5"] as? String ?? ""
    }
    
}
