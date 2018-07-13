//
//  PhotoSelectorCell.swift
//  InstagramFirebase
//
//  Created by Murray Toews on 6/3/17.
//  Copyright © 2017 maple.com

import UIKit


protocol PhotoSelectorCellDelegate {
    func didSelectPhoto(for cell: PhotoSelectorCell)
}



class PhotoSelectorCell: UICollectionViewCell {
    
    var delegate : PhotoSelectorCellDelegate?
    
    
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let selectedImageButton: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = nil
        iv.image = UIImage(named: "selectedPhoto")
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector(("singleTapping:")))
        singleTap.numberOfTapsRequired = 1;
        iv.addGestureRecognizer(singleTap)
        return iv
    }()
    
    let checkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "selectedPhoto").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handlePhotoSelection), for: .touchUpInside)
        return button
    }()
    
    @objc func handlePhotoSelection() {
        print("Handle the photoslection ...")
        //guard let item =  else { return }
        delegate?.didSelectPhoto(for: self)
    }

    
    
    func singleTapping(gestureRecognizer: UITapGestureRecognizer) {
        print("image clicked")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        addSubview(selectedImageButton)
        selectedImageButton.anchor(top: photoImageView.topAnchor, left: nil,  bottom: nil, right: photoImageView.rightAnchor, paddingTop: 3, paddingLeft: 0, paddingBottom: 0 , paddingRight: 3, width: 18, height: 18)
        addSubview(checkButton)
        checkButton.anchor(top: photoImageView.topAnchor, left: photoImageView.leftAnchor,  bottom: nil, right:  nil , paddingTop: 3, paddingLeft: 0, paddingBottom: 0 , paddingRight: 0, width: 18, height: 18)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
