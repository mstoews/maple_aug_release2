//
//  UserImageCell.swift
//  maple-release
//
//  Created by Murray Toews on 2018/03/06.
//  Copyright © 2018 Murray Toews. All rights reserved.
//
import UIKit
import Firebase

 class UserImageCell: BaseCell
{
    var  imageObject: ImageObject?  {
        didSet {
            if let imageUrl = imageObject {
                photoImageView.loadImage(urlString: imageUrl.url)
            }
        }
    }
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image =  #imageLiteral(resourceName: "ic_bookmark").withRenderingMode(.alwaysOriginal)
        return iv
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
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

