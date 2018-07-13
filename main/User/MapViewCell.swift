//
//  MapViewCell.swift
//  Maple
//
//  Created by Murray Toews on 12/14/17.
//  Copyright © 2017 mapleon. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import Firebase

 class MapViewCell: UICollectionViewCell, GMSMapViewDelegate
{

     var mapLocation: [LocationObject]? {
         didSet {
            for location in (mapLocation)! {
                setMarker(location)
            }
         }
     }
    
    let mapView : GMSMapView = {
        let camera = GMSCameraPosition.camera(withLatitude: 35.652832 , longitude: 139.839478 , zoom: 12.0)
        let mv = GMSMapView.map(withFrame: CGRect(x: 20, y: 80, width: 330, height: 560), camera: camera)
        var placesClient: GMSPlacesClient!
        mv.isMyLocationEnabled = true
        mv.settings.myLocationButton = true
        mv.settings.setAllGesturesEnabled(true)
        mv.settings.compassButton = true
        mv.settings.indoorPicker = true
        return mv
    }()
    
    
    func setMarkerLocation(_ map: Post)
    {
        guard let postid = map.id else {return}
        Database.fetchLocationByPostId(postid) { (locations) in
                for location in locations{
                    self.markupMap(location)
                }
            }
    }
    
    func setMarker(_ map: LocationObject)
    {
        self.markupMap(map)
    }
    
    lazy var mapButton: UIButton = {
        let button = UIButton(type: .system)
        //
        let title = "Navi"
        let attributedText = NSMutableAttributedString(string: title, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        button.setImage(#imageLiteral(resourceName: "ic_map"), for: .normal)
        button.setAttributedTitle(attributedText, for: .normal)
        button.addTarget(self, action: #selector(handleOpenMapView), for: .touchUpInside)
        button.tintColor = UIColor.themeColor()
        return button
    }()

    func markupMap(_ location: LocationObject) {
        
        DispatchQueue.main.async { () -> Void in
            
            let position = CLLocationCoordinate2DMake(location.latitude!, location.longitude!)
            let marker = GMSMarker(position: position)
            let camera = GMSCameraPosition.camera(withLatitude: location.latitude!, longitude: location.longitude!, zoom: 14)
            self.mapView.camera = camera
            marker.title = "\(location.location!)"
            marker.map = self.mapView
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mapView)
        addSubview(mapButton)
        
       // mapView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        
        mapView.anchor(top: topAnchor, left: leftAnchor, bottom: nil,
                                    right: nil, paddingTop: 0, paddingLeft: 0 ,
                                    paddingBottom: 0, paddingRight: 0, width: frame.width, height: frame.height - 350)
        
        mapButton.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil)

    }
    
    @objc func handleOpenMapView()
    {
        let testURL = URL(string: "comgooglemaps-x-callback://")!
        if UIApplication.shared.canOpenURL(testURL) {
            let directionsRequest = "comgooglemaps-x-callback://" +
                "?daddr=John+F.+Kennedy+International+Airport,+Van+Wyck+Expressway,+Jamaica,+New+York" +
            "&x-success=sourceapp://?resume=true&x-source=AirApp"
            
            let directionsURL = URL(string: directionsRequest)!
            UIApplication.shared.open(directionsURL)
        } else {
            NSLog("Can't use comgooglemaps-x-callback:// on this device.")
        }
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
