//
//  MapCell.swift
//  AFNetworking
//
//  Created by Murray Toews on 2018/03/03.
//
import UIKit
import Firebase

class MapCell: BaseCell
{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let containerView = UIView()
        
        containerView.layer.borderWidth  = 1
        containerView.layer.borderColor = UIColor.buttonThemeColor().cgColor
        
        addSubview(containerView)
        containerView.anchor(top: topAnchor,  left: leftAnchor, bottom: bottomAnchor,right: rightAnchor)
        
        containerView.addSubview(imageView)
        containerView.addSubview(mapLocation)
        containerView.addSubview(deleteMapCell)
        imageView.anchor(top: containerView.topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 5 , paddingLeft: 1, paddingBottom: 1, paddingRight: 1, width: 30, height: 30)
        mapLocation.anchor(top: containerView.topAnchor, left: imageView.rightAnchor, bottom: bottomAnchor,
                           right: nil,
                           paddingTop: 5 ,
                           paddingLeft: 1,
                           paddingBottom: 1,
                           paddingRight: 1,
                           width: 120,
                           height: 30)
        
        deleteMapCell.anchor(top: containerView.topAnchor,
                             left: nil,
                             bottom: nil,
                             right: containerView.rightAnchor,
                             paddingTop: 2 ,
                             paddingLeft: 2,
                             paddingBottom: 0,
                             paddingRight: 2, width: 16, height: 16)
    }
    
    var btnDeleteMapAction : (()->())?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var mapObject: locObject? {
        didSet {
            mapLocation.text = mapObject?.place?.name
        }
    }
    
    
    let imageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.masksToBounds = true
        iv.image = UIImage(named: "address")
        return iv
    }()
    
    lazy var  deleteMapCell : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_delete"), for: .normal)
        button.tintColor = UIColor.buttonThemeColor()
        button.sizeToFit()
        button.addTarget(self, action: #selector(didDeleteMapCell), for: .touchUpInside)
        return button
    }()
    
    
    var mapLocation: UILabel = {
        let lb = UILabel ()
        lb.layer.borderWidth = 1
        lb.layer.borderColor = UIColor.collectionCell().cgColor
        lb.text = "Location"
        lb.font = UIFont.systemFont(ofSize: 15)
        lb.backgroundColor =  UIColor.collectionCell()
        return lb
    }()
    
    @objc func didDeleteMapCell()
    {
        print("Remove map ... ")
        btnDeleteMapAction?()
    }
    
}
