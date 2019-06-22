//
// Created by Murray Toews on 2017-06-13.
// Copyright (c) 2017 Lets Build That App. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import Firebase

/*
class PlaceMarker: GMSMarker {
    // 1
    let place: GooglePlaces
    
    // 2
    init(place: GooglePlaces) {
        self.place = place
        super.init()
        
        position = place.coordinate
        icon = UIImage(named: place.placeType+"_pin")
        groundAnchor = CGPoint(x: 0.5, y: 1)
        appearAnimation = kGMSMarkerAnimationPop
    }
}
*/

class AddressModel {
    
    var street_address: String = ""
    var suburb : String = ""
    var post_code : String = ""
    var country : String = ""
}



class MapController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UISearchDisplayDelegate
{
    
    var locationManager = CLLocationManager()
    //var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    var posts = [Post]()
    
    let geocoder = GMSGeocoder()
    var lastLocation: String!
    var country: String!
    var currentLatitude : CGFloat!
    var currentLongitude : CGFloat!
    var marked = false
    
    var searchController = UISearchController()
    var resultsViewController: GMSAutocompleteResultsViewController?
    var resultView: UITextView?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Locations"
        
        setNavButtons()
        
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        //self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SharePhotoController.dissmissKeyboard)))
       
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = (self as GMSAutocompleteResultsViewControllerDelegate)
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController.searchResultsUpdater = resultsViewController
        
        let subView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
        let containerView = UIView()
        
        view.addSubview(subView)
        subView.addSubview((searchController.searchBar))
        subView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
       
        view.addSubview(containerView)
        containerView.anchor(top: subView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        //Tokyo 35.652832, and the longitude is 139.839478.
        
        let camera = GMSCameraPosition.camera(withLatitude: 35.652832 , longitude: 139.839478 , zoom: 10.0)
        mapView = GMSMapView.map(withFrame: CGRect(x: 20, y: 80, width: 330, height: 560), camera: camera)
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.settings.indoorPicker = true
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        let nav_height = self.navigationController?.navigationBar.frame.height
        let status_height = UIApplication.shared.statusBarFrame.size.height
       
        mapView.padding = UIEdgeInsets (top: nav_height!+status_height,left: 0,bottom: 0,right: 0);
        mapView.delegate = self
        mapUIView = mapView
        containerView.addSubview(mapUIView)
        
        mapUIView.anchor(top: subView.bottomAnchor , left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: -50, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(plusPhotoButton)
        
       
        
    }

    
    let plusPhotoButton:UIButton = {
        let button = UIButton()
        let borderAlpha : CGFloat = 0.7
        let cornerRadius : CGFloat = 5.0
        button.setImage(#imageLiteral(resourceName: "OK"), for: .normal)
        button.backgroundColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 5.0
        button.layer.borderColor = UIColor.blue.cgColor
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.masksToBounds = false
        
        button.addTarget(self, action: #selector(putMarker), for: .touchUpInside)
        button.addTarget(self, action: #selector(putMarkerTouched), for: .touchDown)
        return button
    }()
    
    @objc func putMarkerTouched()
    {
       
        print("Touchdown")
    }
    
    
    
    let mapButton:UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "gear_normal"), for: .normal)
        button.backgroundColor = UIColor.clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 25
        button.backgroundColor = UIColor.white
        button.layer.borderWidth = 5.0
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.shadowColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(findCurrentLocation), for: .touchUpInside)
        return button
    }()
    
    let placesButton:UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "plus_unselected"), for: .normal)
        button.backgroundColor = UIColor.clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 5.0
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(openPlacesView), for: .touchUpInside)
        return button
    }()
    
    
    var mapUIView:UIView  = {
        let map = UIView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
   
    
    func loadLocation()
    {
        
    }
    
    /*
    func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
        // 1
        mapView.clear()
        // 2
        dataProvider.fetchPlacesNearCoordinate(coordinate, radius:searchRadius, types: searchedTypes) { places in
            for place: GooglePlace in places {
                // 3
                let marker = PlaceMarker(place: place)
                // 4
                marker.map = self.mapView
            }
        }
     }
     */
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        let marker = GMSMarker(position: coordinate)
        let geocoder = GMSGeocoder()
        marker.icon = GMSMarker.markerImage(with: .black)
        
        currentLatitude = CGFloat(coordinate.latitude)
        currentLongitude = CGFloat(coordinate.longitude)
        
    
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let address = response?.firstResult() {
                
                let lines = address.lines!
                print(lines)
                marker.title = lines.joined(separator: "\n")
                marker.title = "Product Location"
                marker.snippet = lines.joined(separator: "\n")
                marker.tracksViewChanges = true
                marker.tracksInfoWindowChanges = true
                let Country = lines[0]
                self.lastLocation = lines[1]
                self.country = Country
                
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
            }
        }
        marked = true
        marker.map = mapView
    }
    
    @objc func saveLocationAndReturn()
    {
        print("Save Locations and exit")
        
        if (marked)
        {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let userLocationRef = Database.database().reference().child("locations").child(uid)
            let ref = userLocationRef.childByAutoId()
            
            let values = ["country": self.country ?? "Country" , "address": self.lastLocation ?? "Address","latitude": currentLatitude, "longitude": currentLongitude , "creationDate": Date().timeIntervalSince1970, "uid": uid] as [String : Any]
            
            ref.updateChildValues(values) { (err, ref) in
                if let err = err {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    print("Failed to save post to DB", err)
                    return
                }
                
                // self.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: ShareController.updateFeedNotificationName, object: nil)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleCancel()
    {
        print("Save Locations and exit")
        
        if (marked)
        {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userLocationRef = Database.database().reference().child("locations").child(uid)
        let ref = userLocationRef.childByAutoId()
        
        let values = ["country": self.country ?? "Country" , "address": self.lastLocation ?? "Address","latitude": currentLatitude, "longitude": currentLongitude , "creationDate": Date().timeIntervalSince1970, "uid": uid] as [String : Any]
        
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to save post to DB", err)
                return
            }
            
            print("Successfully saved post to DB")
            //self.dismiss(animated: true, completion: nil)
            //NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
        }
        }
        dismiss(animated: true, completion: nil)
    }
    
   
    
    @objc func findCurrentLocation() {
        print("findCurrentLocation")
        
        let position = CLLocationCoordinate2D(latitude: 35.6859677777, longitude: 139.76)
        let tokyo = GMSCameraPosition.camera(withLatitude: 35.6859677777, longitude: 139.76, zoom: mapView.camera.zoom)
        let marker = GMSMarker(position: position)
        marker.title = "Nomura Urban Net Building"
        marker.tracksViewChanges = true
        marker.map = mapView
        mapView.camera = tokyo
    }
    
    @objc func openPlacesView()
    {
        print("openPlacesView")

        mapView.animate(toLocation: CLLocationCoordinate2D(latitude: 35.6859677777, longitude: 139.76))
        mapView.animate(toViewingAngle: 45)
        mapView.animate(toBearing: 30)
        
    }
    
    @objc func putMarker()
    {
        print("putMarker")
        
        let position = CLLocationCoordinate2D(latitude: 35.68596, longitude: 139.76701922)
        //let london = GMSMarker(position: position)
        
        let house = UIImage(named: "home_selected")!.withRenderingMode(.alwaysTemplate)
        let markerView = UIImageView(image: house)
        markerView.tintColor = .red
        
        let marker = GMSMarker(position: position)
        marker.title = "Otemachi Otemchi UrbanNet"
        marker.tracksViewChanges = true
        marker.map = mapView
        
        let address = "Some address to be updated"
        let description = "A description of the location"
    
        
        //guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        //print("post id:", self.lastLocation?.id ?? "")
        //print("Inserting location: ", address)
        
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userPostRef = Database.database().reference().child("locations").child(uid)
        let ref = userPostRef.childByAutoId()
    
        let values = ["address": address, "description": description ,"latitude": position.latitude, "longitude": position.longitude , "creationDate": Date().timeIntervalSince1970, "uid": uid] as [String : Any]
        
        
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to save post to DB", err)
                return
            }
            
            print("Successfully saved post to DB")
            //self.dismiss(animated: true, completion: nil)
            //NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
        }

        
        
        
    }
    
    
    fileprivate func fetchMapMarkers() {
        
        //et User = Auth.auth().currentUser
        
        //self.fetchPostsWithUser(User: User)
        
    }
    
    // pass the userID to collect the posts from the user and the ones you are following
    fileprivate func fetchPostsWithUser(user: MapleUser) {
        let ref = Database.database().reference().child("posts").child(user.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            //self.collectionView?.refreshControl?.endRefreshing()
            
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else { return }
                let post = Post(user: user , dictionary: dictionary)
                post.id = key
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                Database.database().reference().child("likes").child(key).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot)
                    
                    if let value = snapshot.value as? Int, value == 1 {
                        post.hasLiked = true
                    } else {
                        post.hasLiked = false
                    }
                    
                    self.posts.append(post)
                    self.posts.sort(by: { (p1, p2) -> Bool in
                        return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                    })
                    //self.collectionView?.reloadData()
                    
                }, withCancel: { (err) in
                    print("Failed to fetch like info for post:", err)
                })
            })
            
        }) { (err) in
            print("Failed to fetch posts:", err)
        }
    }
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        print("tapped")
        
        
        return true
    }
    
    
    
    func setNavButtons()
    {
        let image = UIImage(named: "Share")?.withRenderingMode(.alwaysOriginal)
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(saveLocationAndReturn))
        button.tintColor = .red
        navigationItem.rightBarButtonItem = button
        
        let leftImage = UIImage(named: "cancel")?.withRenderingMode(.alwaysOriginal)
        let leftButton = UIBarButtonItem(image: leftImage, style: .plain, target: self, action: #selector(handleCancel))
        leftButton.tintColor = .red
        navigationItem.leftBarButtonItem = leftButton
        
    }
  
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String,
                 name: String, location: CLLocationCoordinate2D) {
        print("You tapped \(name): \(placeID), \(location.latitude)/\(location.longitude)")
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool)
    {
        //mapView.clear()
        
    }
    
    /*
    func mapView(_ mapView: GMSMapView, idleAt cameraPosition: GMSCameraPosition)
    {   geocoder.reverseGeocodeCoordinate(cameraPosition.target) { (response, error) in
            guard error == nil else {
                return
            }
            if let result = response?.firstResult(){
                let marker = GMSMarker()
                marker.position = cameraPosition.target
                marker.title = result.lines?[0]
                marker.snippet = result.lines?[1]
                marker.isFlat = false
                marker.map = mapView
                
                print ("Adding new location at the idle point")
            }
     
        }
    }
    */
 
}


extension MapController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController.isActive = false
        // Do something with the selected place.
        
        print("Place ID: \(place.placeID ?? "")")
        print("Place Phone Number: \(String(describing: place.phoneNumber))")
        print("Place name: \(place.name ?? "")")
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
                                              zoom: zoomLevel)
        
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
    
    





