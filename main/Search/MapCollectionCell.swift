//
//  MapCollectionCell.swift
//  maple_release
//
//  Created by Murray Toews on 2018/05/05.
//  Copyright © 2018 Murray Toews. All rights reserved.
//


import AlgoliaSearch
import InstantSearchCore
//import AFNetworking
import UIKit
import Firebase
import FirebaseFirestore
import MaterialComponents


class MapCollectionCell: MDCCardCollectionCell {
    
    static let placeholder = UIImage(named: "placeholder")!
    
    let attributeTitle = [NSAttributedStringKey.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .title)]
    let attributeCaption = [NSAttributedStringKey.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .body2 )]
    let attributeSubline = [NSAttributedStringKey.font: UIFont.mdc_preferredFont(forMaterialTextStyle:  .subheadline )]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.collectionCell()
        
        addSubview(mapImageView)
        addSubview(ratingLabel)
        addSubview(typesLabel)
        addSubview(locationLabel)
        addSubview(addressLabel)
        
        mapImageView.anchor(top: topAnchor , left: leftAnchor, bottom: nil, right: nil,paddingTop: 5, paddingLeft: 0, paddingBottom: 5, paddingRight: 0, width: 35, height: 35)
        locationLabel.anchor(top: topAnchor, left: mapImageView.rightAnchor, bottom: nil, right: rightAnchor ,paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 2, width: 0, height: 20)
        addressLabel.anchor(top: locationLabel.bottomAnchor, left: mapImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 2, paddingRight: 0, width: 0, height: 0)
        typesLabel.anchor(top: addressLabel.bottomAnchor, left: mapImageView.rightAnchor, bottom: nil, right: rightAnchor ,paddingTop: 0, paddingLeft: 0, paddingBottom: 2, paddingRight: 0, width: 0, height: 0)
        ratingLabel.anchor(top: typesLabel.bottomAnchor, left: mapImageView.rightAnchor, bottom: nil, right: rightAnchor ,paddingTop: 0, paddingLeft: 0, paddingBottom: 2, paddingRight: 0, width: 0, height: 0)
    }
    
    
    @objc func usernameLabelTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        //self.delegate?.didTapLocationLabel(location: addressLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    let mapImageView : CustomImageView = {
        let iv = CustomImageView()
        iv.image = UIImage(named: "pin")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    
    let ratingLabel : UILabel = {
        let lb = UILabel()
        lb.text = ""
        lb.font = UIFont.systemFont(ofSize: 10)
        lb.numberOfLines = 0
        return lb
    }()
    
    let typesLabel : UILabel = {
        let lb = UILabel()
        lb.text = ""
        lb.font = UIFont.systemFont(ofSize: 10)
        lb.numberOfLines = 0
        return lb
    }()
    
    let locationLabel : UILabel = {
        let lb = UILabel()
        lb.text = ""
        lb.font = UIFont.systemFont(ofSize: 10)
        lb.numberOfLines = 0
        return lb
    }()
    
    let addressLabel : UILabel = {
        let lb = UILabel()
        lb.text = ""
        lb.font = UIFont.systemFont(ofSize: 10)
        lb.numberOfLines = 0
        return lb
    }()
    
    let phoneNumberLabel: UILabel = {
        let lb = UILabel()
        lb.text = ""
        lb.font = UIFont.systemFont(ofSize: 10)
        lb.numberOfLines = 0
        return lb
    }()
    
    let priceLevelLabel : UILabel = {
        let lb = UILabel()
        lb.text = ""
        lb.font = UIFont.systemFont(ofSize: 10)
        lb.numberOfLines = 0
        return lb
    }()
    
    
    var locationRecord : LocationRecord? {
        didSet {
            if let address = locationRecord?.address {
                addressLabel.attributedText = NSMutableAttributedString(string: address , attributes: attributeCaption)
            }
            
            if let types =  locationRecord?.types {
                typesLabel.attributedText = NSMutableAttributedString(string: types , attributes: attributeCaption)
            }
            
            if let location = locationRecord?.place {
                locationLabel.attributedText = NSMutableAttributedString(string: location , attributes: attributeTitle )
            }
            
            if let ratings = locationRecord?.rating {
                
                //ratingLabel.attributedText = NSMutableAttributedString(string: ratings , attributes: attributeCaption)
            }
            
        }
    }
    
}


