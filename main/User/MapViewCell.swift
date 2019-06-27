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
import FirebaseAuth
import FirebaseFirestore


class POIItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String!
    @objc var marker: GMSMarker!
    
    init(position: CLLocationCoordinate2D, name: String, marker: GMSMarker) {
        self.position = position
        self.name = name
        self.marker = marker
    }
}


class MapViewCell: UICollectionViewCell,
    GMSMapViewDelegate,
    CLLocationManagerDelegate,
    GMUClusterManagerDelegate
{
    
    private var clusterManager: GMUClusterManager!
    
    let locationManager = CLLocationManager()
    
    private func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
                                                 zoom: mapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
    }
    
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
    // MARK: Needed to create the custom info window
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    fileprivate var locationMarker : GMSMarker? = GMSMarker()
    
    
  
    
    private func generateClusterItems() {
        for location in locations {
            let doubleLat = Double(location.latitude!)
            let doubleLong = Double(location.longitude!)
            let latitude = CLLocationDegrees(doubleLat)
            let longitude = CLLocationDegrees(doubleLong)
            let position = CLLocationCoordinate2DMake(latitude, longitude)
            let marker = GMSMarker(position: position)
            let item = POIItem(position: CLLocationCoordinate2DMake(
                location.latitude!,
                location.longitude!),
                name: (location.place?.name)!,
                marker: marker)
            clusterManager.add(item)
        }
    }
    
   
    
    func sizeForOffset(view: UIView) -> CGFloat {
        return  120.0
    }
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let poiItem = marker.userData as? POIItem {
            NSLog("Did tap marker for cluster item \(poiItem.name)")
        } else {
            NSLog("Did tap a normal marker")
        }
        
        // Needed to create the custom info window
        locationMarker = marker
        //infoWindow.removeFromSuperview()
        //infoWindow = loadNiB()
        guard let location = locationMarker?.position else {
            print("locationMarker is nil")
            return false
        }
        //infoWindow.center = mapView.projection.point(for: location)
        //infoWindow.center.y = infoWindow.center.y - sizeForOffset(view: infoWindow)
        //self.addSubview(infoWindow)
        
        return false
    }
    
    
    func setMarkerLocation(_ map: Post)
    {
        guard let postid = map.id else {return}
//        Database.fetchLocationByPostId(postid) { (locations) in
//            for location in locations{
//                self.markupMap(location)
//            }
//        }
    }
    
    func setMarker(_ map: LocationObject)
    {
        self.markupMap(map)
    }
    
    lazy var mapButton: UIButton = {
        let button = UIButton(type: .system)
        //
        let title = "Navigation"
        let attributedText = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        button.setImage(#imageLiteral(resourceName: "ic_map"), for: .normal)
        button.setAttributedTitle(attributedText, for: .normal)
        button.addTarget(self, action: #selector(handleOpenMapView), for: .touchUpInside)
        button.tintColor = .black
        return button
    }()
    
    
    func markerByLocation(_ location: LocationObject, _ category: String, _ situation: String ) {
        var cnt : Int = 0
        var locationTypeArray = situation.components(separatedBy: ",")
        
        for types in locationTypeArray {
            switch types.trimmingCharacters(in: .whitespacesAndNewlines) {
            case "point_of_interest":
                locationTypeArray[cnt] = "POI"
                break
            case "establishment":
                locationTypeArray[cnt] = "Business"
                break
            default:
                break
                //locationTypeArray[cnt] = "General"
            }
            cnt += 1
        }
        
        cnt = 0
        var locationResult : String = ""
        for type in locationTypeArray {
            locationResult.append(type)
            cnt += 1
            if cnt < locationTypeArray.count {
                locationResult.append(",")
            }
        }
        
        DispatchQueue.main.async { () -> Void in
            let position = CLLocationCoordinate2DMake(location.latitude!, location.longitude!)
            let marker = GMSMarker(position: position)
            let camera = GMSCameraPosition.camera(withLatitude: location.latitude!, longitude: location.longitude!, zoom: 10)
            self.mapView.camera = camera
            marker.title = "\(location.location!)"
            marker.snippet = "\(category)\n\(locationResult)"
            marker.icon = UIImage(imageLiteralResourceName: "ic_location_on")
            marker.map = self.mapView
        }
        
    }
    
    
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
    var locations = [LocationObject]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mapView)
        addSubview(mapButton)
        
        // mapView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        
        mapView.anchor(top: topAnchor, left: leftAnchor, bottom: nil,
                       right: nil, paddingTop: 0, paddingLeft: 0 ,
                       paddingBottom: 0, paddingRight: 0, width: frame.width, height: frame.height - 350)
        
        mapButton.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil)
        
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        
        // Call cluster() after items have been added to perform the clustering and rendering on map.
        clusterManager.cluster()
        
        // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
        clusterManager.setDelegate(self, mapDelegate: self)
        if let uid = Auth.auth().currentUser?.uid {
            Firestore.fetchLocationByUserId(uid: uid) { (locationObjects) in
                for location in locationObjects {
                    let lat = Double(location.latitude!)
                    let lng = Double(location.longitude!)
                    let latitude = CLLocationDegrees(lat)
                    let longitude = CLLocationDegrees(lng)
                    let position = CLLocationCoordinate2DMake(latitude, longitude)
                    let marker = GMSMarker(position: position)
                    self.locations.append(location)
                    if let product = location.types {
                        //if let desc = location.address {
                            let item = POIItem(position: position, name: product, marker: marker)
                            self.clusterManager.add(item)
                        //}
                    }
                }
            }
        }
        
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

extension MapViewCell: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        // Do something with the selected place.
        
        print("Place ID: \(place.placeID)")
        print("Place Phone Number: \(String(describing: place.phoneNumber))")
        print("Place name: \(place.name)")
        print("Place address: \(String(describing: place.formattedAddress))")
        print("Place attributions: \(String(describing: place.attributions))")
        
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: 10)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
        //listLikelyPlaces()
    }
    
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    
    // Retrieve the users ID and the use that to look up the products by user.
    fileprivate func fetchPosts() {
        guard (Auth.auth().currentUser?.uid) != nil else { return }
        
        //let user = Auth.auth().currentUser
        
        //Database.fetchUserWithUID(uid: uid) { (uid) in
        //self.fetchPostsWithUser(User: user)
    }
}

