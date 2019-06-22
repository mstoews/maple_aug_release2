//
//  SharePhotoController.swift
//  maple products database
//
//  Created by Murray Toews on Aug 07, 2018.
//  Copyright © 2018 maple.com


import UIKit
import Firebase
import Photos
import AssetsLibrary
import FirebaseUI
import AFNetworking
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
import os.log
import AlgoliaSearch
import InstantSearchCore
import MaterialComponents
import Gallery
import Lightbox
import AVFoundation
import AVKit
import SVProgressHUD
import CropViewController
import ActiveLabel

enum  CT {
    case PIC
    case MAP
}

protocol  SharePhotoDelegates {
    func setTabBarHome()
}


class SharePhotoControllers:
    UIViewController,
    UIScrollViewDelegate,
    UICollectionViewDelegateFlowLayout,
    UICollectionViewDataSource,
    UISearchDisplayDelegate,
    UITextViewDelegate,
    UITextFieldDelegate,
    // UITableViewDataSource,
    UIImageEditFilterDelegate,
    // UITableViewDelegate,
    UISearchBarDelegate,
    UISearchResultsUpdating,
    SearchProgressDelegate,
    LightboxControllerDismissalDelegate,
    GalleryControllerDelegate,
    CropViewControllerDelegate,
    ShareHeaderCellDelegate
{
    
    // MARK: - Variables and containts
    
    private var croppedRect = CGRect.zero
    private var croppedAngle = 0
    var VIEW_SCROLL_HEIGHT: CGFloat?
    var uploadTask: StorageUploadTask?
    
    var shareDelegate :SharePhotoDelegate?
    var searchController: UISearchController!
    var searchProgressController: SearchProgressController!
    
    var keyboardNotification: NSNotification?
    
    var scrollView: UIScrollView!
    
    var postSearcher: Searcher!
    var postHits: [JSONObject] = []
    var originIsLocal: Bool = true
    var user: MapleUser!
    
    var mapObjects = [locObject]()
    var imageArray = [UIImage]()
    var imageUrlArray = [String]()
    let imageCellId = "imageCellId"
    let mapCellId = "mapCellId"
    var isMapCell = false
    var mapViewController: BackgroundMapViewController?
    var UIMapController: UIViewController?
    var presentWindow : UIWindow?
    
    let attributeTitle = [NSAttributedString.Key.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .title)]
    let attributeCaption = [NSAttributedString.Key.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .body2 )]
    let attributeSubline = [NSAttributedString.Key.font: UIFont.mdc_preferredFont(forMaterialTextStyle:  .subheadline )]
    
    var gallery: GalleryController!
    let editor: VideoEditing = VideoEditor()
    
    var urlThumbArray = [String]()
    var urlOriginalArray = [String]()
    
    var bottomConstraint: NSLayoutConstraint!
    var heightConstraint: NSLayoutConstraint!
    var inputBottomConstraint: NSLayoutConstraint!
    var sendBottomConstraint: NSLayoutConstraint!
    var insets: UIEdgeInsets!
    
    var bottomAreaInset: CGFloat = 0
    var isEditingComment = false
    var CellType = CT.PIC
    
    var referenceURL: URL!
    
    var urlArray = [String]()
    
    var docRef : DocumentReference!
    let db = Firestore.firestore()
    
    
    public var imageConstraint: NSLayoutConstraint?
    public var imageWidthConstraint: NSLayoutConstraint?
    
    
    lazy var touchView: UIView = {
        
        let _touchView = UIView()
        
        _touchView.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha: 0.0)
        
        let touchViewTapped = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        _touchView.addGestureRecognizer(touchViewTapped)
        
        _touchView.isUserInteractionEnabled = true
        
        _touchView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        
        return _touchView
        
    }()
    
    
    func registerForKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
        
    }
    
    func deregisterFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func dismissKeyboard() {
        
        view.endEditing(true)
        
    }
    
    
    
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.croppedRect = cropRect
        self.croppedAngle = angle
        if imageArray.count > 0 {
            imageArray[self.currentImageItem!] = image
        }
        self.imageCollectionView.reloadData()
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.croppedRect = cropRect
        self.croppedAngle = angle
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        
    }
    
    func lightboxController(_ controller: LightboxController, didTouch image: LightboxImage, at index: Int) {
        
    }
    
    public func layoutImageView() {
        guard imageView.image != nil else { return }
        
        let padding: CGFloat = 20.0
        
        var viewFrame = self.view.bounds
        viewFrame.size.width -= (padding * 2.0)
        viewFrame.size.height -= ((padding * 2.0))
        
        var imageFrame = CGRect.zero
        imageFrame.size = imageView.image!.size;
        
        if imageView.image!.size.width > viewFrame.size.width || imageView.image!.size.height > viewFrame.size.height {
            let scale = min(viewFrame.size.width / imageFrame.size.width, viewFrame.size.height / imageFrame.size.height)
            imageFrame.size.width *= scale
            imageFrame.size.height *= scale
            imageFrame.origin.x = (self.view.bounds.size.width - imageFrame.size.width) * 0.5
            imageFrame.origin.y = (self.view.bounds.size.height - imageFrame.size.height) * 0.5
            imageView.frame = imageFrame
        }
        else {
            self.imageView.frame = imageFrame;
            self.imageView.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        }
    }
    
    
    public func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
        imageView.image = image
        layoutImageView()
        
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        
        if cropViewController.croppingStyle != .circular {
            imageView.isHidden = true
            
            cropViewController.dismissAnimatedFrom(self, withCroppedImage: image,
                                                   toView: imageView,
                                                   toFrame: CGRect.zero,
                                                   setup: { self.layoutImageView() },
                                                   completion: { self.imageView.isHidden = false })
        }
        else {
            self.imageView.isHidden = false
            cropViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        
        //let width = asset.pixelWidth
        //let height = asset.pixelHeight
        //let size = CGSize(width: width, height: height)
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        LightboxConfig.DeleteButton.enabled = true
        SVProgressHUD.show()
        Image.resolve(images: images, completion: { [weak self] resolvedImages in
            SVProgressHUD.dismiss()
            self?.showLightbox(images: resolvedImages.compactMap({ $0 }))
        })
    }
    
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        for img in images  {
            let uiimage = getAssetThumbnail(asset: img.asset)
            imageArray.append (uiimage)
        }
        
        if imageArray.count > 0 {
            imageCollectionView.reloadData()
        }
        gallery.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
        
        
        editor.edit(video: video) { (editedVideo: Video?, tempPath: URL?) in
            DispatchQueue.main.async {
                if let tempPath = tempPath {
                    let controller = AVPlayerViewController()
                    controller.player = AVPlayer(url: tempPath)
                    
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - ShowLightBox
    func showLightbox(images: [UIImage]) {
        guard images.count > 0 else {
            return
        }
        
        let lightboxImages = images.map({ LightboxImage(image: $0) })
        let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
        lightbox.dismissalDelegate = self
        gallery.present(lightbox, animated: true, completion: nil)
    }
    
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
    }
    
    
    
    func updateConstraints() {
        let constant = MDCCeil((self.view.frame.width - 2) * 0.65)
        let widthConstant = MDCCeil((self.view.frame.width - 2) * 0.9)
        if imageConstraint == nil {
            imageConstraint = imageCollectionView.heightAnchor.constraint(equalToConstant: constant)
            imageConstraint?.isActive = true
        }
        if imageWidthConstraint == nil {
            imageWidthConstraint = imageCollectionView.widthAnchor.constraint(equalToConstant: widthConstant)
            imageWidthConstraint?.isActive = true
        }
        imageConstraint?.constant = constant
        imageWidthConstraint?.constant = widthConstant
    }
    
    
    //var post : Post?
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")
    var pictureSize = CGFloat(350.00)
    
    // var tableView : UITableView
    
    let searchTableCellId = "searchTableCellId"
    
    func updateSearchResults(for searchController: UISearchController) {
        postSearcher.params.query = searchController.searchBar.text
        postSearcher.search()
    }
    
    func updateSearchResults(for productTextField: UITextField) {
        postSearcher.params.query = productTextField.text
        postSearcher.search()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    }
    
    func searchDidStart(_ searchProgressController: SearchProgressController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func searchDidStop(_ searchProgressController: SearchProgressController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    
    var refresher:UIRefreshControl!
    
    let backGroundView : UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named:"place_holder")
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let backGroundViewMaps : UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named:"placeholder_map_navigation")
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView = UIScrollView()
        
        Gallery.Config.VideoEditor.savesEditedVideoToLibrary = true
        Gallery.Config.initialTab = Gallery.Config.GalleryTab.imageTab
        Gallery.Config.tabsToShow = [Gallery.Config.GalleryTab.imageTab, Gallery.Config.GalleryTab.cameraTab]
        
        updateConstraints()
        
        registerForKeyboardNotifications()
        
        /***** Set up toasts *****/
        edgesForExtendedLayout = UIRectEdge()
        presentWindow = UIApplication.shared.keyWindow
        
        imageCollectionView.register(PostImageObject.self, forCellWithReuseIdentifier: imageCellId)
        locationCollectionView.register(MapCell.self, forCellWithReuseIdentifier: mapCellId)
        
        view.backgroundColor = UIColor.collectionCell()
        self.view.tintColor  = UIColor.buttonThemeColor()
        navigationItem.title = "Post Page"
        imageCollectionView.backgroundView = backGroundView
        locationCollectionView.backgroundView = backGroundViewMaps
        
        Products.delegate = self
        Description.delegate = self
        
        imageCard = MDCCard()
        
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        
        locationCollectionView.dataSource = self
        locationCollectionView.delegate = self
       
        
        containerView = MDCCard()
        locationCard = UIView()
        
        let tapLocation = UITapGestureRecognizer(target: self, action: #selector(userTappedLocationCollection(tapGestureRecognizer: )))
        locationCard?.isUserInteractionEnabled = true
        locationCard?.addGestureRecognizer(tapLocation)
        
        
        let tapPhotos = UITapGestureRecognizer(target: self, action: #selector(userTappedPhotoCollection(tapGestureRecognizer: )))
        imageCollectionView.isUserInteractionEnabled = true
        imageCollectionView.addGestureRecognizer(tapPhotos)
        
        
        setupImageAndTextViews()
        setNavigationButtons()
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.fetchUserWithUID(uid: uid, completion: { (user) in
            self.user = user
        })
        
        /****** Tap to dismiss KeyBoard ******/
        
        let tapImageCollectionView = UITapGestureRecognizer(target: self, action: #selector(imageCollectionViewTapped(tapGestureRecognizer: )))
        imageCollectionView.isUserInteractionEnabled = true
        imageCollectionView.addGestureRecognizer(tapImageCollectionView)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dissmissKeyboard)))
        /****** End Gestures           ******/
        
        definesPresentationContext = true
        
        VIEW_SCROLL_HEIGHT? = 400.0
        print("Keyboard adjusted value \(VIEW_SCROLL_HEIGHT ?? 0.0)")
        
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
        //HideImagesAndMaps()
        print("Keyboard is shown ... ")
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            bottomAreaInset = -100
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardSize.height : 0
            let inset = isKeyboardShowing ? -bottomAreaInset : bottomAreaInset
            print("Keyboard is showing : \(inset)")
            heightConstraint?.constant += inset
            inputBottomConstraint?.constant = isKeyboardShowing ? 0 : bottomAreaInset
            sendBottomConstraint?.constant = isKeyboardShowing ? 12 : (12 + bottomAreaInset)
            if let animationDuration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
                UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { completed in
                    if isKeyboardShowing {
                        if self.Description.isHidden == false {
                         self.view.frame.origin.y -= keyboardSize.height + self.bottomAreaInset
                        }
                    } else {
                        MDCSnackbarManager.setBottomOffset(0)
                    }
                })
            }
        }
        
        
    }

    @objc func keyboardWillBeHidden(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            self.view.frame.origin.y += keyboardSize.height + bottomAreaInset
        }
        print("Hide keyboard ...")
        
    }
    
    var editingIndex: IndexPath!
    
    
    func text(for priceLevel: GMSPlacesPriceLevel) -> String {
        switch priceLevel {
        case .free: return NSLocalizedString("Free",comment: "Relative cost for a free location")
        case .cheap: return NSLocalizedString("Cheap",comment: "Relative cost for a cheap location")
        case .medium: return NSLocalizedString("Medium",comment: "Relative cost for a medium cost location")
        case .high: return NSLocalizedString("High",comment: "Relative cost for a high cost location")
        case .expensive: return NSLocalizedString("Expensive",comment: "Relative cost for an expensive location")
        case .unknown: return NSLocalizedString("Unkown",comment: "Relative cost for when it is unknown")
        @unknown default:
            print("Fatal error...")
            fatalError()
        }
    }
    
    
    let loadImages: CustomImageView = {
        let iv = CustomImageView()
        var defaultImage: UIImage = UIImage(named: "maple_start_image")!
        iv.image = defaultImage
        return iv
    }()
    
    
    @objc func imageCollectionViewTapped(tapGestureRecognizer: UITapGestureRecognizer){
        view.endEditing(true)
        handleAddPhotos()
        
    }
    
    @objc func dissmissKeyboard(){
        view.endEditing(true)
    }
    
    
    let tableProductsView : UITableView = {
        let tv = UITableView()
        tv.isHidden = true
        tv.tableFooterView?.isHidden = true
        tv.tableHeaderView?.isHidden = true
        tv.tableHeaderView=nil
        tv.tableFooterView=nil
        return tv
    }()
    
    
    let buttonMenus = UIView()
    
    
   
    
    @objc func userTappedPhotoCollection(tapGestureRecognizer: UITapGestureRecognizer)
    {
        handleAddPhotos()
    }
    
    var containerView : MDCCard?
    
    // MARK: - Arrange Fields
    
    var imageCard: MDCCard?
    var locationCard: UIView?
    
    func setupImageAndTextViews() {
        
        let productsHeight = CGFloat(45.0)
        let paddingSize = CGFloat(7.0)
        let paddingTopBottom = CGFloat(7.0)
        
        
        guard let cView = containerView else { return }
        
        
        locationCard?.addSubview(locationCollectionView)
        
        
        locationCollectionView.anchor(top: locationCard?.topAnchor, left: locationCard?.leftAnchor, bottom: locationCard?.bottomAnchor, right: locationCard?.rightAnchor)
        
        
        imageCard?.setShadowElevation(ShadowElevation.menu, for: UIControl.State.normal)
        imageCard?.addSubview(imageCollectionView)
        imageCollectionView.anchor(top: imageCard?.topAnchor, left: imageCard?.leftAnchor, bottom: imageCard?.bottomAnchor , right: imageCard?.rightAnchor,
                                   paddingTop: paddingTopBottom,
                                   paddingLeft: paddingSize,
                                   paddingBottom: paddingTopBottom,
                                   paddingRight: paddingSize,
                                   width: 0 , height: (imageConstraint?.constant)!)
        
        
        
        
        containerView?.setShadowElevation(ShadowElevation.cardResting, for: UIControl.State.normal)
        
        containerView?.inkView.inkColor = .lightGray
        containerView?.backgroundColor = UIColor.collectionBackGround()
        
        buttonMenus.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        buttonMenus.layer.cornerRadius = 10
        buttonMenus.backgroundColor = UIColor.veryLightGray()
        buttonMenus.layer.borderWidth = 2
        buttonMenus.layer.borderColor = UIColor.black.cgColor
        
        
        view.addSubview(containerView!)
        cView.addSubview(imageCard!)
        cView.addSubview(Products)
        cView.addSubview(Description)
        cView.addSubview(DescriptionLabel)
        cView.addSubview(locationCard!)
        cView.addSubview(RunningCountLabel)
        cView.addSubview(tableProductsView)
        cView.addSubview(buttonMenus)
        cView.addSubview(mapLabel)
        cView.addSubview(Photos)
        cView.addSubview(FloatingPlusButton)
        
        
        if #available(iOS 11.0, *) {
            cView.anchor(top: view.safeAreaLayoutGuide.topAnchor , left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor,
                         paddingTop: paddingSize,
                         paddingLeft: paddingSize,
                         paddingBottom: paddingSize ,
                         paddingRight: paddingSize,
                         width: 0 ,
                         height: 0)
        } else {
            cView.anchor(top: view.topAnchor , left: view.leftAnchor, bottom: view.bottomAnchor , right: view.rightAnchor)
        }
        
        
        self.pictureSize = cView.frame.size.width
        
        //let heightCollectionView = imageConstraint?.constant
        
        imageCard?.anchor(top: cView.topAnchor, left: cView.leftAnchor, bottom: nil , right: cView.rightAnchor,
                          paddingTop: paddingTopBottom,
                          paddingLeft: paddingSize,
                          paddingBottom: paddingTopBottom,
                          paddingRight: paddingSize,
                          width: 0 , height: (imageConstraint?.constant)!)
        
        
        Products.anchor(top:  imageCard?.bottomAnchor,
                        left: cView.leftAnchor,
                        bottom: nil ,
                        right: cView.rightAnchor ,
                        paddingTop: paddingTopBottom,
                        paddingLeft: paddingSize,
                        paddingBottom: paddingTopBottom,
                        paddingRight: paddingSize,
                        width: 0 ,
                        height: productsHeight)
        
        
        locationCard?.anchor(top: Products.bottomAnchor, left: cView.leftAnchor, bottom: nil, right: cView.rightAnchor ,
                             paddingTop: paddingTopBottom,
                             paddingLeft: paddingSize,
                             paddingBottom: paddingTopBottom,
                             paddingRight: paddingSize,
                             width: 0, height: 40)
        
        
        
        Description.anchor(top: locationCard?.bottomAnchor, left: cView.leftAnchor, bottom: nil , right: cView.rightAnchor,
                           paddingTop: paddingTopBottom ,
                           paddingLeft: paddingSize,
                           paddingBottom: paddingTopBottom,
                           paddingRight: paddingSize,
                           width: 0 , height: 2.5 * productsHeight)
        
        RunningCountLabel.anchor(top: nil, left: nil, bottom: Description.bottomAnchor, right: Description.rightAnchor , paddingTop: 4 , paddingLeft: 0, paddingBottom: 1 , paddingRight: 0, width: 50 , height: 30)
        
        
        FloatingPlusButton.anchor(top: Description.bottomAnchor, left: nil, bottom: nil, right: cView.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        
        
    }
    
    
    let FloatingPlusButton : MDCFloatingButton = {
        let fb = MDCFloatingButton()
        fb.backgroundColor = UIColor.buttonThemeColor()
        fb.setImage(#imageLiteral(resourceName: "ic_add_to_photos_white"), for: .normal)
        fb.addTarget(self, action: #selector(handleShare(_:)), for: .touchUpInside)
        return fb
    }()
    
    var textFieldControllerFloating : MDCTextInputController?
    
    let Products:  UITextField = {
        let TextField =  UITextField()
        TextField.placeholder = "Caption"
        TextField.font = UIFont.systemFont(ofSize: 15)
        TextField.translatesAutoresizingMaskIntoConstraints = true
        TextField.textColor = UIColor.black
        TextField.backgroundColor =  UIColor.collectionCell()
        TextField.tag = 1
        return TextField
    }()
    
    
    let Description:  MultilineTextField = {
        handleSharextField =  MultilineTextField ()
        TextField.placeholder = "Description"
        TextField.font = UIFont.systemFont(ofSize: 15)
        TextField.translatesAutoresizingMaskIntoConstraints = true
        TextField.textColor = UIColor.black
        TextField.backgroundColor =  UIColor.collectionCell()
        TextField.tag = 2
        return TextField
    }()
    
    
    let imageCollectionView:  UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 345, height: 230)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.collectionCell()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInsetAdjustmentBehavior = .never
        return collectionView
    }()
    
    
    let LocationLabel : UILabel = {
        let ui = UILabel()
        ui.text = "Location"
        return ui
    }()
    
    
    let locationCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.collectionCell()
        collectionView.backgroundView = UIView()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    
    @objc func handleEditMenu()
    {
        //shareShowSettings.showSettings()
        print ("Handle Edit Menu")
        
    }
    
    
    lazy var mapsButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.collectionBackGround()
        button.setImage(#imageLiteral(resourceName: "ic_place"), for: .normal)
        button.setTitle( "" , for: .normal)
        button.setTitleColor( UIColor.buttonThemeColor() , for: .normal)
        button.tintColor = UIColor.buttonThemeColor()
        button.sizeToFit()
        button.addTarget(self, action: #selector(openMapSelector), for: .touchUpInside)
        CellType = CT.MAP
        return button
    }()
    
    
    lazy var mapLabel : UILabel = {
        let ml = UILabel()
        var attributedText: NSMutableAttributedString?
        attributedText = NSMutableAttributedString(string: "Location" , attributes: attributeCaption)
        ml.attributedText = attributedText
        return ml
    }()
    
    lazy var Photos : UILabel = {
        let pl = UILabel()
        pl.text = "Photos"
        return pl
    }()
    
    
    
    func didReturnMapPlace(place: GMSPlace){
        print (place)
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func setNavigationButtons(){
        
        let rightImage = UIImage(named: "ic_add_to_photos")?.withRenderingMode(.automatic)
        let rightButton = UIBarButtonItem(image: rightImage, style: .done , target: self, action: #selector(handleShareAll))
        rightButton.tintColor = UIColor.buttonThemeColor()
        navigationItem.rightBarButtonItem = rightButton
    }
    
    let noneText = NSLocalizedString("PlaceDetails.MissingValue", comment: "The value of a property which is missing")
    
    @objc func handleClearAllFields()
    {
        let alert = UIAlertController(title: "Clear All Fields", message: "Current fields will be cleared. Continue?", preferredStyle: UIAlertController.Style.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler:
            { action in
                switch action.style{
                case .default:
                    self.imageArray.removeAll()
                    self.mapObjects.removeAll()
                    self.Products.text?.removeAll()
                    self.Description.text?.removeAll()
                    self.imageCollectionView.reloadData()
                    self.locationCollectionView.reloadData()
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                @unknown default:
                    fatalError()
                }}))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
  
    
    var selectedImage: UIImage? {
        didSet {
            self.imageView.image = selectedImage
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var iCount = 0
        switch CellType
        {
        case CT.MAP:
            iCount = mapObjects.count
            break
        case CT.PIC:
            iCount = imageArray.count
            break
        }
        return iCount
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = indexPath.item
        switch CellType
        {
        case CT.MAP:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: mapCellId, for: indexPath) as! MapCell
            if mapObjects.count > 0  {
                cell.mapObject = (mapObjects[indexPath.item]) as locObject
            }
            if item >= 0 {
                cell.btnDeleteMapAction = {() in
                    self.mapObjects.remove(at: indexPath.item)
                    self.refreshMapCollection { error in
                        if let error = error {
                            print("Oops! Something went wrong... : ", error)
                        } else {
                            print("It has finished")
                        }
                    }
                }
            }
            return cell
        //break
        case CT.PIC:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCellId, for: indexPath) as! PostImageObject
            if imageArray.count > 0 {
                cell.imageObject = (imageArray[indexPath.item])
                cell.isSelectable = true
                
                //cell.selectedImageTintColor = .blue
                cell.cornerRadius = 8
                cell.setShadowElevation(ShadowElevation(rawValue: 12), for: .selected)
                cell.setShadowColor(UIColor.black, for: .highlighted)
                
                cell.btnEditAction = {() in
                    let item = indexPath.item
                    if item >= 0  {
                        if let img = self.imageArray[item] as UIImage? {
                            self.currentImageItem = item
                            let cropViewController = CropViewController(image: img)
                            cropViewController.delegate = self
                            self.present(cropViewController, animated: true, completion: nil)
                        }
                    }
                }
                
                
                cell.btnFilterAction = {() in
                    let item = indexPath.item
                    if item >= 0  {
                        if let img = self.imageArray[item] as UIImage? {
                            // let image = img.images![indexPath.item]
                            //                            let vc = SHViewController(image: img)
                            //                            vc.delegate = self as SHViewControllerDelegate
                            //                            self.currentImageItem = item
                            //                            os_log("Filtering an item", log: OSLog.default, type: .debug)
                            //                            self.present(vc, animated: true, completion: nil)
                        }
                    }
                }
                cell.btnDeleteAction = {() in
                    print("Delete Acount", indexPath.item)
                    if (self.imageArray[indexPath.item] as UIImage?) != nil {
                        self.imageArray.remove(at: indexPath.item)
                        self.refreshImageCollection { error in
                            if let error = error {
                                print("Oops! Something went wrong... : ", error)
                            } else {
                                print("It has finished")
                            }
                        }
                    }
                }
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        var rc = CGSize(width: 100 , height: 100 )
        switch CellType
        {
        case CT.MAP:
            rc = CGSize(width: 162, height: 40 )
            break
        case CT.PIC:
            rc = CGSize(width: collectionView.frame.width, height: collectionView.frame.height )
            break
        }
        return rc
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "cellHeaderId", for: indexPath) as! ShareHeaderCell
        header.delegate = self
        return header
    }
    
    @objc func didClearAllFields() {
        handleClearAllFields()
    }
    
    func didHandleDelete() {
        print("SharePhotoController : didhandleDelete")
        
    }
    
    var currentImageItem : Int?
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch CellType
        {
        case CT.PIC:
            if imageArray.count > 0 {
                let item = indexPath.item
                if item >= 0  {
                    if let img = imageArray[item] as UIImage? {
                    }
                }
            }
            break
        case CT.MAP:
            if mapObjects.count > 0 {
                let item = indexPath.item
                if item >= 0 {
                    // let place = mapObjects[item]
                    // we need to extend the class and make sure we go to the location selected
                    let config = GMSPlacePickerConfig(viewport: nil)
                    let placePicker = GMSPlacePickerViewController(config: config)
                    placePicker.delegate = self
                    placePicker.modalPresentationStyle = .popover
                    placePicker.popoverPresentationController?.sourceView = mapsButton
                    placePicker.popoverPresentationController?.sourceRect = mapsButton.bounds
                    self.present(placePicker, animated: true, completion: nil)
                }
            }
            break
        }
    }
    
    func ViewControllerImageDidFilter(image: UIImage) {
        if currentImageItem! >= 0 {
            imageArray[currentImageItem!] = image
            DispatchQueue.main.async {
               self.imageCollectionView.reloadData()
            }
           
        }
    }
    
    func didHandleCamera() {
        handleAddPhotos()
    }
    
    func didHandelLocation() {
        handleOpenMaps()
    }
    
    func didHandleClear() {
        handleClearAllFields()
    }
    
    func didHandleFilter() {
        
    }
    
    func shViewControllerDidCancel() {
        print ("print ...")
    }
    
    
    @objc func handleClearMaps()
    {
        self.mapObjects.removeAll()
    }
    
    @objc func handleOpenMaps()
    {
        CellType = CT.MAP
        print("Open the maps window")
        let mapController = MapLocationController()
        let navController = UINavigationController(rootViewController: mapController)
        present(navController, animated: true, completion: nil)
    }
    
    @objc func handleAddPhotos(){
        CellType = CT.PIC
        gallery = GalleryController()
        gallery.delegate = self
        present(gallery, animated: true, completion: nil)
    }
    
    
    let RunningCountLabel: UILabel = {
        let TextField = UILabel()
        TextField.text = "Max 300"
        TextField.font = UIFont.systemFont(ofSize: 10)
        TextField.layer.cornerRadius = 10
        TextField.translatesAutoresizingMaskIntoConstraints = true
        TextField.textColor = UIColor.lightGray
        TextField.backgroundColor =  UIColor.collectionCell()
        TextField.tag = 2
        return TextField
    }()
    
    let DescriptionLabel: UILabel = {
        let TextField = UILabel()
        TextField.text  = "Description of the product"
        TextField.font = UIFont.systemFont(ofSize: 15)
        TextField.layer.cornerRadius = 10
        TextField.translatesAutoresizingMaskIntoConstraints = true
        TextField.textColor = UIColor.lightGray
        TextField.isEnabled = false
        TextField.backgroundColor =  UIColor.rgb(red: 240, green: 240, blue: 240)
        return TextField
    }()
    
    @objc func textProductFieldChanged(_ textField: UITextField) {
        updateSearchResults(for: textField)
        tableProductsView.isHidden = false
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        Products.resignFirstResponder()
        Description.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        RunningCountLabel.text = String("\(numberOfChars)/300")
        return numberOfChars <= 300;
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        buttonMenus.isHidden = true
        if textView.textColor == UIColor.lightGray {
            //textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        buttonMenus.isHidden = false
        if textView.text.count  == 0 {
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            tableProductsView.isHidden = true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            tableProductsView.isHidden = true
        }
        if textField.tag == 2 {
            textField.placeholder = ""
        }
        
    }
    
    func textSearchPairing(_ textField: UITextView)
    {
        print("Search the text field for pairing")
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .white
        //iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = false
        let imageName = ""
        let image = UIImage(named: imageName)
        iv.image = image
        iv.layer.cornerRadius = 10
        return iv
    }()
    
    
    var PrefersStatusBarHidden: Bool {
        return true
    }
    
    func handleShare(){
        
    }
    
    func refreshMapCollection(completion: @escaping (Error?) -> Void){
        CellType = CT.MAP
        locationCollectionView.reloadData()
        completion(nil)
    }
    
    func refreshImageCollection(completion: @escaping (Error?) -> Void) {
        CellType = CT.PIC
        imageCollectionView.reloadData()
        completion(nil)
    }
    
}

