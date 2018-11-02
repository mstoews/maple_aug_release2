//
//  ProductPageController.swift
//  maple
//
//  Created by Murray Toews on 2018/04/22.
//  Copyright © 2018 Murray Toews. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import Kingfisher
//import INSPhotoGallery
import MaterialComponents

enum ProductView {
    case DSC
    case IMG
    case PRD
}


class ProductImageCell: BaseCell
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


class PostDescriptionCell: BaseCell
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



class ProductPageController:  UIViewController, CLLocationManagerDelegate,  UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GMSMapViewDelegate {
    
    var productPageCellId = "productPageCellId"
    var postDescriptionCellId = "postDescriptionCellId"
    var searchController = UISearchController()
    var resultsViewController: GMSAutocompleteResultsViewController?
    var placesClient: GMSPlacesClient!
    var numberOfLikes : Int?
    var locations = [LocationObject]()
    
    let locationManager = CLLocationManager()
    
    var post: FSPost? {
        didSet {
            title =  "Post"
            setupAttributedCaption()
            
            Database.fetchLocationByPostId((post?.id!)!){ (locationObjects) in
                for location in locationObjects {
                    self.locations.append(location)
                    self.locateWithLongitude(location, (self.post?.description)!, (self.post?.product)!)
                }
            }
            
            productLabel.text = post?.product
            //guard let profileImageUrl = post?.user.profileImageUrl else { return }
            //userProfileImageView.loadImage(urlString: profileImageUrl)
            imageCollectionView.reloadData()
        }
        
    }

    
    let imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.collectionCell()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    let descriptionListController:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.collectionCell()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    
    let similiarProductsListController:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.collectionCell()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    

    func didTapImage(for cell: ProductImageCell, post: FSPost) {
        
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
        attributedText.append(NSAttributedString(string: "\(post.description)", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)]))
        attributedText.append(NSAttributedString(string: "\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 6)]))
        
        let timeAgoDisplay = post.creationDate.timeAgoDisplay()
        attributedText.append(NSAttributedString(string: timeAgoDisplay, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 8), NSAttributedStringKey.foregroundColor: UIColor.gray]))
        Description.attributedText = attributedText
    }
    
    
    
    func locateWithLongitude(_ location: LocationObject, _ category: String, _ situation: String ) {
        
        DispatchQueue.main.async { () -> Void in
            
            let position = CLLocationCoordinate2DMake(location.latitude!, location.longitude!)
            let marker = GMSMarker(position: position)
            let camera = GMSCameraPosition.camera(withLatitude: location.latitude!, longitude: location.longitude!, zoom: 14)
            self.mapView.camera = camera
            marker.title = "\(location.location!)"
            marker.snippet = "\(category) : \(situation)"
            //marker.icon = UIImage(imageLiteralResourceName: "icons8-marker-50")
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productPageCellId, for: indexPath) as! ProductImageCell
        cell.url = post?.imageUrlArray[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width / 4 - 10
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 0, 0, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productPageCellId, for: indexPath) as! ProductImageCell
        didTapImage(for: cell, post: post!)
    }
    
    // NSLocationAlwaysAndWhenInUseUsageDescription
    // NSLocationWhenInUseUsageDescription
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Products Page"
        view.backgroundColor = UIColor.veryLightGray()
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        imageCollectionView.register(ProductImageCell.self, forCellWithReuseIdentifier: productPageCellId)
        descriptionListController.register(PostDescriptionCell.self, forCellWithReuseIdentifier: postDescriptionCellId )
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        //locationManager.delegate =  self
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
        //let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: cell)
        //present(galleryPreview, animated: true, completion: nil)
        
    }
    
    lazy var filterPhotos: UIButton = {
        let button = UIButton(type: .system)
        //button.setImage(#imageLiteral(resourceName: "icons8-filter"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "icons8-erase"), for: .normal)
        button.tintColor = .black
        button.sizeToFit()
        button.addTarget(self, action: #selector(handleFilter), for: .touchUpInside)
        return button
    }()
    
    lazy var addPhotos: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "picture"), for: .normal)
        button.sizeToFit()
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleAddPhotos), for: .touchUpInside)
        return button
    }()
    
    
    lazy var mapNavigation: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_navigation"), for: .normal)
        button.tintColor = .black
        button.sizeToFit()
        button.addTarget(self, action: #selector(handleNavigation), for: .touchUpInside)
        return button
    }()
    
    lazy var mapSetType: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "icons8-Tracking-50"), for: .normal)
        button.sizeToFit()
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleAddPhotos), for: .touchUpInside)
        return button
    }()
    
    
    
    lazy var prodIcon : UIButton = {
        let ib = UIButton()
        ib.contentMode = .scaleAspectFill
        ib.setImage(#imageLiteral(resourceName: "icons8-Buying-50"), for: .normal)
        ib.clipsToBounds = true
        return ib
    }()
    
    
    lazy var mapTypeSatelite : UIButton = {
        let ib = UIButton()
        ib.contentMode = .scaleAspectFill
        ib.setImage(#imageLiteral(resourceName: "ic_trending_up"), for: .normal)
        ib.clipsToBounds = true
        ib.addTarget(self, action: #selector(handleNavigation), for: .touchUpInside)
        return ib
    }()
    
    lazy var mapTypeHybrid : UIButton = {
        let ib = UIButton()
        ib.contentMode = .scaleAspectFill
        ib.setImage(#imageLiteral(resourceName: "ic_pin_drop"), for: .normal)
        ib.clipsToBounds = true
        ib.addTarget(self, action: #selector(handleNavigation), for: .touchUpInside)
        return ib
    }()
    
    lazy var mapTypeNormal  : UIButton = {
        let ib = UIButton()
        ib.contentMode = .scaleAspectFill
        ib.setImage(#imageLiteral(resourceName: "icons8-directions-filled-24"), for: .normal)
        ib.clipsToBounds = true
        ib.addTarget(self, action: #selector(handleNavigation), for: .touchUpInside)
        return ib
    }()
    
    
    @objc func handleNavigation()
    {
        let testURL = URL(string: "comgooglemaps-x-callback://")!
         if UIApplication.shared.canOpenURL(testURL) {
            
            if locations.count > 0 {
                let customURL = "comgooglemaps://"
                let location = locations[0]
                
                if UIApplication.shared.canOpenURL(NSURL(string: customURL)! as URL) {
                    UIApplication.shared.open(URL(string:"comgooglemaps://?center=\(String(describing: location.latitude)),\(String(describing: location.longitude))&zoom=14&views=traffic&q=\(String(describing: location.latitude)),\(String(describing: location.longitude))")!, options: [:], completionHandler: nil)
                }
                else {
                    UIApplication.shared.open(URL(string:
                        "https://maps.google.com/?q=@\(Float(location.latitude!)),\(Float(location.longitude!))")! as URL)
                    
//                    let alert = UIAlertController(title: "GoogleMaps Navigation", message: "This feature requires GoogleMaps to be installed", preferredStyle: UIAlertControllerStyle.alert)
//                    let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
//                    alert.addAction(ok)
//                    self.present(alert, animated:true, completion: nil)
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
        editMenu.layer.cornerRadius = 10
        editMenu.backgroundColor = UIColor.veryLightGray()
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
        
        let stackVerticalMapButtons = UIStackView(arrangedSubviews: [mapNavigation,mapSetType,mapTypeSatelite, mapTypeHybrid, mapTypeNormal])
        stackVerticalMapButtons.axis = .vertical
        stackVerticalMapButtons.distribution = .fillEqually
        mapMenu.addSubview(stackVerticalMapButtons)
        
        
        containerView.backgroundColor = UIColor.collectionCell()
        view.addSubview(containerView)
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, bookmarkButton])
        stackView.distribution = .fillEqually
        //containerView.addSubview(userProfileImageView)
        containerView.addSubview(prodIcon)
        containerView.addSubview(productLabel)
        containerView.addSubview(imageCollectionView)
        containerView.addSubview(descriptionListController)
        containerView.addSubview(topDividerView)
        containerView.addSubview(bottomDividerView)
        //containerView.addSubview(stackView)
        containerView.addSubview(Description)
        //containerView.addSubview(mapviewDividerView)
        containerView.addSubview(mapView)
        containerView.addSubview(editMenu)
        containerView.addSubview(mapMenu)
        containerView.addSubview(similiarProductsListController)
        
        let heightOfViewController = view.frame.width / 4 - 10
        
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
        
        
        
        
        descriptionListController.anchor(top: topDividerView.bottomAnchor,
                                         left: containerView.leftAnchor,
                                         bottom:  nil,
                                         right: containerView.rightAnchor,
                                         paddingTop: 5 ,
                                         paddingLeft: 5,
                                         paddingBottom: 5,
                                         paddingRight: 5,
                                         width: 0, height: heightOfViewController)
        
        
        mapView.anchor(top: descriptionListController.bottomAnchor,
                       left: containerView.leftAnchor,
                       //bottom: containerView.bottomAnchor,
                       bottom: nil,
                       right: containerView.rightAnchor,
                       paddingTop: 5 ,
                       paddingLeft: 5,
                       paddingBottom: 5,
                       paddingRight: 5,
                       width: 0, height: 300)
        
        
        //stackButtonsVerical.anchor(top: editMenu.topAnchor, left: editMenu.leftAnchor, bottom: editMenu.bottomAnchor, right: editMenu.rightAnchor)
        //editMenu.anchor(top: imageCollectionView.topAnchor, left: nil, bottom: nil, right: imageCollectionView.rightAnchor, paddingTop: 10, paddingLeft: 5, paddingBottom: 0, paddingRight: 15, width: 60, height: 120)
        
        stackVerticalMapButtons.anchor(top: mapView.topAnchor, left: mapMenu.leftAnchor, bottom: mapMenu.bottomAnchor, right: mapMenu.rightAnchor)
        mapMenu.anchor(top: mapView.topAnchor, left: mapView.leftAnchor, bottom: nil, right: nil, paddingTop: 2, paddingLeft: 2, paddingBottom: 0, paddingRight: 0, width: 40, height: 200)
        
        
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
    
    
//    func showControllerForSetting(_ setting: Setting) {
//        let dummySettingsViewController = UIViewController()
//        dummySettingsViewController.view.backgroundColor = UIColor.white
//        //dummySettingsViewController.navigationItem.title = setting.name.rawValue
//        //navigationController?.navigationBar.tintColor = UIColor.white
//        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
//        navigationController?.pushViewController(dummySettingsViewController, animated: true)
//    }
//    
    
    
    let mapView : GMSMapView = {
        let camera = GMSCameraPosition.camera(withLatitude: 35.652832 , longitude: 139.839478 , zoom: 10.0)
        let mv = GMSMapView.map(withFrame: CGRect(x: 20, y: 80, width: 330, height: 560), camera: camera)
        var placesClient: GMSPlacesClient!
        mv.isMyLocationEnabled = true
        mv.settings.myLocationButton = true
        mv.settings.compassButton = true
        mv.settings.indoorPicker = true
        mv.settings.scrollGestures = true
        mv.settings.zoomGestures   = true
        mv.settings.tiltGestures   = true
        mv.settings.rotateGestures = true
        mv.mapType = .satellite
        return mv
    }()
    
    
    let topDividerView: UIView = {
        let iv = UIView()
        iv.backgroundColor = UIColor.lightGray
        return iv
    }()
    
    
    lazy var bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "bookmark").withRenderingMode(.alwaysOriginal), for: .normal)
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
        button.setImage(#imageLiteral(resourceName: "like_selected-1").withRenderingMode(.alwaysOriginal), for: .normal)
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
        button.setImage(#imageLiteral(resourceName: "comment1").withRenderingMode(.alwaysOriginal), for: .normal)
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



