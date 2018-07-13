    //
//  Image.swift
//  Maple
//
//  Created by Murray Toews on 11/7/17.
//  Copyright © 2017 mapleon. All rights reserved.
//

import UIKit
import Foundation

//class ImageObjects: NSObject {
//    var postid: String
//    var image: UIImage?
//    var imageUrl: String
// init (postid: String , imageUrl: String)
//    {
//        self.postid = postid
//        self.imageUrl = imageUrl
//        let url = URL(string: (self.imageUrl))
//        if url != nil {
//            let imagedata = try? Data(contentsOf: url!)
//            let image: UIImage = UIImage(data: imagedata!)!
//            self.image = image
//        }
//    }
//}

class  ImageObject : NSObject {
    
    var postid: String?
    var url: String
    var imageId: String?
    var thumb: String?
    
    init(postid: String, imageid: String,  url: String) {
        self.postid = postid
        self.url = url
        self.imageId = imageid
        self.thumb = url
    }
}

