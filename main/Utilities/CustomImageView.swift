//
//  CustomImageView.swift
//
//  Created by Murray Toews on 4/5/17.

import Foundation
import UIKit
import FirebaseStorage
import FirebaseUI
import SDWebImage

var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    var lastURLUsedToLoadImage: String?
    
    func loadImage(urlString: String) {
        lastURLUsedToLoadImage = urlString
        self.image = nil
        
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        
        var urlPlaceholder: URL?
        
        if let url = URL(string: urlString) {
            urlPlaceholder = url
        }
        else {
          urlPlaceholder = URL(string: "https://firebasestorage.googleapis.com/v0/b/maplefirebase.appspot.com/o/profile_images%2F014BCC59-1498-4BC2-B542-77481DB47730?alt=media&token=a3cd97b9-1c82-4bdb-a49b-eb2057b0d9a4")
       }
        self.sd_cancelCurrentImageLoad()
        self.sd_setShowActivityIndicatorView(true)
        self.sd_setIndicatorStyle(.whiteLarge)
        self.sd_setImage(with: urlPlaceholder , placeholderImage: UIImage(named: "place_holder"))
    }
    
    func loadImageWithPlaceholder(url: String, placeHolder: String) {
        // set image to nil
        self.image = nil
        
        // set lastImgUrlUsedToLoadImage
        lastURLUsedToLoadImage = url
        
        // check if image exists in cache
        if let cachedImage = imageCache[url] {
            self.image = cachedImage
            return
        }
        
        // url for image location
        if let url = URL(string: url) {
            self.sd_cancelCurrentImageLoad()
            self.sd_setShowActivityIndicatorView(true)
            self.sd_setIndicatorStyle(.whiteLarge)
            sd_setImage(with: url, placeholderImage: UIImage(named: placeHolder))
        }
    }
    
}



extension UIImageView{
    
    func setImageWith(color: UIColor)
    {
        image = image?.withRenderingMode(.alwaysTemplate)
        tintColor = color
    }
    
    func setImageWith(storageRefString: String, placeholderImage: UIImage?)
    {
        if storageRefString == ""
        {
            image = placeholderImage
        }
        else if storageRefString.hasPrefix("https://fb")
        {
            self.sd_showActivityIndicatorView()
            self.sd_setIndicatorStyle(.gray)
            self.sd_setImage(with: URL(string: storageRefString), placeholderImage: placeholderImage)
        }
        else{
            self.sd_showActivityIndicatorView()
            self.sd_setIndicatorStyle(.gray)
            let reference : StorageReference = Storage.storage().reference(forURL: storageRefString)
            self.sd_setImage(with: reference, placeholderImage: placeholderImage)
        }
        
    }
    
    
}



