//
//  SharePhotoController.swift
//  maple products database
//
//  Created by Murray Toews on 6/3/17.
//  Copyright © 2017 maple.com

import UIKit
import Photos
import AssetsLibrary
import FirebaseUI
import AlgoliaSearch
import InstantSearchCore
import AFNetworking
import Firebase
import FirebaseFirestore
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
import DKImagePickerController
import Sharaku
import os.log
import AlgoliaSearch
import InstantSearchCore
import MaterialComponents
import ImagePicker
import Gallery
import Lightbox
import AVFoundation
import AVKit
import SVProgressHUD
import CropViewController

enum  CT {
    case PIC
    case MAP
}

protocol  SharePhotoDelegate {
    func setTabBarHome()
}


//class ShadowViewCollection : UICollectionView {
//    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout)
//     {
//        super.init(frame: frame, collectionViewLayout: layout)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override class var layerClass: AnyClass {
//        return MDCShadowLayer.self
//    }
//
//    func setDefaultElevation() {
//        self.shadowLayer.elevation = .cardResting
//    }
//    var shadowLayer: MDCShadowLayer {
//        return self.layer as! MDCShadowLayer
//    }
//
//    func setElevation(points: CGFloat) {
//        self.shadowLayer.elevation = ShadowElevation(rawValue: points)
//    }
//}

class SharePhotoController:
    UIViewController,
    UICollectionViewDelegateFlowLayout,
    UICollectionViewDataSource,
    UISearchDisplayDelegate,
    UITextViewDelegate,
    UITextFieldDelegate,
    UITableViewDataSource,
    SHViewControllerDelegate,
    UIImageEditFilterDelegate,
    UITableViewDelegate,
    UISearchBarDelegate,
    UISearchResultsUpdating,
    UITabBarDelegate,
    SearchProgressDelegate,
    ImagePickerDelegate,
    LightboxControllerDismissalDelegate,
    GalleryControllerDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    CropViewControllerDelegate,
    ShareHeaderCellDelegate
{
    
    private var croppedRect = CGRect.zero
    private var croppedAngle = 0

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

    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        LightboxConfig.DeleteButton.enabled = true
        SVProgressHUD.show()
        Image.resolve(images: images, completion: { [weak self] resolvedImages in
            SVProgressHUD.dismiss()
            self?.showLightbox(images: resolvedImages.compactMap({ $0 }))
        })
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
        
        let width = asset.pixelWidth/5
        let height = asset.pixelHeight/5
        
        let size = CGSize(width: width, height: height)
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
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
    
    // MARK: - Helper
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
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        guard images.count > 0 else { return }
        
        let lightboxImages = images.map {
            return LightboxImage(image: $0)
        }
        
        let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
        imagePicker.present(lightbox, animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imageArray = imageAssets
        if imageArray.count > 0 {
            imageCollectionView.reloadData()
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    var gallery: GalleryController!
    let editor: VideoEditing = VideoEditor()

    /*******************************/
    
    let ref = Database.database().reference()
    var fullmetadata: StorageMetadata?
    var thumbmetadata:  StorageMetadata?
    
    let myGroup = DispatchGroup()
  
    /*******************************/
    
    
    var bottomConstraint: NSLayoutConstraint!
    var heightConstraint: NSLayoutConstraint!
    var inputBottomConstraint: NSLayoutConstraint!
    var sendBottomConstraint: NSLayoutConstraint!
    var insets: UIEdgeInsets!
    
    var bottomAreaInset: CGFloat = 0
    var isEditingComment = false
    var CellType = CT.PIC
    
    var referenceURL: URL!
    
    var spinner : UIView!
    
    var urlArray = [String]()
    
    var docRef : DocumentReference!
    let db = Firestore.firestore()
    
    var post: Post? {
        didSet {
            if let post = post  {
                print("Post ID : \(post.id!)")
                self.CellType = CT.PIC
                imageCollectionView.reloadData()
                Products.text = post.caption
                Description.text = post.description

                DispatchQueue.main.async {
                    self.CellType = CT.MAP
                    self.locationCollectionView.reloadData()
                }

            }
        }
    }
    
    var shareDelegate :SharePhotoDelegate?
    var searchController: UISearchController!
    var searchProgressController: SearchProgressController!
    
    var postSearcher: Searcher!
    var categorySearcher: Searcher!
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
    
    let attributeTitle = [NSAttributedStringKey.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .title)]
    let attributeCaption = [NSAttributedStringKey.font: UIFont.mdc_preferredFont(forMaterialTextStyle: .body2 )]
    let attributeSubline = [NSAttributedStringKey.font: UIFont.mdc_preferredFont(forMaterialTextStyle:  .subheadline )]
    
    public var imageConstraint: NSLayoutConstraint?
    public var imageWidthConstraint: NSLayoutConstraint?
    
    
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
    let categoryTableCellId = "searchCategoryCellId"
    

    func updateSearchResults(for searchController: UISearchController) {
        postSearcher.params.query = searchController.searchBar.text
        postSearcher.search()
    }
    
    func updateSearchResults(for productTextField: UITextField) {
        postSearcher.params.query = productTextField.text
        postSearcher.search()
    }
    
    func updateCategorySearchResults(for categoryDescTextField: UITextField) {
        categorySearcher.params.query = categoryDescTextField.text
        categorySearcher.search()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        Gallery.Config.VideoEditor.savesEditedVideoToLibrary = true
        
    
        updateConstraints()
        
        /***** Set up toasts *****/
        edgesForExtendedLayout = UIRectEdge()
        //UIView.hr_setToastThemeColor(color: UIColor.themeColor())
        presentWindow = UIApplication.shared.keyWindow
        
        
        imageCollectionView.register(PostImageObject.self, forCellWithReuseIdentifier: imageCellId)
        locationCollectionView.register(MapCell.self, forCellWithReuseIdentifier: mapCellId)
        
        view.backgroundColor = UIColor.collectionCell()
        self.view.tintColor  = UIColor.themeColor()
        navigationItem.title = "Post Product"
        
        Products.delegate = self
        CategoryDesc.delegate = self
        Description.textView?.delegate = self
        tableProductsView.delegate = self
        tableProductsView.dataSource =  self
        tableCategoryView.delegate = self
        tableCategoryView.dataSource =  self
        
        setupImageAndTextViews()
        setNavigationButtons()
        
       guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUserWithUID(uid: uid, completion: { (user) in
            self.user = user
        })
        
        /****** Tap to dismiss KeyBoard ******/
        
        let tapImageCollectionView = UITapGestureRecognizer(target: self, action: #selector(imageCollectionViewTapped(tapGestureRecognizer: )))
        imageCollectionView.isUserInteractionEnabled = true
        imageCollectionView.addGestureRecognizer(tapImageCollectionView)
        //view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dissmissKeyboard)))
        /****** End Gestures           ******/
        
        
        /******  Algolia Search Products ******/
        tableProductsView.register(SearchTableCell.self, forCellReuseIdentifier: searchTableCellId)
        postSearcher = Searcher(index: AlgoliaManager.sharedInstance.posts, resultHandler: self.handleSearchResults)
        postSearcher.params.hitsPerPage = 15
        postSearcher.params.attributesToRetrieve = ["*" ]
        postSearcher.params.attributesToHighlight = ["product"]
        tableProductsView.tableHeaderView?.isHidden = true
        
        
        /******  Algolia Search Categories ******/
        tableCategoryView.register(SearchTableCell.self, forCellReuseIdentifier: searchTableCellId)
        categorySearcher = Searcher(index: AlgoliaManager.sharedInstance.category, resultHandler: self.handleSearchResults)
        categorySearcher.params.hitsPerPage = 15
        categorySearcher.params.attributesToRetrieve = ["*" ]
        categorySearcher.params.attributesToHighlight = ["category"]
        tableCategoryView.tableHeaderView?.isHidden = true
        
        definesPresentationContext = true
        updateSearchResults(for: Products)
        updateCategorySearchResults(for: CategoryDesc)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // End Algolia Search
        
    }
    
    
    func text(for priceLevel: GMSPlacesPriceLevel) -> String {
        switch priceLevel {
        case .free: return NSLocalizedString("Free",comment: "Relative cost for a free location")
        case .cheap: return NSLocalizedString("Cheap",comment: "Relative cost for a cheap location")
        case .medium: return NSLocalizedString("Medium",comment: "Relative cost for a medium cost location")
        case .high: return NSLocalizedString("High",comment: "Relative cost for a high cost location")
        case .expensive: return NSLocalizedString("Expensive",comment: "Relative cost for an expensive location")
        case .unknown: return NSLocalizedString("Unkown",comment: "Relative cost for when it is unknown")
        }
    }
    
    
//    @objc func uploadPressed(_ sender: Any) {
//        spinner = displaySpinner()
//        let uid = Auth.auth().currentUser!.uid
//
//        for image in imageArray {
//        let postRef = ref.child("posts").childByAutoId()
//        let postId = postRef.key
//        guard let resizedImageData = UIImageJPEGRepresentation(image, 0.9) else { return }
//        guard let thumbnailImageData = image.resizeImage(640, with: 0.7) else { return }
//        let fullFilePath = "\(uid)/full/\(postId)/jpeg"
//        let thumbFilePath = "\(uid)/thumb/\(postId)/jpeg"
//        let metadata = StorageMetadata()
//        let uid = Auth.auth().currentUser!.uid
//
//        metadata.contentType = "image/jpeg"
//        let storageRef = Storage.storage().reference()
//        let message = MDCSnackbarMessage()
//        let myGroup = DispatchGroup()
//        myGroup.enter()
//        storageRef.child(fullFilePath).putData(resizedImageData, metadata: metadata) { fullmetadata, error in
//            if let error = error {
//                message.text = "Error uploading image"
//                MDCSnackbarManager.show(message)
//                //self.button.isEnabled = true
//                print("Error uploading image: \(error.localizedDescription)")
//                return
//            }
//            self.fullmetadata = fullmetadata
//            myGroup.leave()
//        }
//        myGroup.enter()
//        storageRef.child(thumbFilePath).putData(thumbnailImageData, metadata: metadata) { thumbmetadata, error in
//            if let error = error {
//                message.text = "Error uploading thumbnail"
//                MDCSnackbarManager.show(message)
//                //self.button.isEnabled = true
//                print("Error uploading thumbnail: \(error.localizedDescription)")
//                return
//            }
//
//            myGroup.leave()
//        }
//
//
//
//
//
//        myGroup.notify(queue: .main) {
//            if let spinner = self.spinner {
//                self.removeSpinner(spinner)
//            }
//
//            let fullUrl = self.fullmetadata?.downloadURLs?[0].absoluteString
//            let fullstorageUri = storageRef.child((self.fullmetadata?.path!)!).description
//            let thumbUrl = self.thumbmetadata?.downloadURLs?[0].absoluteString
//            let thumbstorageUri = storageRef.child((self.thumbmetadata?.path!)!).description
//            let trimmedComment = self.Description.text?.trimmingCharacters(in: CharacterSet.whitespaces)
//            let data = ["full_url": fullUrl ?? "",
//                        "full_storage_uri": fullstorageUri,
//                        "thumb_url": thumbUrl ?? "",
//                        "thumb_storage_uri": thumbstorageUri,
//                        "text": trimmedComment ?? "",
//                        "author": Auth.auth().currentUser?.uid as Any,
//                        "timestamp": ServerValue.timestamp()] as [String: Any]
//            postRef.setValue(data)
//            postRef.root.updateChildValues(["people/\(uid)/posts/\(postId)": true, "feed/\(uid)/\(postId)": true])
//            self.navigationController?.popViewController(animated: true)
//            message.text = "Upload completed successfully"
//            MDCSnackbarManager.show(message)
//        }
//      }
//    }
//
    var urlThumbArray = [String]()
    var urlOriginalArray = [String]()
    
    let loadImages: CustomImageView = {
        let iv = CustomImageView()
        return iv
    }()
    
    
    
    @objc func imageCollectionViewTapped(tapGestureRecognizer: UITapGestureRecognizer){
        view.endEditing(true)
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
    
    let tableCategoryView : UITableView = {
        let tv = UITableView()
        tv.isHidden = true
        tv.tableFooterView?.isHidden = true
        tv.tableHeaderView?.isHidden = true
        tv.tableHeaderView=nil
        tv.tableFooterView=nil
        return tv
    }()
    
    let buttonMenus = UIView()

    
    
    
    func setupImageAndTextViews() {
        
        // Construct a window and the split split pane view controller we are going to embed our UI in.
        // Wrap the split pane controller in a inset controller to get the map displaying behind our
        // Make the window visible and allow the app to continue initialization.
        
        //docRef = Firestore.firestore().document("maplefirebase/posts")
        
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        
        locationCollectionView.dataSource = self
        locationCollectionView.delegate = self
        
        let locationCard = UIView()
        locationCard.addSubview(locationCollectionView)

        locationCollectionView.anchor(top: locationCard.topAnchor, left: locationCard.leftAnchor, bottom: locationCard.bottomAnchor, right: locationCard.rightAnchor)
        
        let imageCard = MDCCard()
        imageCard.setShadowElevation(ShadowElevation.menu, for: UIControlState.normal)
        imageCard.addSubview(imageCollectionView)
        imageCollectionView.anchor(top: imageCard.topAnchor, left: imageCard.leftAnchor, bottom: imageCard.bottomAnchor, right: imageCard.rightAnchor)
        
        let containerView = MDCCard()
        containerView.setShadowElevation(ShadowElevation.cardResting, for: UIControlState.normal)
        
        containerView.inkView.inkColor = UIColor.themeColor()
        containerView.backgroundColor = UIColor.collectionBackGround()
        
        buttonMenus.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        buttonMenus.layer.cornerRadius = 10
        buttonMenus.backgroundColor = UIColor.veryLightGray()
        buttonMenus.layer.borderWidth = 2
        buttonMenus.layer.borderColor = UIColor.black.cgColor
        
        
        
        //let stackButtonsVerical = UIStackView(arrangedSubviews: [addPhotos,filterPhotos,erasePhotos])
        let stackButtonsVerical = UIStackView(arrangedSubviews: [addPhotos, mapsButton, clearAllFields])
        stackButtonsVerical.axis = .vertical
        stackButtonsVerical.distribution = .fillProportionally
        
        buttonMenus.addSubview(stackButtonsVerical)
     
        
        view.addSubview(containerView)
        
        //containerView.addSubView()
        containerView.addSubview(imageCard)
        containerView.addSubview(Products)
        containerView.addSubview(Description)
        containerView.addSubview(DescriptionLabel)
        containerView.addSubview(CategoryDesc)
        containerView.addSubview(locationCard)
        containerView.addSubview(RunningCountLabel)
        containerView.addSubview(tableProductsView)
        containerView.addSubview(tableCategoryView)
        containerView.addSubview(buttonMenus)
        containerView.addSubview(mapLabel)
        containerView.addSubview(Photos)
        
 
        let productsHeight = CGFloat(45.0)
        let paddingSize = CGFloat(7.0)
        let paddingTopBottom = CGFloat(7.0)
        
       
        if #available(iOS 11.0, *) {
            containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor , left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor,
                                 paddingTop: 7,
                                 paddingLeft: 7,
                                 paddingBottom: 7 ,
                                 paddingRight: 7,
                                 width: 0 ,
                                 height: 0)
        } else {
            containerView.anchor(top: view.topAnchor , left: view.leftAnchor, bottom: view.bottomAnchor , right: view.rightAnchor)
        }
       
        
        self.pictureSize = containerView.frame.size.width
        
        
        imageCard.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil , right: containerView.rightAnchor,
                         paddingTop: paddingTopBottom,
                         paddingLeft: paddingSize,
                         paddingBottom: paddingTopBottom,
                         paddingRight: paddingSize,
                         width: 0 , height: (imageConstraint?.constant)!)
        
        Products.anchor(top:  imageCard.bottomAnchor, left: containerView.leftAnchor, bottom: nil , right: containerView.rightAnchor ,
                        paddingTop: paddingTopBottom,
                        paddingLeft: paddingSize,
                        paddingBottom: paddingTopBottom,
                        paddingRight: paddingSize,
                        width: 0 , height: productsHeight)
        
        

        locationCard.anchor(top: Products.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor ,
                                              paddingTop: paddingTopBottom,
                                              paddingLeft: paddingSize,
                                              paddingBottom: paddingTopBottom,
                                              paddingRight: paddingSize,
                                              width: 0, height: 40)

        
        
        Description.anchor(top: locationCard.bottomAnchor, left: containerView.leftAnchor, bottom: nil , right: containerView.rightAnchor,
                           paddingTop: paddingTopBottom ,
                           paddingLeft: paddingSize,
                           paddingBottom: paddingTopBottom,
                           paddingRight: paddingSize,
                           width: 0 , height: 3 * productsHeight)
        
        RunningCountLabel.anchor(top: nil, left: nil, bottom: Description.bottomAnchor, right: Description.rightAnchor , paddingTop: 4 , paddingLeft: 0, paddingBottom: 1 , paddingRight: 0, width: 50 , height: 30)
        
        CategoryDesc.anchor(top: Description.bottomAnchor, left: containerView.leftAnchor, bottom: nil , right: containerView.rightAnchor,
                            paddingTop: paddingTopBottom ,
                            paddingLeft: paddingSize,
                            paddingBottom: paddingTopBottom,
                            paddingRight: paddingSize,
                            width: 0 , height: productsHeight)
        
        stackButtonsVerical.anchor(top: buttonMenus.topAnchor, left: buttonMenus.leftAnchor, bottom: buttonMenus.bottomAnchor, right: buttonMenus.rightAnchor)
        
        buttonMenus.anchor(top: imageCard.topAnchor, left: nil, bottom: nil, right: imageCard.rightAnchor, paddingTop: 10, paddingLeft: 5, paddingBottom: 0, paddingRight: 15, width: 40, height: 120)
        
        tableProductsView.anchor(top: Products.bottomAnchor, left: Products.leftAnchor, bottom: containerView.bottomAnchor , right: Products.rightAnchor)
        
        tableCategoryView.anchor(top: CategoryDesc.bottomAnchor, left: CategoryDesc.leftAnchor, bottom: containerView.bottomAnchor, right: CategoryDesc.rightAnchor)
    }
    
    /*
     let textFieldFloating = MDCMultilineTextField()
     scrollView.addSubview(textFieldFloating)
     textFieldFloating.placeholder = "Full Name"
     textFieldFloating.textView.delegate = self
     textFieldControllerFloating = MDCTextInputControllerUnderline(input: textFieldFloating) // Hold on as a property
     */
    
    var textFieldControllerFloating : MDCTextInputController?
    
    let Products: MDCTextField = {
        let TextField = MDCTextField()
        TextField.placeholder = "Products"
        TextField.borderView?.borderFillColor = .white
        TextField.hidesPlaceholderOnInput = true
        TextField.font = UIFont.systemFont(ofSize: 15)
        TextField.autocorrectionType = UITextAutocorrectionType.yes
        TextField.keyboardType = UIKeyboardType.default
        TextField.clearButtonMode = UITextFieldViewMode.whileEditing;
        TextField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        TextField.backgroundColor =  UIColor.collectionCell()
        TextField.addTarget(self, action: #selector(textProductFieldChanged(_:)), for: .editingChanged)
        TextField.tag = 1
        return TextField
    }()
    
    let CategoryDesc: MDCTextField = {
        let TextField = MDCTextField()
        TextField.placeholder = "Category"
        TextField.font = UIFont.systemFont(ofSize: 15)
        TextField.autocorrectionType = UITextAutocorrectionType.yes
        TextField.keyboardType = UIKeyboardType.default
        TextField.clearButtonMode = UITextFieldViewMode.whileEditing;
        TextField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        TextField.backgroundColor =  UIColor.collectionCell()
        TextField.addTarget(self, action: #selector(textCategoryFieldChanged(_:)), for: .editingChanged)
        TextField.tag = 3
        return TextField
    }()
    
    let Description:  MDCMultilineTextField = {
        let TextField =  MDCMultilineTextField()
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
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.collectionCell()
        //collectionView.shadowLayer.isShadowMaskEnabled = true
        //collectionView.setDefaultElevation()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    

    let locationCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.collectionCell()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    
    func showControllerForSetting(_ setting: ShareSetting) {
        let dummySettingsViewController = UIViewController()
        dummySettingsViewController.view.backgroundColor = UIColor.white
        dummySettingsViewController.navigationItem.title = setting.name.rawValue
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }
    
    let  shareShowSettings = ShareShowSettings()
    
    @objc func handleEditMenu()
    {
        shareShowSettings.showSettings()
        print ("Handle Edit Menu")
        
    }
    

    lazy var mapsButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.collectionBackGround()
        button.setImage(#imageLiteral(resourceName: "ic_place"), for: .normal)
        button.setTitle( "" , for: .normal)
        button.setTitleColor( UIColor.themeColor() , for: .normal)
        button.tintColor = UIColor.themeColor()
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
    
    lazy var clearAllFields: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_delete"), for: .normal)
        button.tintColor = UIColor.themeColor()
        button.sizeToFit()
        button.addTarget(self, action: #selector(didClearAllFields), for: .touchUpInside)
        //button.setElevation(ShadowElevation.raisedButtonResting, for: .normal)
        //button.setElevation(ShadowElevation.raisedButtonPressed, for: .highlighted)
        CellType = CT.PIC
        return button
    }()
    
    
    lazy var addPhotos: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_camera"), for: .normal)
        button.sizeToFit()
        button.tintColor = UIColor.themeColor()
        button.addTarget(self, action: #selector(handleAddPhotos), for: .touchUpInside)
        CellType = CT.PIC
        return button
    }()
    
    lazy var erasePhotos: UIButton = {
        let button = UIButton(type: .system)
        //button.setImage(#imageLiteral(resourceName: "ic_delete_forever_white"), for: .normal)
        button.sizeToFit()
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleClearAllFields), for: .touchUpInside)
        CellType = CT.PIC
        return button
    }()
    
    func didReturnMapPlace(place: GMSPlace){
        print (place)
    }
    
    func setNavigationButtons(){
        //let rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.compose, target: self, action: #selector(handleShareAll))
        //navigationItem.rightBarButtonItem = rightButton
        
        let rightImage = UIImage(named: "ic_add_to_photos")?.withRenderingMode(.automatic)
        let rightButton = UIBarButtonItem(image: rightImage, style: .done , target: self, action: #selector(handleEditMenu))
        rightButton.tintColor = UIColor.themeColor()
        navigationItem.rightBarButtonItem = rightButton
        
//        let leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(handleEditMenu))
//        navigationItem.leftBarButtonItem = leftButton
//
        
        let leftImage = UIImage(named: "ic_menu")?.withRenderingMode(.automatic)
        let leftButton = UIBarButtonItem(image: leftImage, style: .done , target: self, action: #selector(handleEditMenu))
        leftButton.tintColor = UIColor.themeColor()
        navigationItem.leftBarButtonItem = leftButton
    }
    
    let noneText = NSLocalizedString("PlaceDetails.MissingValue", comment: "The value of a property which is missing")
    
    
    @objc func handleClearAllFields()
    {
        CellType = CT.PIC
        
        if post == nil
        {
            let alert = UIAlertController(title: "Clear All Fields", message: "Current fields will be cleared. Continue?", preferredStyle: UIAlertControllerStyle.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler:
                { action in
                    switch action.style{
                    case .default:
                        self.imageArray.removeAll()
                        self.mapObjects.removeAll()
                        self.Products.text?.removeAll()
                        self.CategoryDesc.text?.removeAll()
                        self.Description.text?.removeAll()
                        self.imageCollectionView.reloadData()
                        self.locationCollectionView.reloadData()
                 
                        //let image = UIImage(named: "icons8-erase_filled")
                        //self.presentWindow!.makeToast(message: "All fields cleared", duration: 1, position: "bottom" as AnyObject, image: image!)
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                    }}))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
            
    
    
    @objc func openMapSelector() {
        CellType = CT.MAP
        print("Open the maps window")
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        placePicker.modalPresentationStyle = .popover
        placePicker.popoverPresentationController?.sourceView = mapsButton
        placePicker.popoverPresentationController?.sourceRect = mapsButton.bounds
        self.present(placePicker, animated: true, completion: nil)
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
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        print("Post Hits : \(postHits.count)")
        return postHits.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: searchTableCellId, for: indexPath) as! SearchTableCell
        
        // Load more?
        if indexPath.row + 5 >= postHits.count {
            postSearcher.loadMore()
        }
        cell.post = PostRecord(json: postHits[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if Products.tag == 1 {
        let Post = PostRecord(json: postHits[indexPath.row])
        Products.text = Post.product
        tableProductsView.isHidden = true
        dissmissKeyboard()
        }
        
        if CategoryDesc.tag == 3 {
            let Post = PostRecord(json: postHits[indexPath.row])
            CategoryDesc.text = Post.product
            tableProductsView.isHidden = true
            dissmissKeyboard()
        }
    }
    
    var editingIndex: IndexPath!
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardSize.height : 0
            let inset = isKeyboardShowing ? -bottomAreaInset : bottomAreaInset
            heightConstraint?.constant += inset
            inputBottomConstraint?.constant = isKeyboardShowing ? 0 : bottomAreaInset
            sendBottomConstraint?.constant = isKeyboardShowing ? 12 : (12 + bottomAreaInset)
            if let animationDuration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as? Double {
                UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { completed in
                    if isKeyboardShowing {
                        if !(self.Description.text?.isEmpty)!{
                            let indexPath = self.isEditingComment ? self.editingIndex : IndexPath(item: (self.Description.text?.count)! - 1, section: 1)
                            //collectionView.scrollToItem(at: indexPath!, at: .bottom, animated: true)
                        }
                    } else {
                        MDCSnackbarManager.setBottomOffset(0)
                    }
                })
            }
        }
    }

    
    func handleSearchResults(results: SearchResults?, error: Error?, userInfo: [String: Any]) {
        guard let results = results else { return }
        if results.page == 0 {
            postHits = results.hits
        } else {
            postHits.append(contentsOf: results.hits)
        }
        originIsLocal = results.content["origin"] as? String == "local"
        self.tableProductsView.reloadData()
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
    
//    override func collectionView(_ collectionView: UICollectionView,
//                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! MDCCardCollectionCell
//        // If you wanted to have the card show the selected state when tapped
//        // then you need to turn isSelectable to true, otherwise the default is false.
//        cell.isSelectable = true
//
//        cell.selectedImageTintColor = .blue
//        cell.cornerRadius = 8
//        cell.setShadowElevation(6, for: .selected)
//        cell.setShadowColor(UIColor.black, for: .highlighted)
//        return cell
//    }
    
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
                cell.imageObject = (imageArray[indexPath.item]) as UIImage
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
                            let vc = SHViewController(image: img)
                            vc.delegate = self as SHViewControllerDelegate
                            self.currentImageItem = item
                            os_log("Filtering an item", log: OSLog.default, type: .debug)
                            self.present(vc, animated: true, completion: nil)
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
        return UIEdgeInsetsMake(1, 1, 1, 1)
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
                        let vc = SHViewController(image: img)
                        vc.delegate = self as SHViewControllerDelegate
                        currentImageItem = item
                        os_log("Filtering an item", log: OSLog.default, type: .debug)
                        present(vc, animated: true, completion: nil)
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
    
    func shViewControllerImageDidFilter(image: UIImage) {
        if currentImageItem! >= 0 {
            imageArray[currentImageItem!] = image
            imageCollectionView.reloadData()
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
    
    let imagePicker = ImagePickerController()
    
    @objc func handleAddPhotos(){
        CellType = CT.PIC
//        let pickerController = DKImagePickerController()
//        //self.imageArray.removeAll()
//        pickerController.didSelectAssets = { (assets: [DKAsset]) in
//            for asset in assets {
//                asset.fetchOriginalImage(true, completeBlock: { image, info in
//                    self.imageArray.append(image!)
//                })
//                self.imageCollectionView.reloadData()
//            }
//        }
//        self.present(pickerController, animated: true) {}
        
        var config = Configuration()
        config.doneButtonTitle = "Finish"
        config.noImagesTitle = "Sorry! There are no images here!"
        config.recordLocation = true
        config.allowVideoSelection = true
        
        imagePicker.expandGalleryView()
        imagePicker.delegate = self
        imagePicker.imageLimit = 5
        imagePicker.doneButtonTitle = "Select"
        
        
        gallery = GalleryController()
        gallery.delegate = self
        present(gallery, animated: true, completion: nil)
        
        //present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    
    public var imageAssets : [UIImage] {
        return AssetManager.resolveAssets(imagePicker.stack.assets)
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
    
    
    @objc func textCategoryFieldChanged(_ textField: UITextField) {
        updateCategorySearchResults(for: textField)
        tableCategoryView.isHidden = false
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        Products.resignFirstResponder()
        Description.resignFirstResponder()
        CategoryDesc.resignFirstResponder()
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
        if textField.tag == 3 {
            tableCategoryView.isHidden = true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            tableProductsView.isHidden = false
        }
       
        if textField.tag == 3 {
            tableCategoryView.isHidden = false
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
    
    
    @objc func handleFilter()
    {
        if imageArray.count > 0 {
            let pickerController = DKImagePickerController()
            self.imageArray.removeAll()
            pickerController.didSelectAssets = { (assets: [DKAsset]) in
                pickerController.maxSelectableCount = 5
                for asset in assets {
                    asset.fetchOriginalImage(true, completeBlock: { image, info in
                        self.imageArray.append(image!)
                    })
                    self.imageCollectionView.reloadData()
                }
            }
            self.present(pickerController, animated: true) {}
        }
    }
    
    
    var PrefersStatusBarHidden: Bool {
        return true
    }
    
    func handleShare(){
        
    }
    
    func refreshMapCollection(completion: @escaping (Error?) -> Void) {
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


extension SharePhotoController : GMSPlacePickerViewControllerDelegate {
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Create the next view controller we are going to display and present it.
        let nextScreen = PlaceDetailViewController(place: place)
        self.splitPaneViewController?.push(viewController: nextScreen, animated: false)
        self.mapViewController?.coordinate = place.coordinate
        // Dismiss the place picker.
        let placePickerObject = locObject(place: place)
        mapObjects.append(placePickerObject!)
        refreshMapCollection { error in
            if let error = error {
                print("Oops! Something went wrong... : ", error)
            } else {
                print("It has finished")
            }
        }
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




