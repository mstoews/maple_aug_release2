/*
 * Copyright 2016 Google Inc. All rights reserved.
 *
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
 * file except in compliance with the License. You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

import UIKit
import GoogleMaps
import GooglePlaces
//import Floaty

protocol PlaceDetailViewControllerDelegate : class {
    func didFinishTask(sender: SharePhotoController)
    func didSaveMapPlace(place: GMSPlace)
}

extension SharePhotoController : PlaceDetailViewControllerDelegate {
    func didFinishTask(sender: SharePhotoController) {
        
    }
    func didSaveMapPlace(place: GMSPlace) {
        let mp = locObject(place: place)
        mapObjects.append(mp!)
    }
}

/// A view controller which displays details about a specified |GMSPlace|.
class PlaceDetailViewController: BaseContainerViewController {
  let place: GMSPlace
  @IBOutlet private weak var photoView: UIImageView!
  @IBOutlet private weak var mapView: GMSMapView!
  @IBOutlet var tableBackgroundView: UIView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var statusBarShadow: ShadowLineView!
  @IBOutlet weak var navigationBar: UIView!
  @IBOutlet weak var headerHeightExtension: UIView!
  @IBOutlet weak var headerHeightExtensionConstraint: NSLayoutConstraint!
  @IBOutlet weak var photoWidthConstraint: NSLayoutConstraint!
  private lazy var placesClient = { GMSPlacesClient.shared() } ()
  private static let photoSize = CGSize(width: 450, height: 300)
  private var tableDataSource: PlaceDetailTableViewDataSource!
  
 
  init(place: GMSPlace) {
    self.place = place
    super.init(nibName: String(describing: type(of: self)), bundle: nil)
  }

    
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  weak var delegate : PlaceDetailViewControllerDelegate?
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Configure the table
    tableDataSource =
      PlaceDetailTableViewDataSource(place: place,
                                     extensionConstraint: headerHeightExtensionConstraint,
                                     tableView: tableView)
    tableView.backgroundView = tableBackgroundView
    tableView.dataSource = tableDataSource
    tableView.delegate = tableDataSource

    // Configure the UI elements
    lookupPhoto()
    configureMap()
    configureBars()
    
  }

   
    override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateNavigationBarState(actualTraitCollection)
    updateStatusBarState(actualTraitCollection)
    updateFloaterButton()
  }

  override func willTransition(to newCollection: UITraitCollection,
                               with coordinator: UIViewControllerTransitionCoordinator) {

    super.willTransition(to: newCollection, with: coordinator)

    updateNavigationBarState(newCollection)
    updateStatusBarState(newCollection)
  }

  override func viewWillTransition(to size: CGSize,
                                   with coordinator: UIViewControllerTransitionCoordinator) {

    super.viewWillTransition(to: size, with: coordinator)

    updateStatusBarState(actualTraitCollection)
  }

  private func updateFloaterButton() {
//        let item = FloatyItem()
//        item.hasShadow = false
//        item.buttonColor = UIColor.white
//        item.circleShadowColor = UIColor.blue
//        item.titleShadowColor = UIColor.blue
//        item.titleLabelPosition = .left
//        item.title = "Return"
//        item.icon = UIImage(named:"icons8-exit-sign-filled-24")
//        item.handler = { item in
//            print ("handle item")
//            self.backButtonTapped()
//        }
//    
//        let itemAdd = FloatyItem()
//        itemAdd.hasShadow = false
//        itemAdd.buttonColor = UIColor.white
//        itemAdd.circleShadowColor = UIColor.blue
//        itemAdd.titleShadowColor = UIColor.blue
//        itemAdd.titleLabelPosition = .left
//        itemAdd.title = "Add place"
//        itemAdd.icon = UIImage(named:"icons8-place-marker-50")
//        itemAdd.handler = { item in
//            print("handle add place\n\(self.place)")
//            self.delegate?.didSaveMapPlace(place : self.place)
//            self.splitPaneViewController?.popViewController()
//        }
//        
//        let floater = Floaty()
//        floater.friendlyTap = true
//        floater.buttonColor = .white
//        floater.itemImageColor = .white
//        floater.hasShadow = true
//    
//        // add items to menu
//        floater.addItem(item: item)
//        floater.addItem(item: itemAdd)
//        floater.fabDelegate = self
//        view.addSubview(floater)
//        floater.paddingX = 20.00
//        floater.paddingY = 60.00
    }
    
    
  private func lookupPhoto() {
    // Lookup the photos associated with this place.
    placesClient.lookUpPhotos(forPlaceID: place.placeID) { (metadata, error) in
      // Handle the result if it was successful.
      if let metadata = metadata {
        // Check to see if any photos were found.
        if !metadata.results.isEmpty {
          // If there were load the first one.
          self.loadPhoto(metadata.results[0])
        } else {
          NSLog("No photos were found")
        }
      } else if let error = error {
        NSLog("An error occured while looking up the photos: \(error)")
      } else {
        fatalError("An unexpected error occured")
      }
    }
  }

  private func loadPhoto(_ photo: GMSPlacePhotoMetadata) {
    // Load the specified photo.
    placesClient.loadPlacePhoto(photo, constrainedTo: PlaceDetailViewController.photoSize,
                                scale: view.window?.screen.scale ?? 1) { (image, error) in
                                  // Handle the result if it was successful.
                                  if let image = image {
                                    self.photoView.image = image
                                    self.photoWidthConstraint.isActive = false
                                  } else if let error = error {
                                    NSLog("An error occured while loading the first photo: \(error)")
                                  } else {
                                    fatalError("An unexpected error occured")
                                  }
    }
  }

  private func configureMap() {
    // Place a marker on the map and center it on the desired coordinates.
    let marker = GMSMarker(position: place.coordinate)
    marker.map = mapView
    mapView.camera = GMSCameraPosition(target: place.coordinate, zoom: 15, bearing: 0,
                                       viewingAngle: 0)
    mapView.isUserInteractionEnabled = false
  }

  private func configureBars() {
    // Configure the drop-shadow we display under the status bar.
    statusBarShadow.enableShadow = true
    statusBarShadow.shadowOpacity = 1
    statusBarShadow.shadowSize = 40
    
    
    
    // Add a constraint to the top of the navigation bar so that it respects the top layout guide.
     if #available(iOS 11.0, *) {
        NSLayoutConstraint(item: navigationBar, attribute: .top, relatedBy: .equal,
                       toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1,
                       constant: 0).isActive = true
    }
     else{
        NSLayoutConstraint(item: navigationBar, attribute: .top, relatedBy: .equal,
                           toItem: view.topAnchor, attribute: .bottom, multiplier: 1,
                           constant: 0).isActive = true
    }
    
        
    // Set the color of the hight extension view.
    headerHeightExtension.backgroundColor = Colors.blue2
  }

  private func updateNavigationBarState(_ traitCollection: UITraitCollection) {
    // Hide the navigation bar if we have enough space to be split-screen.
    let isNavigationBarHidden = traitCollection.horizontalSizeClass == .regular
    navigationBar.isHidden = isNavigationBarHidden
    tableDataSource.offsetNavigationTitle = !isNavigationBarHidden
    tableDataSource.updateNavigationTextOffset()
  }

  private func updateStatusBarState(_ traitCollection: UITraitCollection) {
    // Hide the shadow if we are not right against the status bar.
    let hasMargin = insetViewController?.hasMargin ?? false
    statusBarShadow.isHidden = hasMargin

    // Transition to a compact navigation bar layout if the status bar is hidden.
    tableDataSource.compactHeader = traitCollection.verticalSizeClass == .compact
  }

  @IBAction func backButtonTapped() {
    splitPaneViewController?.popViewController()
  }
}
