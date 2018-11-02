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
//        import INSPhotoGallery
        import MaterialComponents
        
        
        //        class POIItem: NSObject, GMUClusterItem {
        //            var position: CLLocationCoordinate2D
        //            @objc var marker: GMSMarker!
        //
        //
        //            init(position: CLLocationCoordinate2D, marker: GMSMarker) {
        //                self.position = position
        //                self.marker = marker
        //            }
        //        }
        
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
        
        
        class CustomMarkers: GMUDefaultClusterRenderer {
            var mapView:GMSMapView?
            let kGMUAnimationDuration: Double = 0.5
            
            override init(mapView: GMSMapView, clusterIconGenerator iconGenerator: GMUClusterIconGenerator) {
                
                super.init(mapView: mapView, clusterIconGenerator: iconGenerator)
            }
            
            func markerWithPosition(position: CLLocationCoordinate2D, from: CLLocationCoordinate2D, userData: AnyObject, clusterIcon: UIImage, animated: Bool) -> GMSMarker {
                let initialPosition = animated ? from : position
                let marker = GMSMarker(position: initialPosition)
                marker.userData! = userData
                if clusterIcon.cgImage != nil {
                    marker.icon = clusterIcon
                }
                else {
                    marker.icon = self.getCustomTitleItem(userData: userData)
                    
                }
                marker.map = mapView
                if animated
                {
                    CATransaction.begin()
                    CAAnimation.init().duration = kGMUAnimationDuration
                    marker.layer.latitude = position.latitude
                    marker.layer.longitude = position.longitude
                    CATransaction.commit()
                }
                return marker
            }
            
            func getCustomTitleItem(userData: AnyObject) -> UIImage {
                let item = userData as! POIItem
                return item.marker.icon!
            }
        }
        
        
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
        
        class PostViewerController:
            UIViewController,
            CLLocationManagerDelegate,
            UICollectionViewDataSource,
            UICollectionViewDelegate,
            UICollectionViewDelegateFlowLayout,
            GMSMapViewDelegate,
            GMUClusterManagerDelegate
            
        {
            var postCellId = "postCellId"
            var searchController = UISearchController()
            var resultsViewController: GMSAutocompleteResultsViewController?
            var placesClient: GMSPlacesClient!
            var numberOfLikes : Int?
            private var clusterManager: GMUClusterManager!
            private var infoWindow = InfoWindow()
            
            let locationManager = CLLocationManager()
            
            private func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) {
                let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
                                                         zoom: mapView.camera.zoom + 1)
                let update = GMSCameraUpdate.setCamera(newCamera)
                mapView.moveCamera(update)
            }
            
            var post: FSPost? {
                didSet {
                    title =  "Find it ..."
                    locations.removeAll()
                    setupAttributedCaption()
                    let iconGenerator = GMUDefaultClusterIconGenerator()
                    let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
                    let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
                    clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
                    
                    // Call cluster() after items have been added to perform the clustering and rendering on map.
                    clusterManager.cluster()
                    
                    // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
                    clusterManager.setDelegate(self, mapDelegate: self)
                    if let postId = post?.id  {
                        print("Post ID:" + postId)
                        Firestore.fetchLocationByPostId(postId: postId) { (locationObjects) in
                            for location in locationObjects {
                                let lat = location.latitude
                                let lng = location.longitude
                                let latitude = CLLocationDegrees(lat!)
                                let longitude = CLLocationDegrees(lng!)
                                let position = CLLocationCoordinate2DMake(latitude, longitude)
                                let marker = GMSMarker(position: position)
                                self.locations.append(location)
                                if let product = location.types {
                                    //if let desc = location.address {
                                        
                                        let item = POIItem(position: CLLocationCoordinate2DMake(lat!, lng!), name: product, marker: marker)
                                        self.clusterManager.add(item)
                                        //self.markerByLocation(location, desc, product)
                                    //}
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
                    clusterManager.setDelegate(self, mapDelegate: self)
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
                //let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: cell)
                //present(galleryPreview, animated: true, completion: nil)
                
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
                    let camera = GMSCameraPosition.camera(withLatitude: location.latitude!, longitude: location.longitude!, zoom: 10)
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
            
            fileprivate var locationMarker : GMSMarker? = GMSMarker()
            
            // MARK: Needed to create the custom info window (this is optional)
            func loadNiB() -> InfoWindow{
                let infoWindow = InfoWindow.instanceFromNib() as! InfoWindow
                return infoWindow
            }
            
            // MARK: Needed to create the custom info window (this is optional)
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
                //        locationMarker = marker
                //        infoWindow.removeFromSuperview()
                //        infoWindow = loadNiB()
                //        guard let location = locationMarker?.position else {
                //            print("locationMarker is nil")
                //            return false
                //        }
                //        infoWindow.center = mapView.projection.point(for: location)
                //        infoWindow.center.y = infoWindow.center.y - sizeForOffset(view: infoWindow)
                //        mapView.addSubview(infoWindow)
                return false
            }
            
            // MARK: Needed to create the custom info window
            func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
                if (locationMarker != nil){
                    guard let location = locationMarker?.position else {
                        print("locationMarker is nil")
                        return
                    }
                    // shareShowSettings.showSettings()
                    
                    print ("did change position")
                    
                    //infoWindow.center = mapView.projection.point(for: location)
                    //infoWindow.center.y = infoWindow.center.y - sizeForOffset(view: infoWindow)
                }
            }
            
            // MARK: Needed to create the custom info window
            func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
                handleEditMenu()
                return UIView()
            }
            
            
            // MARK: Needed to create the custom info window
            func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
                infoWindow.removeFromSuperview()
            }
            
            
            private func generateClusterItems() {
                for location in locations {
                    let doubleLat = Double(location.latitude!)
                    let doubleLong = Double(location.longitude!)
                    let latitude = CLLocationDegrees(doubleLat)
                    let longitude = CLLocationDegrees(doubleLong)
                    let position = CLLocationCoordinate2DMake(latitude, longitude)
                    let marker = GMSMarker(position: position)
                    let item = POIItem(position: CLLocationCoordinate2DMake(location.latitude!, location.longitude!), name: (location.place?.name)!, marker: marker)
                    clusterManager.add(item)
                }
            }
            
            
            let  shareShowSettings = ShareShowSettings()
            
            @objc func handleEditMenu()
            {
                shareShowSettings.showSettings()
                print ("Handle Edit Menu")
                
            }
            
            func didTapImageCell(for cell: UserImageCell, post: Post) {
                
                var photos: [PhotoViewModel] = []
                
                for url in post.imageUrlArray {
                    let pt = PhotoViewModel(imageURL: URL(string: url),thumbnailImageURL: URL(string: url))
                    pt.caption = post.caption
                    photos.append(pt)
                }
                
                let currentPhoto = photos[0]
                //let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: cell)
                //present(galleryPreview, animated: true, completion: nil)
                
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
                button.setImage(#imageLiteral(resourceName: "ic_navigation"), for: .normal)
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
                // Location should be okay once the cooridinates
                if locations.count > 0 {
                    let testURL = URL(string: "comgooglemaps-x-callback://")!
                    if UIApplication.shared.canOpenURL(testURL) {
                        let directionsRequest = "comgooglemaps-x-callback://" +
                            "?daddr=John+F.+Kennedy+International+Airport,+Van+Wyck+Expressway,+Jamaica,+New+York" +
                        "&x-success=sourceapp://?resume=true&x-source=AirApp"
                        
                        let directionsURL = URL(string: directionsRequest)!
                        UIApplication.shared.open(directionsURL)
                    } else {
                        
                        // this has to be the coordinates for the current location vs. the last touched location.
                        
                        let customURL = "https://maps.google.com/maps"
                        let location = locations[0]
                        
                        if UIApplication.shared.canOpenURL(NSURL(string: customURL)! as URL) {
                            UIApplication.shared.open(
                                URL(string:"https://maps.google.com/maps/?center=\(String(describing: location.latitude)),\(String(describing: location.longitude))&zoom=12&views=traffic&q=\(String(describing: location.latitude)),\(String(describing: location.longitude))")!, options: [:], completionHandler: nil)
                            
                            let urlTEST = "https://maps.google.com/maps/?daddr=Roppongi%20Hills%20Mori%20Tower%20Tokyo%20Japan&dirflg=r"
                            UIApplication.shared.open(URL(string: urlTEST)!) //, options: [:], completionHandler: nil)
                        }
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
                
                let containerView = MDCCard()
                containerView.setShadowElevation(ShadowElevation.menu, for: UIControlState.normal)
                containerView.addSubview(imageCollectionView)
                let mapMenu = setMapMenu()
                
                //let stackVerticalMapButtons = UIStackView(arrangedSubviews: [mapGoHome,mapSetType])
                //stackVerticalMapButtons.axis = .vertical
                //stackVerticalMapButtons.distribution = .fillEqually
                //mapMenu.addSubview(stackVerticalMapButtons)
                
                containerView.backgroundColor = UIColor.collectionCell()
                view.addSubview(containerView)
                containerView.addSubview(prodIcon)
                containerView.addSubview(productLabel)
                containerView.addSubview(mapView)
                //containerView.addSubview(mapMenu)
                
                if #available(iOS 11.0, *) {
                    containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                         left: view.leftAnchor,
                                         bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                         right: view.rightAnchor,
                                         paddingTop: 7,
                                         paddingLeft: 7,
                                         paddingBottom: 7,
                                         paddingRight: 7,
                                         width: 0,
                                         height: 0)
                    
                } else {
                    // Fallback on earlier versions
                    containerView.anchor(top: view.topAnchor,
                                         left: view.leftAnchor,
                                         bottom: view.bottomAnchor,
                                         right: view.rightAnchor,
                                         paddingTop: 7,
                                         paddingLeft: 7,
                                         paddingBottom: 7,
                                         paddingRight: 7,
                                         width: 0,
                                         height: 0)
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
                
                
                mapView.anchor(top: productLabel.bottomAnchor,
                               left: containerView.leftAnchor,
                               bottom: containerView.bottomAnchor,
                               right: containerView.rightAnchor,
                               paddingTop: 5 ,
                               paddingLeft: 5,
                               paddingBottom: 5,
                               paddingRight: 5,
                               width: 0, height: 0)
                
                //stackVerticalMapButtons.anchor(top: mapView.topAnchor, left: mapMenu.leftAnchor, bottom: mapMenu.bottomAnchor, right: mapMenu.rightAnchor)
                //mapMenu.anchor(top: mapView.topAnchor, left: mapView.leftAnchor, bottom: nil, right: nil, paddingTop: 3, paddingLeft: 3, paddingBottom: 0, paddingRight: 0, width: 40, height: 100)
                
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
        
        extension PostViewerController: GMSAutocompleteResultsViewControllerDelegate {
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
        
        
