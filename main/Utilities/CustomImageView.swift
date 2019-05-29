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
        guard let url = URL(string: urlString) else { return }
        //self.sd_showActivityIndicatorView()
        //self.sd_setIndicatorStyle(.gray)
        
        self.sd_setShowActivityIndicatorView(true)
        self.sd_setIndicatorStyle(.gray)
        //self.sd_setImage(with: URL(string: urlString), placeholderImage: UIImage(named: "placeholder"))
        self.sd_setImage(with: url, placeholderImage: UIImage(named: "windows"))
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



