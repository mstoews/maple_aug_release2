import UIKit
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import Mapbox
import MaterialComponents

class AdvancedNavigationController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate, NavigationMapViewDelegate, NavigationViewControllerDelegate {
    
    var nav: Navigation?
    var mapView: NavigationMapView?
    var currentRoute: Route? {
        get {
            return routes?.first
        }
        set {
            guard let selected = newValue else { routes?.remove(at: 0); return }
            guard let routes = routes else { self.routes = [selected]; return }
            self.routes = [selected] + routes.filter { $0 != selected }
        }
    }
    var routes: [Route]? {
        didSet {
            guard let routes = routes, let current = routes.first else { mapView?.removeRoutes(); return }
            mapView?.showRoutes(routes)
            mapView?.showWaypoints(current)
        }
    }
    
    var locationManager = CLLocationManager()
    
    private typealias RouteRequestSuccess = (([Route]) -> Void)
    private typealias RouteRequestFailure = ((NSError) -> Void)
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        let url = URL(string: "mapbox://styles/mapbox/streets-v10")
        navigationItem.title = "Map Page"
        
        mapView = NavigationMapView(frame: view.bounds, styleURL: url)
        mapView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView?.userTrackingMode = .follow
        mapView?.delegate = self
        mapView?.navigationMapViewDelegate = self
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        mapView?.addGestureRecognizer(gesture)
        
        // Initialize and add the marker annotation.
        let marker = MGLPointAnnotation()
        marker.coordinate = CLLocationCoordinate2D(latitude: nav!.destinationLocationLatitude! , longitude: nav!.destinationLocationLongitude!)
        marker.title = nav?.Title
        
        // This custom callout example does not implement subtitles.
        marker.subtitle = nav?.SubTitle
        
        // Add marker to the map.
        mapView!.addAnnotation(marker)
        
        // Select the annotation so the callout will appear.
        mapView!.selectAnnotation(marker, animated: true)
       
        view.addSubview(mapView!)
        setRoute()
    }
    
    //overriding layout lifecycle callback so we can style the start button
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupLocationButton()
    }
    
    func setRoute()
    {
        let location = CLLocationCoordinate2D(latitude: nav!.destinationLocationLatitude! , longitude: nav!.destinationLocationLongitude!)
        requestRoute(destination: location)
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        // Wait for the map to load before initiating the first camera movement.
        
        // Create a camera that rotates around the same center point, rotating 180°.
        // `fromDistance:` is meters above mean sea level that an eye would have to be in order to see what the map view is showing.
        let camera = MGLMapCamera(lookingAtCenter: mapView.centerCoordinate, altitude: 4500, pitch: 15, heading: 180)
        //let camera = MGLMapCamera(lookingAtCenter: mapView.centerCoordinate, altitude: 500, pitch: 15, heading: 180)
        
        // Animate the camera movement over 5 seconds.
        mapView.setCamera(camera, withDuration: 5, animationTimingFunction: CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
    }

    
    
    // Button creation and autolayout setup
    func setupLocationButton() {
        view.addSubview(navButton)
        
        // Setup constraints such that the button is placed within
        // the upper left corner of the view.
        navButton.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            NSLayoutConstraint(item: navButton, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 10),
            //NSLayoutConstraint(item: navButton, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: view.safeAreaLayoutGuide.bottomAnchor, attribute: .bottom, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: navButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: navButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48 ),
            NSLayoutConstraint(item: navButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48)
        ]
        
        view.addConstraints(constraints)
    }
    
    let navButton : MDCFloatingButton = {
        let fb = MDCFloatingButton()
        fb.backgroundColor = .white
        fb.tintColor = .white
        fb.setImage(#imageLiteral(resourceName: "ic_navigation"), for: .normal)
        fb.imageTintColor(for: .focused)
        fb.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
        return fb
    }()
    

    @objc func tappedButton() {
        print ("AdvancedNavigationController::tappedbutton")
        guard let route = currentRoute else { return }
        // For demonstration purposes, simulate locations if the Simulate Navigation option is on.
        //let navigationService = MapboxNavigationService(route: route, simulating: simulationIsEnabled ? .always : .onPoorGPS)
        let navigationService = MapboxNavigationService(route: route )
        let navigationOptions = NavigationOptions(navigationService: navigationService)
        let navigationViewController = NavigationViewController(for: route, options: navigationOptions)
        navigationViewController.delegate = self
        present(navigationViewController, animated: true, completion: nil)
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .ended else { return }
        
        //let spot = gesture.location(in: mapView)
        //guard let location = mapView?.convert(spot, toCoordinateFrom: mapView) else { return }
        
        let location = CLLocationCoordinate2D(latitude: nav!.destinationLocationLatitude! , longitude: nav!.destinationLocationLongitude!)
        
        requestRoute(destination: location)
    }
    
    func requestRoute(destination: CLLocationCoordinate2D) {
        guard let userLocation = mapView?.userLocation!.location else { return }
        let userWaypoint = Waypoint(location: userLocation, heading: mapView?.userLocation?.heading, name: "user")
        let destinationWaypoint = Waypoint(coordinate: destination)
        
        let profileTransport = MBDirectionsProfileIdentifier.walking
        //MBDirectionsProfileIdentifier.automobile
        
        //let options = NavigationRouteOptions(waypoints: [userWaypoint, destinationWaypoint])
        let options = NavigationRouteOptions(waypoints: [userWaypoint, destinationWaypoint], profileIdentifier: profileTransport)
        
        Directions.shared.calculate(options) { (waypoints, routes, error) in
            guard let routes = routes else { return }
            self.routes = routes
            self.navButton.isHidden = false
            self.mapView?.showRoutes(routes)
            self.mapView?.showWaypoints(self.currentRoute!)
        }
    }
    
    // Delegate method called when the user selects a route
    func navigationMapView(_ mapView: NavigationMapView, didSelect route: Route) {
        self.currentRoute = route
    }
}

