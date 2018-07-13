//
//  EditPostController.swift
//  maple
//
//  Created by Murray Toews on 2017-07-23.
//  Copyright © 2017 mapleon. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import Kingfisher
import INSPhotoGallery


class PostsImage: BaseCell
{
    var  url: String?  {
        didSet {
            photoImageView.loadImage(urlString: url!)
        }
    }
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? UIColor.blue  : UIColor.clear
        }
    }
    
}



class EditPostController: UIViewController,CLLocationManagerDelegate,  UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GMSMapViewDelegate {

    var postCellId = "postCellId"
    var searchController = UISearchController()
    var resultsViewController: GMSAutocompleteResultsViewController?
    var placesClient: GMSPlacesClient!
    var numberOfLikes : Int?
    
    let locationManager = CLLocationManager()
   
    var post: FSPost? {
        didSet {
            title =  "Where it is ..."
            locations.removeAll()
            setupAttributedCaption()
            if let uid = post?.uid  {
                Firestore.fetchLocationByUserId(uid: uid) { (locationObjects) in
                    for location in locationObjects {
                        self.locations.append(location)
                        if let product = location.types {
                            if let desc = location.address {
                                self.markerByLocation(location, desc, product)
                            }
                        }
                    }
                }
            }
            if let product = post?.product {
                productLabel.text = product
            }
            if let category = post?.category {
                if let product = post?.product {
                    if category.count > 0  {
                        productLabel.text = product + "/" + category
                    }
                }
            }
            //guard let profileImageUrl = post?.user.profileImageUrl else { return }
                //userProfileImageView.loadImage(urlString: profileImageUrl)
                imageCollectionView.reloadData()
        }
    }
    
    
    
    let imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.collectionBackGround()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    func didTapImage(for cell: PostsImage, post: FSPost) {
        
        var photos: [PhotoViewModel] = []
        
        for url in post.imageUrlArray {
            let pt = PhotoViewModel(imageURL: URL(string: url),thumbnailImageURL: URL(string: url))
            pt.caption = post.product
            photos.append(pt)
        }
        
        let currentPhoto = photos[0]
        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: cell)
        present(galleryPreview, animated: true, completion: nil)
        
    }
    
    fileprivate func setupAttributedCaption() {
        guard let post = self.post else { return }
        let attributedText = NSMutableAttributedString(string: "", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 10)])
        attributedText.append(NSAttributedString(string: "\(post.description)", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: "\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 6)]))
        
        let timeAgoDisplay = post.creationDate.timeAgoDisplay()
        attributedText.append(NSAttributedString(string: timeAgoDisplay, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12), NSAttributedStringKey.foregroundColor: UIColor.gray]))
        Description.attributedText = attributedText
    }
    
    
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
            let camera = GMSCameraPosition.camera(withLatitude: location.latitude!, longitude: location.longitude!, zoom: 14)
            self.mapView.camera = camera
            marker.title = "\(location.location!)"
            marker.snippet = "\(category)\n\(locationResult)"
            marker.icon = UIImage(imageLiteralResourceName: "ic_place")
            marker.map = self.mapView
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if post != nil {
            return (post?.imageUrlArray.count)!
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postCellId, for: indexPath) as! PostsImage
        cell.url = post?.imageUrlArray[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width / 2 - 10
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 0, 0, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postCellId, for: indexPath) as! PostsImage
        didTapImage(for: cell, post: post!)
    }
    
    // NSLocationAlwaysAndWhenInUseUsageDescription
    // NSLocationWhenInUseUsageDescription
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rgb(red: 100, green: 240, blue: 240)
        view.backgroundColor = .white
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        imageCollectionView.register(PostsImage.self, forCellWithReuseIdentifier: postCellId)
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate =  self
        placesClient = GMSPlacesClient.shared()
        
    }
    
    
    func didTapImageCell(for cell: UserImageCell, post: Post) {
        
        var photos: [PhotoViewModel] = []
        
        for url in post.imageUrlArray {
            let pt = PhotoViewModel(imageURL: URL(string: url),thumbnailImageURL: URL(string: url))
            pt.caption = post.caption
            photos.append(pt)
        }
        
        let currentPhoto = photos[0]
        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: cell)
        present(galleryPreview, animated: true, completion: nil)
        
    }
    
    lazy var filterPhotos: UIButton = {
        let button = UIButton(type: .system)
        //button.setImage(#imageLiteral(resourceName: "icons8-filter"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "ic_filter"), for: .normal)
        button.tintColor = .black
        button.sizeToFit()
        button.addTarget(self, action: #selector(handleFilter), for: .touchUpInside)
        return button
    }()
    
    lazy var addPhotos: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_add_to_photos"), for: .normal)
        button.sizeToFit()
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleAddPhotos), for: .touchUpInside)
        return button
    }()
    
    
    lazy var mapGoHome: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "coordinate"), for: .normal)
        button.tintColor = .black
        button.sizeToFit()
        button.addTarget(self, action: #selector(handleNavigation), for: .touchUpInside)
        return button
    }()
    
    lazy var mapSetType: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_map"), for: .normal)
        button.sizeToFit()
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleAddPhotos), for: .touchUpInside)
        return button
    }()
    
    
    
    lazy var prodIcon : UIButton = {
        let ib = UIButton()
        ib.contentMode = .scaleAspectFill
        ib.setImage(#imageLiteral(resourceName: "ic_shopping_cart"), for: .normal)
        ib.clipsToBounds = true
        return ib
    }()
    
    var locations = [LocationObject]()
    
    @objc func handleNavigation()
    {
        let testURL = URL(string: "comgooglemaps-x-callback://")!
        if UIApplication.shared.canOpenURL(testURL) {
            let directionsRequest = "comgooglemaps-x-callback://" +
                "?daddr=John+F.+Kennedy+International+Airport,+Van+Wyck+Expressway,+Jamaica,+New+York" +
            "&x-success=sourceapp://?resume=true&x-source=AirApp"
            
            let directionsURL = URL(string: directionsRequest)!
            UIApplication.shared.open(directionsURL)
        } else {
            //NSLog("Can't use comgooglemaps-x-callback:// on this device.")
            
            let customURL = "https://maps.google.com/maps"
            let location = locations[0]
            
            if UIApplication.shared.canOpenURL(NSURL(string: customURL)! as URL) {
                UIApplication.shared.open(URL(string:"https://maps.google.com/maps/?center=\(String(describing: location.latitude)),\(String(describing: location.longitude))&zoom=14&views=traffic&q=\(String(describing: location.latitude)),\(String(describing: location.longitude))")!, options: [:], completionHandler: nil)
                
                let urlTEST = "https://maps.google.com/maps/?daddr=Roppongi%20Hills%20Mori%20Tower%20Tokyo%20Japan&dirflg=r"
                UIApplication.shared.open(URL(string: urlTEST)!) //, options: [:], completionHandler: nil)
            }
        }
    }
    
    @objc func handleFilter()
    {
        
    }
    
    @objc func handleAddPhotos()
    {
        
    }
    

    fileprivate func setMapMenu() -> UIView
    {
        let editMenu = UIView()
        editMenu.backgroundColor = UIColor.blue
        editMenu.layer.cornerRadius = 10
        editMenu.backgroundColor = .white
        editMenu.layer.borderWidth = 2
        editMenu.layer.borderColor = UIColor.black.cgColor
        return editMenu
    }
    
    override func viewDidLayoutSubviews() {
        let containerView = UIView()
        
        let editMenu = UIView()
        editMenu.backgroundColor = UIColor.blue
        editMenu.layer.cornerRadius = 10
        editMenu.backgroundColor = .white
        editMenu.layer.borderWidth = 2
        editMenu.layer.borderColor = UIColor.black.cgColor
        
        let mapMenu = setMapMenu()
    
        //let stackButtonsVerical = UIStackView(arrangedSubviews: [addPhotos,filterPhotos,erasePhotos])
        let stackButtonsVerical = UIStackView(arrangedSubviews: [addPhotos,filterPhotos])
        stackButtonsVerical.axis = .vertical
        stackButtonsVerical.distribution = .fillEqually
        
        editMenu.addSubview(stackButtonsVerical)
        
        let stackVerticalMapButtons = UIStackView(arrangedSubviews: [mapGoHome,mapSetType])
        stackVerticalMapButtons.axis = .vertical
        stackVerticalMapButtons.distribution = .fillEqually
        mapMenu.addSubview(stackVerticalMapButtons)
        
        
        containerView.backgroundColor = UIColor.veryLightGray()
        view.addSubview(containerView)
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, bookmarkButton])
        stackView.distribution = .fillEqually
        //containerView.addSubview(userProfileImageView)
        containerView.addSubview(prodIcon)
        containerView.addSubview(productLabel)
        containerView.addSubview(imageCollectionView)
        containerView.addSubview(topDividerView)
        containerView.addSubview(bottomDividerView)
        //containerView.addSubview(stackView)
        containerView.addSubview(Description)
        //containerView.addSubview(mapviewDividerView)
        containerView.addSubview(mapView)
        containerView.addSubview(editMenu)
        containerView.addSubview(mapMenu)
        
        let heightOfViewController = view.frame.width / 2 - 10
        
        if #available(iOS 11.0, *) {
            containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                 left: view.leftAnchor,
                                 bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                 right: view.rightAnchor)
        } else {
            // Fallback on earlier versions
            containerView.anchor(top: view.topAnchor,
                                 left: view.leftAnchor,
                                 bottom: view.bottomAnchor,
                                 right: view.rightAnchor)
        }
        
        prodIcon.anchor(top: containerView.topAnchor,
                        left: containerView.leftAnchor,
                        bottom: nil ,
                        right: nil,
                        paddingTop: 0,
                        paddingLeft: 5,
                        paddingBottom: 0,
                        paddingRight: 5,
                        width: 40,
                        height: 40)
        
        productLabel.anchor(top: containerView.topAnchor,
                                   left: prodIcon.rightAnchor,
                                   bottom: nil ,
                                   right: containerView.rightAnchor,
                                   paddingTop: 0,
                                   paddingLeft: 5,
                                   paddingBottom: 0,
                                   paddingRight: 5,
                                   width: 0,
                                   height: 40)
        
        
        imageCollectionView.anchor(top: productLabel.bottomAnchor,
                                   left: containerView.leftAnchor,
                                   bottom: nil ,
                                   right: containerView.rightAnchor,
                                   paddingTop: 0,
                                   paddingLeft: 5,
                                   paddingBottom: 0,
                                   paddingRight: 5,
                                   width: 0,
                                   height: heightOfViewController)
        
        topDividerView.anchor(top: imageCollectionView.bottomAnchor,
                              left: containerView.leftAnchor,
                              bottom: nil,
                              right: containerView.rightAnchor,
                              paddingTop: 2 ,
                              paddingLeft: 0,
                              paddingBottom: 0,
                              paddingRight: 0,
                              width: 0,
                              height: 0.5)
        
       

        
        Description.anchor(top: topDividerView.bottomAnchor ,
                           left: containerView.leftAnchor,
                           bottom: nil ,
                           right: containerView.rightAnchor,
                           paddingTop: 0,
                           paddingLeft: 5,
                           paddingBottom: 0,
                           paddingRight: 5,
                           width: 0,
                           height: 60)
        
        
        bottomDividerView.anchor(top:  Description.bottomAnchor,
                                 left: containerView.leftAnchor,
                                 bottom: nil,
                                 right: containerView.rightAnchor,
                                 paddingTop: 0 ,
                                 paddingLeft: 0,
                                 paddingBottom: 0,
                                 paddingRight: 0,
                                 width: 0, height: 1.0)
        
        mapView.anchor(top: bottomDividerView.bottomAnchor,
                       left: containerView.leftAnchor,
                       bottom: containerView.bottomAnchor,
                       right: containerView.rightAnchor,
                       paddingTop: 5 ,
                       paddingLeft: 5,
                       paddingBottom: 5,
                       paddingRight: 5,
                       width: 0, height: 0)
        
        
        //stackButtonsVerical.anchor(top: editMenu.topAnchor, left: editMenu.leftAnchor, bottom: editMenu.bottomAnchor, right: editMenu.rightAnchor)
        //editMenu.anchor(top: imageCollectionView.topAnchor, left: nil, bottom: nil, right: imageCollectionView.rightAnchor, paddingTop: 10, paddingLeft: 5, paddingBottom: 0, paddingRight: 15, width: 50, height: 120)
       
        stackVerticalMapButtons.anchor(top: mapView.topAnchor, left: mapMenu.leftAnchor, bottom: mapMenu.bottomAnchor, right: mapMenu.rightAnchor)
        mapMenu.anchor(top: mapView.topAnchor, left: mapView.leftAnchor, bottom: nil, right: nil, paddingTop: 3, paddingLeft: 3, paddingBottom: 0, paddingRight: 0, width: 40, height: 100)
        
        
    }
    
    
    fileprivate func setUserName(userName: String, caption: String) -> NSMutableAttributedString
    {
        var attributedText: NSMutableAttributedString?
        let systemDynamicFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyle.body)
        let size = systemDynamicFontDescriptor.pointSize
        let font = UIFont(name: "ArialHebrew", size: size)
        
        attributedText = NSMutableAttributedString(string: "" , attributes: [NSAttributedStringKey.font: font as Any])
        attributedText?.append(NSMutableAttributedString(string: userName , attributes: [NSAttributedStringKey.font: font as Any]))
        attributedText?.append(NSMutableAttributedString(string: " : " , attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 12)]))
        attributedText?.append(NSMutableAttributedString(string: caption , attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 12)]))
        
        return attributedText!
    }
    
    let  editShowSettings = UserPostSettingsController()
    
    func handleEditMenu()
    {
        editShowSettings.showSettings()
        print ("Handle Edit Menu")
        
    }

    
    func showControllerForSetting(_ setting: Setting) {
        let dummySettingsViewController = UIViewController()
        dummySettingsViewController.view.backgroundColor = UIColor.white
        dummySettingsViewController.navigationItem.title = setting.name.rawValue
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }


    
    let mapView : GMSMapView = {
        let camera = GMSCameraPosition.camera(withLatitude: 35.652832 , longitude: 139.839478 , zoom: 14.0)
        let mv = GMSMapView.map(withFrame: CGRect(x: 20, y: 80, width: 330, height: 560), camera: camera)
        var placesClient: GMSPlacesClient!
        mv.isMyLocationEnabled = true
        mv.settings.myLocationButton = true
        mv.settings.compassButton = true
        mv.settings.scrollGestures = true
        mv.settings.zoomGestures   = true
        mv.settings.tiltGestures   = true
        mv.settings.rotateGestures = true
        mv.mapType = .normal
        return mv
    }()
    
    
    let topDividerView: UIView = {
        let iv = UIView()
        iv.backgroundColor = UIColor.lightGray
        return iv
    }()
    
    
    lazy var bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_bookmark").withRenderingMode(.alwaysOriginal), for: .normal)
        //button.addTarget(self, action: #selector(handleBookmark), for: .touchUpInside)
        return button
    }()
    
    
    let bottomDividerView :UIView = {
        let iv = UIView()
        iv.backgroundColor = UIColor.darkGray
        return iv
    }()
    
    let mapviewDividerView :UIView = {
        let iv = UIView()
        iv.backgroundColor = UIColor.darkGray
        return iv
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_favorite").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    let productLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    
    
    @objc func handleLike() {
        print("Handling like from within cell...")
        //delegate?.didLike(for: self)
    }
    
    lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_comment").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()
    
    let userProfileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        return iv
    }()
    
    @objc func handleComment() {
        print("Trying to show comments...")
        //guard let post = post else { return }
        //delegate?.didTapComment(post: post)
    }

    
    
    let imageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .red
        iv.clipsToBounds = true
        return iv
    }()
    
    let labelComment: UILabel = {
        let lb = UILabel()
        //lb.labelComment = "Comment:"
        return lb
    }()
    
    
    let mapsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "search_selected"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        //button.addTarget(self, action: #selector(handleOpenMaps), for: .touchUpInside)
        return button
    }()
    
    
    
    let y = CGFloat(100)

    
    let Description: UILabel = {
        let TextField = UILabel()
        TextField.numberOfLines = 0
        TextField.font = UIFont.systemFont(ofSize: 10)
        TextField.layer.cornerRadius = 10
        TextField.translatesAutoresizingMaskIntoConstraints = true
        TextField.textColor = UIColor.darkGray
         return TextField
    }()
    

    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

extension EditPostController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController.isActive = false
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
                                              zoom: 14)
        
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


