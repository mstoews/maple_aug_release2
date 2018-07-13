//
//  Situation.swift
//  Maple
//
//  Created by Murray Toews on 2017-10-12.
//  Copyright © 2017 mapleon. All rights reserved.
//

import Foundation


struct Situation {
    var id: Int?
    var Situation: String
    
    init(dictionary : [String: Any]) {
        self.id = dictionary["id"] as? Int ?? 0
        self.Situation = dictionary["Situation"] as? String ?? ""
    }
    
}
