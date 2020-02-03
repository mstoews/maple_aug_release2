//
//  MapLocationController.swift
//  maple
//
//  Created by Murray Toews on 9/25/17.
//  Copyright © 2017 mapleon. All rights reserved.
//


import UIKit
import GoogleMaps
import GooglePlaces



protocol MapLocationControllerDelegate {
    func didReturnMapLocation(Location: String, lat: Double, lon: Double)
}



class MapLocationController: UIViewController , UISearchBarDelegate , LocateOnTheMap, GMSAutocompleteFetcherDelegate ,GMSMapViewDelegate{
    
    var mapObjectsCollection = [LocationObject]()
    // An array to hold the list of likely places.
    var likelyPlaces: [GMSPlace] = []
    
    // The currently selected place.
    var selectedPlace: GMSPlace?
    
    /**
     * Called when an autocomplete request returns an error.
     * @param error the error that was received.
     */
    
    func didTapInfoWindow()
    {
        print("Did Tap Info Window")
    }
    
    @objc func handleSavePins()
    {
        
    }
    
    let geocoder = GMSGeocoder()
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        return true
    }
    
    func googleMapsView(_ mapView: GMSMapView, willMove gesture: Bool) {
        mapView.clear()
    }
    
    func googleMapsView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
    }
    
    
    func googleMapsView(_ mapView: GMSMapView!, idleAt position: GMSCameraPosition!) {
        reverseGeocodeCoordinate(coordinate: position.target)
    }
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        
        // 1
        let geocoder = GMSGeocoder()
        
        // 2
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let address = response?.firstResult() {
                
                // 3
                // let lines = address.lines as! [String]
                //self.addressLabel.text = lines.joinWithSeparator("\n")
                
                // 4
                UIView.animate(withDuration: 0.25) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    var delegate: MapLocationControllerDelegate?
    
    public func didFailAutocompleteWithError(_ error: Error) {
        //        resultText?.text = error.localizedDescription
    }
    
    /**
     * Called when autocomplete predictions are available.
     * @param predictions an array of GMSAutocompletePrediction objects.
     */
    public func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        //self.resultsArray.count + 1
        
        for prediction in predictions {
            
            if let prediction = prediction as GMSAutocompletePrediction?{
                self.resultsArray.append(prediction.attributedFullText.string)
            }
        }
        self.searchResultController.reloadDataWithArray(self.resultsArray)
        //   self.searchResultsTable.reloadDataWithArray(self.resultsArray)
        print(resultsArray)
    }
    
    
    var googleMapsView: GMSMapView!
    var searchResultController: MapLocationSearchController!
    var resultsArray = [String]()
    var gmsFetcher: GMSAutocompleteFetcher!
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let camera = GMSCameraPosition.camera(withLatitude: 35.652832 , longitude: 139.839478 , zoom: 16.0)
        self.googleMapsView = GMSMapView.map(withFrame: CGRect(x: 0, y: 40, width: 50, height: 560), camera: camera)
        googleMapsView.isMyLocationEnabled = true
        googleMapsView.settings.myLocationButton = false
        googleMapsView.settings.compassButton = true
        googleMapsView.settings.indoorPicker = true
        googleMapsView.settings.zoomGestures = true
        googleMapsView.settings.tiltGestures = true
        self.view.addSubview(self.googleMapsView)
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self as CLLocationManagerDelegate
        
        placesClient = GMSPlacesClient.shared()
        
        self.googleMapsView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
//        
//        let item = FloatyItem()
//        item.hasShadow = false
//        item.buttonColor = UIColor.white
//        item.circleShadowColor = UIColor.blue
//        item.titleShadowColor = UIColor.blue
//        item.titleLabelPosition = .left
//        item.title = "Close the page"
//        item.icon = UIImage(named:"icons8-place-marker-50")
//        item.handler = { item in
//            print ("handle item")
//            self.handleCancel()
//        }
//        
//        let floater = Floaty()
//        floater.friendlyTap = true
//        floater.buttonColor = .white
//        floater.hasShadow = true
//        floater.addItem("Add Pin", icon: UIImage(named:"plus_unselected")!)
//        floater.addItem("Routes", icon: UIImage(named:"icons8-place-marker-50")!)
//        floater.addItem(item: item)
//        floater.addItem(item : GoToLocation)
//        floater.fabDelegate = self
//        
//        view.addSubview(floater)
//        floater.paddingX = 10.00
//        title = "ロケーション検索"
        
        setNavigationButtons()
        searchResultController = MapLocationSearchController()
        searchResultController.delegate = self
        gmsFetcher = GMSAutocompleteFetcher()
        gmsFetcher.delegate = self
    }
    
    func setNavigationButtons()
    {
        //let image = UIImage(named: "icons8-Share 2-50")?.withRenderingMode(.alwaysOriginal)
        let image = UIImage(named: "search_selected")?.withRenderingMode(.alwaysOriginal)
        let rightbutton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(searchWithAddress))
        rightbutton.tintColor = .red
        navigationItem.rightBarButtonItem = rightbutton
        
        let leftImage = UIImage(named: "icons8-Back Arrow-50")?.withRenderingMode(.alwaysOriginal)
        let leftButton = UIBarButtonItem(image: leftImage, style: .plain, target: self, action: #selector(handleCancel))
        leftButton.tintColor = .red
        navigationItem.leftBarButtonItem = leftButton
        
    }
    
    @objc func handleCancel()
    {
        print("Save Locations and exit")
        dismiss(animated: true, completion: nil)
    }
    
    
    /**
     action for search location by address
     
     - parameter sender: button search location
     */
    @objc func searchWithAddress(_ sender: AnyObject) {
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.delegate = self
        self.present(searchController, animated:true, completion: nil)
    }
    
    /**
     Locate map with longitude and longitude after search location on UISearchBar
     
     - parameter lon:   longitude location
     - parameter lat:   latitude location
     - parameter title: title of address location
     */
    
    
    func locateWithLongitude(_ lon: Double, andLatitude lat: Double, andTitle title: String) {
        
        DispatchQueue.main.async { () -> Void in
            let position = CLLocationCoordinate2DMake(lat, lon)
            let marker = GMSMarker(position: position)
            //let place = GMSPlace(
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 14)
            self.googleMapsView.camera = camera
            marker.title = "\(title)"
            marker.snippet = "This is the info window"
            marker.map = self.googleMapsView
            marker.isDraggable = true
            //let mp = MapObject(place: place)
            //self.mapObjectsCollection.append(mp)
        }
        
    }
    
    /**
     Searchbar when text change
     
     - parameter searchBar:  searchbar UI
     - parameter searchText: searchtext description
     */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let placeClient = GMSPlacesClient()
        
        placeClient.autocompleteQuery(searchText, bounds: nil, filter: nil)  {(results, error: Error?) -> Void in
            // NSError myerr = Error;
            print("Error @%",Error.self)
            
            self.resultsArray.removeAll()
            if results == nil {
                return
            }
            
            for result in results! {
                if let result = result as? GMSAutocompletePrediction {
                    self.resultsArray.append(result.attributedFullText.string)
                }
            }
            
            self.searchResultController.reloadDataWithArray(self.resultsArray)
            
        }
        self.resultsArray.removeAll()
        gmsFetcher?.sourceTextHasChanged(searchText)
        
        
    }
    
    // Populate the array with the list of likely places.
    func listLikelyPlaces() {
        // Clean up from previous sessions.
        likelyPlaces.removeAll()
        
        placesClient.currentPlace(callback: { (placeLikelihoods, error) -> Void in
            if let error = error {
                // TODO: Handle the error.
                print("Current Place error: \(error.localizedDescription)")
                return
            }
            
            // Get likely places and add to the list.
            if let likelihoodList = placeLikelihoods {
                for likelihood in likelihoodList.likelihoods {
                    let place = likelihood.place
                    self.likelyPlaces.append(place)
                }
            }
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

extension MapLocationController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if googleMapsView.isHidden {
            googleMapsView.isHidden = false
            googleMapsView.camera = camera
        } else {
            googleMapsView.animate(to: camera)
        }
        
        listLikelyPlaces()
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            googleMapsView.isHidden = false
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
}


