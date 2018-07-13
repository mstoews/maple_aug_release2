//
//  CustomImageView.swift
//
//  Created by Murray Toews on 4/5/17.

import Foundation
import UIKit
import FirebaseStorage
import FirebaseUI
import SDWebImage
import Kingfisher

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
        
        loadImageWithCompletionHandler(imageURL: url) { (img, error) in
            if error != nil {
                return
            }
            else {
                self.image = img
            }
        }
    }
    
    func loadImageWithCompletionHandler(imageURL: URL, _ completion: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
            KingfisherManager.shared.retrieveImage(with: ImageResource(downloadURL: imageURL), options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                completion(image, error)
            })
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
            self.sd_setImage(with: URL(string: storageRefString), placeholderImage: placeholderImage)
        }
        else{
            let reference : StorageReference = Storage.storage().reference(forURL: storageRefString)
            self.sd_setImage(with: reference, placeholderImage: placeholderImage)
        }
        
    }
    
    
}
