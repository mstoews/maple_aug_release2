//
//  HomeViewPostController.swift
//  maple-release
//
//  Created by Murray Toews on 2018/02/08.
//  Copyright © 2018 Murray Toews. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
import DKImagePickerController
import Sharaku
import os.log
//mport ImageViewer


class HomeViewPostController:
    UIViewController,
    UITextFieldDelegate ,
    UISearchDisplayDelegate,
    UITextViewDelegate,
    SHViewControllerDelegate
{
    var mapObjects = [LocationObject]()
    var imageArray = [UIImage]()
    var imageUrlArray = [String]()
    let cellId = "cellId"
    let mapCellId = "mapCellId"
    var isMapCell = false
    var mapViewController: BackgroundMapViewController?
    var UIMapController: UIViewController?
    var docRef : DocumentReference!
    //var post : Post?
    

    let pictureSize = 300.00
    
    
    var post: Post? {
        didSet {
                imagePostView.loadImage(urlString: (post?.imageUrl)!)
                Products.text = post?.caption
                Description.text = post?.description
        }
    }
    
    fileprivate func setupImageAndTextViews() {
        
        
        let buttonPadding : CGFloat = 5.0
        let containerView = UIView()
        
        view.backgroundColor = .white
        let topDividerView = UIView()
        
        topDividerView.backgroundColor = UIColor.lightGray
        containerView.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor.lightGray
        
        view.addSubview(containerView)
        containerView.addSubview(topDividerView)
        containerView.addSubview(bottomDividerView)
        containerView.addSubview(imagePostView)
        containerView.addSubview(Products)
        containerView.addSubview(Description)
        
        // 1. Stack View
        if #available(iOS 11.0, *) {
        containerView.anchor(top: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        }
        else
        {
            containerView.anchor(top: view.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        }
        
        topDividerView.anchor(top: containerView.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 5 , paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 0, height: 0.5)
        // 2. Products : parent = ContainerView
        Products.anchor(top: topDividerView.bottomAnchor , left: view.leftAnchor, bottom: nil , right: view.rightAnchor , paddingTop: 4 , paddingLeft: buttonPadding, paddingBottom: 0, paddingRight: buttonPadding, width: 0 , height: 40)
    
        // 3. Descriptiong : parent = Products
        Description.anchor(top: Products.bottomAnchor, left: view.leftAnchor, bottom: nil , right: view.rightAnchor, paddingTop: 4 , paddingLeft: buttonPadding, paddingBottom: 4 , paddingRight: buttonPadding, width: 0 , height: 60)
        imagePostView.anchor(top: Description.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor , right: view.rightAnchor)
        
    }
    
    
    private let noneText = NSLocalizedString("PlaceDetails.MissingValue",
                                             comment: "The value of a property which is missing")
    
    private func text(for priceLevel: GMSPlacesPriceLevel) -> String {
        switch priceLevel {
        case .free: return NSLocalizedString("Places.PriceLevel.Free",comment: "Relative cost for a free location")
        case .cheap: return NSLocalizedString("Places.PriceLevel.Cheap",comment: "Relative cost for a cheap location")
        case .medium: return NSLocalizedString("Places.PriceLevel.Medium",comment: "Relative cost for a medium cost location")
        case .high: return NSLocalizedString("Places.PriceLevel.High",comment: "Relative cost for a high cost location")
        case .expensive: return NSLocalizedString("Places.PriceLevel.Expensive",comment: "Relative cost for an expensive location")
        case .unknown: return NSLocalizedString("Places.PriceLevel.Unknown",comment: "Relative cost for when it is unknown")
        }
    }
    
    var selectedImage: UIImage? {
        didSet {
            self.imageView.image = selectedImage
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rgb(red: 220, green: 240, blue: 240)
        navigationItem.title = Products.text
        //setNavigationButtons()
        self.view.tintColor = UIColor.red
         setupImageAndTextViews()
     }
    
    func completionHandler() {
        self.locationCollectionView.reloadData()
        print("completionHandler: save boolean")
    }
    
    fileprivate func reloadData()
    {
        if mapObjects.count > 0 {
            DispatchQueue.main.async {
                self.locationCollectionView.reloadData()
            }
        }
    }
    
    var currentImage = 0
    
    var currentImageItem : Int?
    
    func shViewControllerImageDidFilter(image: UIImage) {
        if currentImageItem! >= 0 {
            imageArray[currentImageItem!] = image
        }
    }
    
    func shViewControllerDidCancel() {
        print ("print ...")
    }
    
    
    @objc func handleOpenMaps()
    {
        isMapCell = true
        print("Open the maps window")
        //let mapController = MapLocationController()
        //let navController = UINavigationController(rootViewController: mapController)
        //present(navController, animated: true, completion: nil)
    }
    
    
    let imagePostView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let locationCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(hue: 30/360, saturation: 2/100, brightness: 99/100, alpha: 0.8)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.layer.cornerRadius = 10
        return collectionView
    }()
    
    let Products: UILabel = {
        let TextField = UILabel()
        TextField.font = UIFont.systemFont(ofSize: 15)
        TextField.backgroundColor =  UIColor(hue: 30/360, saturation: 2/100, brightness: 99/100, alpha: 0.8)
        TextField.numberOfLines = 0
         return TextField
    }()
    
    let Description: UILabel = {
        let TextField = UILabel()
        TextField.font = UIFont.systemFont(ofSize: 15)
        TextField.backgroundColor =  UIColor(hue: 30/360, saturation: 2/100, brightness: 99/100, alpha: 0.8)
        TextField.numberOfLines = 0
        return TextField
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .white
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        let imageName = ""
        let image = UIImage(named: imageName)
        iv.image = image
        return iv
    }()
    
    var PrefersStatusBarHidden: Bool {
        return true
    }
    
    func handleShare(){}
    
}


extension HomeViewPostController : GMSPlacePickerViewControllerDelegate {
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Create the next view controller we are going to display and present it.
        let nextScreen = PlaceDetailViewController(place: place)
        self.splitPaneViewController?.push(viewController: nextScreen, animated: false)
        self.mapViewController?.coordinate = place.coordinate
        // Dismiss the place picker.
        let placePickerObject = LocationObject(place: place)
        mapObjects.append(placePickerObject!)
        locationCollectionView.reloadData()
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didFailWithError error: Error) {
        // In your own app you should handle this better, but for the demo we are just going to log
        // a message.
        NSLog("An error occurred while picking a place: \(error)")
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        NSLog("The place picker was canceled by the user")
        
        // Dismiss the place picker.
        viewController.dismiss(animated: true, completion: nil)
        dismiss(animated: true, completion: nil)
    }
}





