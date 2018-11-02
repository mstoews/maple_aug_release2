//
//  PostImageCell.swift
//  maple-release
//
//  Created by Murray Toews on 2018/03/03.
//  Copyright © 2018 Murray Toews. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
//import DKImagePickerController
import os.log
import AlgoliaSearch
import InstantSearchCore
import MaterialComponents
//import Floaty

protocol UIImageEditFilterDelegate {
    func didHandleFilter()
    func didHandleDelete()
}


class PostImageObject: MDCCardCollectionCell
{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        let buttonMenus = UIView()
        buttonMenus.backgroundColor = UIColor.themeColor()
        buttonMenus.layer.cornerRadius = 10
        buttonMenus.backgroundColor = UIColor(displayP3Red: 255, green: 200, blue: 150, alpha: 0.3)
        buttonMenus.layer.borderWidth = 2
        buttonMenus.layer.borderColor = UIColor.black.cgColor
        
        let stackButtonsVerical = UIStackView(arrangedSubviews: [deleteButton,filterButton,editButton])
        stackButtonsVerical.axis = .vertical
        stackButtonsVerical.distribution = .fillEqually
        
        buttonMenus.addSubview(stackButtonsVerical)
    
        addSubview(imageView)
        addSubview(buttonMenus)
        
        imageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        
        stackButtonsVerical.anchor(top: buttonMenus.topAnchor, left: buttonMenus.leftAnchor, bottom: buttonMenus.bottomAnchor, right: buttonMenus.rightAnchor)
        buttonMenus.anchor(top: topAnchor, left: leftAnchor, bottom: nil , right: nil, paddingTop: 20, paddingLeft: 5, paddingBottom: 0, paddingRight: 20,  width: 40, height: 120)
    }
    
    var delegate: UIImageEditFilterDelegate?
    
    var btnFilterAction : (()->())?
    
    var btnDeleteAction : (()->())?
    
    var btnEditAction : (()->())?
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        //button.setImage(#imageLiteral(resourceName: "filter-2"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "ic_filter"), for: .normal)
        button.tintColor = UIColor.themeColor()
        button.sizeToFit()
        button.addTarget(self, action: #selector(handleFilterFromImage), for: .touchUpInside)
        return button
    }()
    
    lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        //button.setImage(#imageLiteral(resourceName: "ic_filter"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "ic_edit"), for: .normal)
        button.tintColor = UIColor.themeColor()
        button.sizeToFit()
        button.addTarget(self, action: #selector(handleEdit), for: .touchUpInside)
        return button
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_delete"), for: .normal)
        button.sizeToFit()
        button.tintColor = UIColor.themeColor()
        button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        return button
    }()
    
    @objc func handleFilterFromImage()
    {
        print("HandleFilterfromIma")
        btnFilterAction?()
    }
    
    @objc func handleDelete()
    {
        print("PostImageCell : handleDelete")
        btnDeleteAction?()
    }
    
    @objc func handleEdit()
    {
        print("PostImageCell : handleDelete")
        btnEditAction?()
    }
    
    var imageObject: UIImage? {
        didSet {
            imageView.image = imageObject
        }
    }
    
    let imageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        //iv.layer.masksToBounds = true
        return iv
    }()
}


