//
//  SharePhotoCell.swift
//  Maple
//
//  Created by Murray Toews on 10/13/17.
//  Copyright © 2017 mapleon. All rights reserved.
//



import UIKit
import MaterialComponents

class SharePhotoCell: MDCCardCollectionCell {
    
    var image: Photo? {
        didSet {
            if let imageUrl = image?.imageUrl {
                photoImageView.loadImage(urlString: imageUrl)
            }
        }
    }
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.loadImage(urlString: "ic_camera")
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 5, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? UIColor.gray : UIColor.clear
        }
}

}
