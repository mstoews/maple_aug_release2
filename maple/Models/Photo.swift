//
//  Photo.swift
//  maple
//
//  Created by Murray Toews on 2017-08-07.
//  Copyright © 2017 mapleon. All rights reserved.
//

import Foundation

struct Photo {
    
    var id: String?
    var index: Int
    var imageUrl: String
    
    init(index: Int, image: String) {
        self.index = index
        self.imageUrl = image
    }
}


