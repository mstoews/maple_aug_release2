//
//  MapboxViewController.swift
//  Maple
//
//  Created by Murray Toews on 2020/03/25.
//  Copyright © 2020 Murray Toews. All rights reserved.
//

import UIKit
import MapKit
import Mapbox
import LBTATools

class MapBoxSingleLocalViewController: UIViewController, MKMapViewDelegate {
    var mapView = MKMapView()
    
    override func viewDidLoad() {
    super.viewDidLoad()
        
        navigationItem.title = "Map Page"
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self

        // Enable heading tracking mode so that the arrow will appear.
        mapView.userTrackingMode = .followWithHeading

        // Enable the permanent heading indicator, which will appear when the tracking mode is not `.followWithHeading`.
        //mapView.showsUserHeadingIndicator = true

        view.addSubview(mapView)
        mapView.fillSuperview()
        setupViews()
        
    }
    
    func setupViews() {
        setupSearchUI()
    }
      let locationsController = LocationsCarouselController(scrollDirection: .horizontal)
        
        fileprivate func setupLocationsCarousel() {
            let locationsView = locationsController.view!
                
            view.addSubview(locationsView)
            locationsView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, size: .init(width: 0, height: 100))
        }
        
        let searchTextField = UITextField(placeholder: "Search query")
        
        fileprivate func setupSearchUI() {
            let whiteContainer = UIView(backgroundColor: .white)
            view.addSubview(whiteContainer)
            whiteContainer.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 16, bottom: 0, right: 16))
            
            whiteContainer.stack(searchTextField).withMargins(.allSides(16))
            
            if #available(iOS 13.0, *) {
                _ = NotificationCenter.default
                    .publisher(for: UITextField.textDidChangeNotification, object: searchTextField)
                    .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
                    .sink { (_) in
                        self.performLocalSearch()
                }
            } else {
                // Fallback on earlier versions
            }
        }
        
        @objc fileprivate func handleSearchChanges() {
            performLocalSearch()
        }
        
        fileprivate func performLocalSearch() {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchTextField.text
            request.region = mapView.region
            
            mapView.annotations.forEach { (annotation) in
                if annotation.title == "TEST" {
                    mapView.selectAnnotation(annotation, animated: true)
                }
            }
            
            let localSearch = MKLocalSearch(request: request)
            localSearch.start { (resp, err) in
                if let err = err {
                    print("Failed local search:", err)
                    return
                }
                
                // Success
                // remove old annotations
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.locationsController.items.removeAll()
                
                resp?.mapItems.forEach({ (mapItem) in
                    print(mapItem.address())
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = mapItem.placemark.coordinate
                    annotation.title = mapItem.name
                    self.mapView.addAnnotation(annotation)
                    
                    // tell my locationsCarouselController
                    self.locationsController.items.append(mapItem)
                })
                
                if resp?.mapItems.count != 0 { self.locationsController.collectionView.scrollToItem(at: [0, 0], at: .centeredHorizontally, animated: true)
                }
                
                self.mapView.showAnnotations(self.mapView.annotations, animated: true)
            }
        }
      
    fileprivate func requestUserLocation() {
        //locationManager.requestWhenInUseAuthorization()
        //locationManager.delegate = self
       }
       
       func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
           switch status {
           case .authorizedWhenInUse:
               print("Received authorization of user location")
               // request for where the user actually is
               //locationManager.startUpdatingLocation()
           default:
               print("Failed to authorize")
           }
       }
       
       func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           guard let firstLocation = locations.first else { return }
           mapView.setRegion(.init(center: firstLocation.coordinate, span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: false)
           
           //locationManager.stopUpdatingLocation()
       }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Only show callouts for `Hello world!` annotation.
        return annotation.responds(to: #selector(getter: MGLAnnotation.title)) && annotation.title! == "Hello world!"
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        // Substitute our custom view for the user location annotation. This custom view is defined below.
        if annotation is MGLUserLocation && mapView.userLocation != nil {
            return CustomUserLocationAnnotationView()
        }
        return nil
    }

    // Optional: tap the user location annotation to toggle heading tracking mode.
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        if mapView.userTrackingMode != .followWithHeading {
            mapView.userTrackingMode = .followWithHeading
        } else {
            mapView.resetNorth()
        }

        // We're borrowing this method as a gesture recognizer, so reset selection state.
        mapView.deselectAnnotation(annotation, animated: false)
    }
}


class CustomUserLocationAnnotationView: MGLUserLocationAnnotationView {
    let size: CGFloat = 48
    var dot: CALayer!
    var arrow: CAShapeLayer!

    // -update is a method inherited from MGLUserLocationAnnotationView. It updates the appearance of the user location annotation when needed. This can be called many times a second, so be careful to keep it lightweight.
    override func update() {
        if frame.isNull {
            frame = CGRect(x: 0, y: 0, width: size, height: size)
            return setNeedsLayout()
        }

        // Check whether we have the user’s location yet.
        if CLLocationCoordinate2DIsValid(userLocation!.coordinate) {
            setupLayers()
            updateHeading()
        }
    }

    private func updateHeading() {
        // Show the heading arrow, if the heading of the user is available.
        if let heading = userLocation!.heading?.trueHeading {
            arrow.isHidden = false

            // Get the difference between the map’s current direction and the user’s heading, then convert it from degrees to radians.
            let rotation: CGFloat = -MGLRadiansFromDegrees(mapView!.direction - heading)

            // If the difference would be perceptible, rotate the arrow.
            if abs(rotation) > 0.01 {
                // Disable implicit animations of this rotation, which reduces lag between changes.
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                arrow.setAffineTransform(CGAffineTransform.identity.rotated(by: rotation))
                CATransaction.commit()
            }
        } else {
            arrow.isHidden = true
        }
    }

    private func setupLayers() {
        // This dot forms the base of the annotation.
        if dot == nil {
            dot = CALayer()
            dot.bounds = CGRect(x: 0, y: 0, width: size, height: size)

            // Use CALayer’s corner radius to turn this layer into a circle.
            dot.cornerRadius = size / 2
            dot.backgroundColor = super.tintColor.cgColor
            dot.borderWidth = 4
            dot.borderColor = UIColor.white.cgColor
            layer.addSublayer(dot)
        }

        // This arrow overlays the dot and is rotated with the user’s heading.
        if arrow == nil {
            arrow = CAShapeLayer()
            arrow.path = arrowPath()
            arrow.frame = CGRect(x: 0, y: 0, width: size / 2, height: size / 2)
            arrow.position = CGPoint(x: dot.frame.midX, y: dot.frame.midY)
            arrow.fillColor = dot.borderColor
            layer.addSublayer(arrow)
        }
    }

    // Calculate the vector path for an arrow, for use in a shape layer.
    private func arrowPath() -> CGPath {
        let max: CGFloat = size / 2
        let pad: CGFloat = 3

        let top =    CGPoint(x: max * 0.5, y: 0)
        let left =   CGPoint(x: 0 + pad,   y: max - pad)
        let right =  CGPoint(x: max - pad, y: max - pad)
        let center = CGPoint(x: max * 0.5, y: max * 0.6)

        let bezierPath = UIBezierPath()
        bezierPath.move(to: top)
        bezierPath.addLine(to: left)
        bezierPath.addLine(to: center)
        bezierPath.addLine(to: right)
        bezierPath.addLine(to: top)
        bezierPath.close()

        return bezierPath.cgPath
    }
}

