//
//  SinglePhotoPost.swift
//  maple-release
//
//  Created by Murray Toews on 2018/02/10.
//  Copyright © 2018 Murray Toews. All rights reserved.
//

import Foundation



struct SinglePhotoPost {
    var caption: String
    var imageUrl: String
    var description: String
    
    init(caption: String, description: String, imageUrl: String) {
        self.caption = caption
        self.description = description
        self.imageUrl = imageUrl
    }
}
