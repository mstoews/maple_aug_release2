//
//  MapBoxViewController.swift
//  Maple
//
//  Created by Murray Toews on 2019/05/08.
//  Copyright © 2019 Murray Toews. All rights reserved.
//

import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import Mapbox
import MaterialComponents
import JJFloatingActionButton

protocol MapPostDelegate {
    func didTapNavigation(navigation: NavigationStruct)
}

class MapPostViewController: UIViewController, MGLMapViewDelegate  {
    
    var delegate: MapPostDelegate?
    var nav: NavigationStruct?
    var containerView: MDCCard?
   

    override func viewDidLoad() {
        super.viewDidLoad()

        containerView? = MDCCard()
        containerView?.setShadowElevation(ShadowElevation.cardResting, for: UIControl.State.normal)
        containerView?.inkView.inkColor = .lightGray
        containerView?.backgroundColor = UIColor.collectionBackGround()
    
        
        view.addSubview(containerView!)
        
        let url = URL(string: "mapbox://styles/mapbox/streets-v11")
        navigationItem.title = "Map Page"
        
        let mapView = MGLMapView(frame: view.bounds, styleURL: url)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        let center = CLLocationCoordinate2D(latitude: self.nav!.currentLocationLatitude! , longitude: self.nav!.currentLocationLongitude!)
        
        // Optionally set a starting point.
        mapView.setCenter(center, zoomLevel: 8, direction: 0, animated: false)
        
        // Initialize and add the marker annotation.
        let marker = MGLPointAnnotation()
        marker.coordinate = CLLocationCoordinate2D(latitude: nav!.destinationLocationLatitude! , longitude: nav!.destinationLocationLongitude!)
        marker.title = nav?.Title
        
        // This custom callout example does not implement subtitles.
        marker.subtitle = nav?.SubTitle
        
        // Add marker to the map.
        mapView.addAnnotation(marker)
        
        // Select the annotation so the callout will appear.
        mapView.selectAnnotation(marker, animated: false)
        containerView?.addSubview(mapView)
    
        setupLocationButton()
        actionButton.display(inViewController: self)
        
    }

    // Button creation and autolayout setup
    func setupLocationButton() {
        containerView?.addSubview(navButton)
        
        // Setup constraints such that the button is placed within
        // the upper left corner of the view.
        navButton.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            NSLayoutConstraint(item: navButton, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: view.safeAreaLayoutGuide.bottomAnchor, attribute: .bottom, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: navButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: navButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40 ),
            NSLayoutConstraint(item: navButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40)
        ]
        
        view.addConstraints(constraints)
      
        
        containerView?.addSubview(navButton2)
        navButton2.translatesAutoresizingMaskIntoConstraints = false
        let abConstraints = [
            NSLayoutConstraint(item: navButton2, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: view.safeAreaLayoutGuide.bottomAnchor, attribute: .bottom, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: navButton2, attribute: .left, relatedBy: .equal, toItem: navButton.rightAnchor, attribute: .left, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: navButton2, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40 ),
            NSLayoutConstraint(item: navButton2, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40)
        ]
        
        containerView?.addConstraints(abConstraints)
        
    }
    
    
    
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Only show callouts for `Hello world!` annotation.
        return annotation.responds(to: #selector(getter: MGLAnnotation.title)) && annotation.title! == "Hello world!"
    }
    
    //        func mapView(_ mapView: MGLMapView, calloutViewFor annotation: MGLAnnotation) -> MGLCalloutView? {
    //            // Instantiate and return our custom callout view.
    //            return CustomCalloutView(representedObject: annotation)
    //        }
    //
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        // Optionally handle taps on the callout.
        print("Tapped the callout for: \(annotation)")
        
        // Hide the callout.
        mapView.deselectAnnotation(annotation, animated: true)
    }

    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        // Wait for the map to load before initiating the first camera movement.
        
        // Create a camera that rotates around the same center point, rotating 180°.
        // `fromDistance:` is meters above mean sea level that an eye would have to be in order to see what the map view is showing.
        let camera = MGLMapCamera(lookingAtCenter: mapView.centerCoordinate, altitude: 1500, pitch: 15, heading: 180)
        
        // Animate the camera movement over 5 seconds.
        mapView.setCamera(camera, withDuration: 5, animationTimingFunction: CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
    }
    
    let navButton : MDCFloatingButton = {
        let fb = MDCFloatingButton()
        fb.backgroundColor = .white
        fb.tintColor = .white
        fb.setImage(#imageLiteral(resourceName: "ic_camera_white"), for: .normal)
        fb.imageTintColor(for: .focused)
        fb.addTarget(self, action: #selector(handleNavigate(_:)), for: .touchUpInside)
        return fb
    }()
    
    let navButton2 : MDCFloatingButton = {
        let fb = MDCFloatingButton()
        fb.backgroundColor = .white
        fb.tintColor = .white
        fb.setImage(#imageLiteral(resourceName: "carplay_minus"), for: .normal)
        fb.imageTintColor(for: .focused)
        fb.addTarget(self, action: #selector(handleNavigate(_:)), for: .touchUpInside)
        return fb
    }()
    
    let actionButton : JJFloatingActionButton = {
       let ab = JJFloatingActionButton()
        ab.itemAnimationConfiguration = .circularSlideIn(withRadius: 120)
        ab.buttonAnimationConfiguration = .rotation(toAngle: .pi * 3 / 4)
        ab.buttonAnimationConfiguration.opening.duration = 0.8
        ab.buttonAnimationConfiguration.closing.duration = 0.6
        
        ab.addItem(image: #imageLiteral(resourceName: "ic_settings_white")) { item in
            Helper.showAlert(for: item)
        }
        
        ab.addItem(image: #imageLiteral(resourceName: "ic_location_on_white")) { item in
            Helper.showAlert(for: item)
        }
        
        ab.addItem(image: #imageLiteral(resourceName: "ic_notifications_white")) { item in
            Helper.showAlert(for: item)
        }
        
        ab.addItem(image: #imageLiteral(resourceName: "feedback-confusing-directions")) { item in
            Helper.showAlert(for: item)
        }
        
        return ab
    }()
    
    var navigationViewController: NavigationViewController?
    var options: NavigationRouteOptions?

    @objc func handleNavigate(_ sender: UIButton) {
        print("Handle Navigation ... ")
        
        let origin = Waypoint(coordinate: CLLocationCoordinate2D(latitude: nav!.currentLocationLatitude! , longitude: nav!.currentLocationLongitude!), name: "Origin")
        let destination = Waypoint(coordinate: CLLocationCoordinate2D(latitude: nav!.destinationLocationLatitude!, longitude: nav!.destinationLocationLongitude!), name: nav?.Title)
        
        // Set options
        options = NavigationRouteOptions(waypoints: [origin, destination])

        Directions.shared.calculate(options!) { (waypoints, routes, error) in
            guard let route = routes?.first, error == nil else {
                print(error!.localizedDescription)
                return
            }

            let navigationService = MapboxNavigationService(route: route)
            let navigationOptions = NavigationOptions(navigationService: navigationService)
            self.navigationViewController = NavigationViewController(for: route, options: navigationOptions)
            self.navigationViewController?.delegate = self
            self.delegate?.didTapNavigation(navigation: self.nav!)
            
            self.present(self.navigationViewController!, animated: true, completion: nil)
        }
        
    }
}

extension MapPostViewController: NavigationViewControllerDelegate {
    // Never reroute internally. Instead,
    // 1. Fetch a route from your server
    // 2. Map Match the coordinates from your server
    // 3. Set the route on your server
    func navigationViewController(_ navigationViewController: NavigationViewController, shouldRerouteFrom location: CLLocation) -> Bool {
        
        // Here, we are simulating a custom server.
        let routeOptions = NavigationRouteOptions(waypoints: [Waypoint(location: location), self.options!.waypoints.last!])
        Directions.shared.calculate(routeOptions) { (waypoints, routes, error) in
            guard let routeCoordinates = routes?.first?.coordinates, error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            //
            // ❗️IMPORTANT❗️
            // Use `Directions.calculateRoutes(matching:completionHandler:)` for navigating on a map matching response.
            //
            let matchOptions = NavigationMatchOptions(coordinates: routeCoordinates)
            
            // By default, each waypoint separates two legs, so the user stops at each waypoint.
            // We want the user to navigate from the first coordinate to the last coordinate without any stops in between.
            // You can specify more intermediate waypoints here if you’d like.
            for waypoint in matchOptions.waypoints.dropFirst().dropLast() {
                waypoint.separatesLegs = false
            }
            
            Directions.shared.calculateRoutes(matching: matchOptions) { (waypoints, routes, error) in
                guard let route = routes?.first, error == nil else { return }
                
                // Set the route
                self.navigationViewController?.route = route
            }
        }
        
        return true
    }
}

