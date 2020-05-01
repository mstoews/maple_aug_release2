//
//  GoogleMapController.swift
//  Maple
//
//  Created by Murray Toews on 4/26/20.
//  Copyright © 2020 Murray Toews. All rights reserved.
//

import UIKit
//import GooglePlaces
import MapKit
import CoreLocation

extension GMPViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation is MKPointAnnotation) {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
            annotationView.canShowCallout = true
            return annotationView
        }
        return nil
    }
    
}


class GMPViewController: UIViewController, CLLocationManagerDelegate {

  var placesClient: GMSPlacesClient!

  // Add a pair of UILabels in Interface Builder, and connect the outlets to these variables.
    

     let mapView = MKMapView()
     let locationManager = CLLocationManager()

     
     fileprivate func requestUserLocation() {
         locationManager.delegate = self
         locationManager.requestWhenInUseAuthorization()
     }
     
     func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
         switch status {
         case .authorizedWhenInUse:
             print("Received authorization of user location")
             // request for where the user actually is
             locationManager.startUpdatingLocation()
         default:
             print("Failed to authorize")
         }
     }
     
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         guard let firstLocation = locations.first else { return }
         mapView.setRegion(.init(center: firstLocation.coordinate, span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: false)
         
         locationManager.stopUpdatingLocation()
     }
     
    
  let nameLabel : UILabel = {
         let ui = UILabel()
         ui.text = "Itabashi"
         ui.backgroundColor = UIColor.red
         return ui
     }()
    
  let addressLabel : UILabel = {
         let ui = UILabel()
         ui.text = "Itabashi 3-chome"
         ui.backgroundColor = UIColor.red
         return ui
     }()
    
    lazy var goMaps: UIButton = {
           let button = UIButton(type: .system)
           button.backgroundColor = UIColor.collectionBackGround()
           button.setImage(#imageLiteral(resourceName: "search_selected"), for: .normal)
           button.setTitle( "GO to Maps" , for: .normal)
           button.setTitleColor( UIColor.buttonThemeColor() , for: .normal)
           button.tintColor = UIColor.buttonThemeColor()
           button.sizeToFit()
           button.addTarget(self, action: #selector(getCurrentPlace), for: .touchUpInside)
           return button
       }()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    placesClient = GMSPlacesClient.shared()
    requestUserLocation()

    mapView.delegate = self
    mapView.showsUserLocation = true
    view.addSubview(mapView)
    mapView.fillSuperview()
    
    let paddingSize = CGFloat(2.0)
    let topPadding = CGFloat(100)
    
    let stackLabel = UIStackView(arrangedSubviews: [nameLabel, addressLabel, goMaps])
    stackLabel.distribution = .fillProportionally
    stackLabel.axis = .vertical
    view.addSubview(stackLabel)
    stackLabel.anchor( top: view.topAnchor,left: view.leftAnchor, bottom: nil,
                      right: nil,
                      paddingTop: topPadding,
                      paddingLeft: paddingSize,
                      paddingBottom: paddingSize ,
                      paddingRight: paddingSize,
                      width: view.frame.width ,
                      height: 120)
  }

  // Add a UIButton in Interface Builder, and connect the action to this function.
  @objc func getCurrentPlace()
  
  {

    placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
      if let error = error {
        print("Current Place error: \(error.localizedDescription)")
        return
      }

      self.nameLabel.text = "No current place"
      self.addressLabel.text = ""

      if let placeLikelihoodList = placeLikelihoodList {
        let place = placeLikelihoodList.likelihoods.first?.place
        if let place = place {
          self.nameLabel.text = place.name
          self.addressLabel.text = place.formattedAddress?.components(separatedBy: ", ")
            .joined(separator: "\n")
        }
      }
    })
  }
}
