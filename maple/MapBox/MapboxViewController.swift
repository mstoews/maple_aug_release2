//
//  MapboxViewController.swift
//  Maple
//
//  Created by Murray Toews on 2020/03/25.
//  Copyright © 2020 Murray Toews. All rights reserved.
//

import UIKit
import Mapbox

class MapBoxSingleLocalViewController: UIViewController, MGLMapViewDelegate {
    override func viewDidLoad() {
    super.viewDidLoad()
        
        let url = URL(string: "mapbox://styles/mapbox/streets-v11")
        navigationItem.title = "Map Page"
     
        let mapView = MGLMapView(frame: view.bounds, styleURL: url)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.showsUserLocation = true
         mapView.showsUserLocation = true
             
             //let center = CLLocationCoordinate2D(latitude: self.nav!.currentLocationLatitude! , longitude: self.nav!.currentLocationLongitude!)
             
//             // Optionally set a starting point.
//             mapView.setCenter(center, zoomLevel: 8, direction: 0, animated: false)
//
//             // Initialize and add the marker annotation.
//             let marker = MGLPointAnnotation()
//             //marker.coordinate = CLLocationCoordinate2D(latitude: nav!.destinationLocationLatitude! , longitude: nav!.destinationLocationLongitude!)
//             //marker.title = nav?.Title
//
//             // This custom callout example does not implement subtitles.
//             //marker.subtitle = nav?.SubTitle
//
//             // Add marker to the map.
//             mapView.addAnnotation(marker)
             
             // Select the annotation so the callout will appear.
        // Set the map’s center coordinate and zoom level.
        mapView.setCenter(CLLocationCoordinate2D(latitude: 41.8864, longitude: -87.7135), zoomLevel: 13, animated: false)
        view.addSubview(mapView)
    }
     
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Only show callouts for `Hello world!` annotation.
        return annotation.responds(to: #selector(getter: MGLAnnotation.title)) && annotation.title! == "Hello world!"
    }
}


