//
//  Bookmark.swift
//  maple
//
//  Created by Murray Toews on 10/9/17.
//  Copyright © 2017 mapleon. All rights reserved.
//

import Foundation
struct Bookmark {
    
    var id: String?
    let postId: String
    let bookMarked: String
    
    var hasBookmark = false
    
    init(id: String, dictionary: [String: Any]){
        self.postId = dictionary["postId"] as? String ?? ""
        self.bookMarked = dictionary["bookMarkded"] as? String ?? ""
    }
}
