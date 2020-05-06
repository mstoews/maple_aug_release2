//
//  HomeController.swift
//  InstagramFirebase
//
//  Created by Murray Toews on 6/3/17.
//  Copyright © 2017 maple.com

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseUI
import AlgoliaSearch
import InstantSearchCore
import Lightbox
import GoogleSignIn
import MaterialComponents
import JGProgressHUD
import Mapbox


// MARK: - Fix the pagination


import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
  var locationManager = CLLocationManager()
  var latestLocation: CLLocation?

  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
  }

  func start() {
    locationManager.startUpdatingLocation()
  }

  func stop() {
    locationManager.stopUpdatingLocation()
  }

  // MARK: - CLLocationManagerDelegate

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    // Pick the location with best (= smallest value) horizontal accuracy
    latestLocation = locations.sorted { $0.horizontalAccuracy < $1.horizontalAccuracy }.first
  }

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedAlways || status == .authorizedWhenInUse {
      locationManager.startUpdatingLocation()
    } else {
      locationManager.stopUpdatingLocation()
    }
  }
}


enum  FetchType {
    case ALL
    case USER
}


class HomeController: MDCCollectionViewController, HomePostCellDelegate, HomeHeaderCellDelegate, CLLocationManagerDelegate

{

    var FETCH_TYPE = FetchType.USER
    let db = Firestore.firestore()
    let cellId = "cellId"
    let cellHeaderId = "cellHeaderId"
    
    var PAGINATION_LIMIT : Int = 0
    private let refreshControl = UIRefreshControl()
    var spinner: UIView?
    let bottomBarView = MDCBottomAppBarView()
    
    lazy var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let red = MDCPalette.red.tint600
 
    var newPost = false
    var followChanged = false
    var isFirstOpen = true
    var locations = [LocationObject]()
    let backgroundView = UIImageView()
    private var listener: ListenerRegistration?
    private var posts: [FSPost] = []
    private var documents: [DocumentSnapshot] = []

    static let updateFeedNotificationName = NSNotification.Name(rawValue: "handleRefresh")
    
    var appBarViewController = MDCAppBarViewController()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: HomeController.updateFeedNotificationName, object: nil)
        collectionView?.backgroundColor = UIColor.collectionBackGround()
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(HomeHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: cellHeaderId)
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged )
        self.collectionView.alwaysBounceVertical = true
        
        collectionView?.refreshControl = refreshControl
        collectionView?.backgroundView = nil
        //Firestore.updateDocCounts()
        setupNavigationItems()
        collectionView?.delegate = self
        PAGINATION_LIMIT = 0
        handleRefresh()
        
        MDCAppBarColorThemer.applyColorScheme(ApplicationScheme.shared.colorScheme, to:self.appBarViewController)

        MDCAppBarTypographyThemer.applyTypographyScheme(ApplicationScheme.shared.typographyScheme, to: self.appBarViewController)
    }
    
    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    @objc func handleRefresh() {
        refreshControl.beginRefreshing()
        PAGINATION_LIMIT = PAGINATION_LIMIT + 100
        observePostFeed()
        refreshControl.endRefreshing()
    }

    
    func didTapMapButton(post: FSPost) {
        print("Did tap map button ... ")
        //let viewController = MapPostViewController()
        
        let viewController = AdvancedNavigationController()
        
        let locationManager = LocationManager()
      
        
        // Get the current location here and add it below.
        // If there are multiple locations the user will be directed to the latest location
        
        locations.removeAll()
        if let postId = post.id {
            Firestore.fetchLocationByPostId(postId: postId) { (locationObjects) in
                if locationObjects.count > 0 {
                    let values : [String: Any] = [
                        "currentLat" : locationObjects[0].latitude!,
                        "currentLng" : locationObjects[0].longitude!,
                        "destinationLat" : locationObjects[0].latitude!,
                        "destinationLng" : locationObjects[0].longitude!,
                        "Title": post.product,
                        "SubTitle" : post.description]
                    
                    let nav = Navigation(dictionary: values)
                    viewController.nav = nav
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
                else
                {
                    locationManager.start()
                    let location = locationManager.latestLocation
                    locationManager.stop()
                    
                    let values : [String: Any] = [
                        "currentLat" : location?.coordinate.latitude as Any,
                        "currentLng" : location?.coordinate.longitude as Any,
                        "destinationLat" : location?.coordinate.latitude as Any,
                        "destinationLng" : location?.coordinate.longitude as Any,
                        "Title": post.product,
                        "SubTitle" : post.description]
                    
                    let nav = Navigation(dictionary: values)
                    viewController.nav = nav
                    self.navigationController?.pushViewController(viewController, animated: true)
                    
                    
                }
            }
            
        }
    }
    
    func didSharePost(post: FSPost, imageObject: ImageObject) {
    
        shareImageView.loadImage(urlString: imageObject.url)
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            
            //let objectsToShare = [post.description]
            let activityVC = UIActivityViewController(activityItems: [shareImageView.image!], applicationActivities: nil)
            activityVC.title = "Share Post"
            activityVC.excludedActivityTypes = []
            
            activityVC.popoverPresentationController?.sourceView = self.view
            activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            //activityVC.popoverPresentationController?.sourceRect = self.view.frame
            
            self.present(activityVC, animated: true, completion: nil)
        }
        else
        {
            let activityController = UIActivityViewController(activityItems:  [shareImageView.image!] , applicationActivities: nil)
             activityController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            present(activityController, animated: true, completion: nil)
        }
    }
    
    func didTapImageCell(for cell: UserImageCell, post: FSPost) {
        
    }
    
   
    func setButtonImage(button: UIButton, btnName: String,  color: UIColor)
    {
        let origImage = UIImage(named: btnName);
        let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = color
    }
  
    let shareImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let emptyHomeLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.text = "This feed will be populated as you follow more people."
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        messageLabel.sizeToFit()
        return messageLabel
    }()
    
   
    
    
    deinit {
        listener?.remove()
    }
    
 
    
    
    func updateAlgoliaStore(post: FSPost)
    {
        var imageUrl: String?
        if post.imageUrlArray.count > 0 {
            imageUrl = post.imageUrlArray[0]
        }
        
        
        if let imageUrl = imageUrl {
        let values : [String: Any] = ["userid" : post.uid,
                                      "name" : post.userName,
                                      "profileUrl" : post.imageUrl,
                                      "product": post.product ,
                                      "description" : post.description,
                                      "urlArray" : imageUrl,
                                      "creationDate": Date().timeIntervalSince1970]
        
        AlgoliaManager.sharedInstance.posts.addObject(values, withID: post.id! , completionHandler: { (content, error) -> Void in
            if error == nil {
                if let objectID = content!["objectID"] as? String {
                    print("Object ID: \(objectID)")
                }
            }
        })
        }
    }
    
    fileprivate func observePostFeed()
    {
        stopObserving()
        self.posts.removeAll()
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Fetching Posts"
        hud.show(in: view)
        
        self.listener = self.db.collection("posts")
            .order(by: "creationDate", descending: true).limit(to: PAGINATION_LIMIT)
            .addSnapshotListener{  [weak self] (snapshot, error) in
                guard let strongSelf = self else { return }
                
                guard let snapshot = snapshot else {
                    print("Error fetching snapshot results: \(error!)")
                    return
                }
                
                let _fsPost = snapshot.documents.map { (document) -> FSPost in
                    let post = FSPost(dictionary: document.data(), postId: document.documentID)!
                    strongSelf.updateAlgoliaStore(post: post)
                    return post
                }
                
                strongSelf.posts = _fsPost
                strongSelf.documents = snapshot.documents
       
                DispatchQueue.main.async {
                    strongSelf.collectionView?.reloadData()
                }
        }
        hud.dismiss()
    }
    
    
    fileprivate func stopObserving() {
        listener?.remove()
    }
    
    //MARK:- Top Posts
    func observeTopFeed(){
        stopObserving()

        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Fetching Posts"
        hud.show(in: view)

        self.listener = self.db.collection("posts")
            .order(by: "numberOfLikes", descending: false).limit(to: 5)
            .addSnapshotListener{  (snapshot, error) in
                guard let snapshot = snapshot else {
                    print("Error fetching snapshot results: \(error!)")
                    return
                }

                let models = snapshot.documents.map { (document) -> FSPost in
                    if let model = FSPost(dictionary: document.data(), postId: document.documentID) {
                        //Firestore.updateAlgoliaPost(post: model)
                        return model
                    }
                    else {
                        // Don't use fatalError here in a real app.
                        fatalError("Unable to initialize type \(FSPost.self) with dictionary \(document.data())")
                    }
                }

                self.posts = models

                self.documents = snapshot.documents

                if self.documents.count > 0 {
                    //print("Number of posts: \(self.documents.count)")
                    self.collectionView?.backgroundView = nil
                }
                else
                {
                    self.collectionView?.backgroundView = nil
                }
                self.collectionView?.reloadData()
        }
        hud.dismiss()
    }

    
    func didTapImageCell(for cell: UserImageCell, post: Post) {
        
        var photos: [PhotoViewModel] = []
        for url in post.imageUrlArray {
            let pt = PhotoViewModel(imageURL: URL(string: url),thumbnailImageURL: URL(string: url))
            pt.caption = post.caption
            photos.append(pt)
        }
    }
    
    func didTapUserNameLabel(uid: String) {
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
            Firestore.fetchUserWithUID(uid: uid, completion: { (user) in
            userProfileController.user = user
            self.navigationController?.pushViewController(userProfileController, animated: true)
        })
    }
    
    func didTapFollowUser(for cell: HomePostCell, post: FSPost) {
        let message = MDCSnackbarMessage()
        MDCSnackbarManager.snackbarMessageViewBackgroundColor  = UIColor.buttonThemeColor()
        if let uid = Auth.auth().currentUser?.uid {
            if uid != post.uid {
                Firestore.didFollowUser(uid: uid, uidFollow: post.uid, didFollow: true)
                message.text = "You are following \(post.userName)"
                MDCSnackbarManager.show(message)
            }
            else {
                message.text = "Probably should not follow yourself ..."
                MDCSnackbarManager.show(message)
            }
        }
    }
    
    func didShowTopUsers() {
        FETCH_TYPE = FetchType.USER
        print("didShowTopUsers")
        observeTopFeed()
    }
    
    func didShowFollowersPosts() {
        FETCH_TYPE = FetchType.ALL
        print("didShowFollowerPosts")
        observePostFeed()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        MDCSnackbarManager.setBottomOffset(bottomBarView.frame.height)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObserving()
    }
    
    func updateFireStore (post: Post)
    {
        if let postid = post.id {
            let values : [String: Any] = [
                "postid" : postid,
                "name" : post.user.username,
                "uid" : post.user.uid,
                "profileUrl" : post.user.profileImageUrl,
                "product": post.caption,
                "description" : post.description,
                "originalImages" : post.largeUrlArray,
                "thumbImages" : post.imageUrlArray,
                "creationDate": Date().timeIntervalSince1970,
                "numberOfLikes": 1,
                "numberOfComments" : 4]
            
            db.collection("posts").document(postid).setData(values)
            { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully postId: " + postid)
                }
            }
        }
    }
    
    internal func cleanCollectionView() {
        if collectionView!.numberOfItems(inSection: 0) > 0 {
            collectionView!.reloadSections([0])
        }
    }
    
    // MARK: - Needs a fix to move to dynamic links 
    func setupNavigationItems() {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
        navigationItem.titleView?.backgroundColor = ApplicationScheme().colorScheme.backgroundColor
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if posts.count > 0 {
            
            //let approximateWidthOfBioTextView = view.frame.width
            //let size = CGSize(width: approximateWidthOfBioTextView, height: 1000)
            //let attributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: CGFloat(15))]
            let post = posts[indexPath.item]
            let lineHeight = CGFloat(40)
            //
            let totalHeight = CGFloat(360)
            let descriptionLength = CGFloat(post.description.lengthOfBytes(using: String.Encoding.isoLatin2))
            var descriptionRatio = descriptionLength/CGFloat(100)
            descriptionRatio.round(.up)
            
            let estimatedHeight = descriptionRatio * lineHeight
            //let estimatedFrame = NSString(string: post.description).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            return CGSize(width: view.frame.width - 15 , height: totalHeight + CGFloat(estimatedHeight))
        }
        else
        {
            return CGSize(width: view.frame.width - 15 , height: view.frame.height/2 )
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if posts.count > 0 {
            return posts.count
        }
        else
        {
            return 0
        }
    }
        
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        if (posts.count > 0 ){
            cell.post = posts[indexPath.item]
        }
        cell.delegate = self
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: cellHeaderId, for: indexPath) as! HomeHeaderCell
        header.delegate = self
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 7, left: 1, bottom: 1, right: 1)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 40)
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
        return size
    }
    
     func didTapComment(post: FSPost) {
        print("Message coming from home controller ... didTapComment")
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    func didTapImage(for cell: PostImage, post: FSPost) {
        
        var images : [LightboxImage] = []
        if post.imageUrlArray.count > 0 {
            for url in post.imageUrlArray {
                //let pt = PhotoViewModel(imageURL: URL(string: url),thumbnailImageURL: URL(string: url))
                //pt.caption = post.product + "\n" + post.description
                //photos.append(pt)
                let lightbox = LightboxImage(imageURL: URL(string: url)! )
                lightbox.text = post.product + "\n" + post.description
                images.append( lightbox)
                
            }
        }
        
        if images.count > 0 {
            let controller = LightboxController(images: images)
            controller.dynamicBackground = true
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true, completion: nil)
        }
       
    }
    
    func didTapBookmark(for cell: HomePostCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        var post = self.posts[indexPath.item]
                 if (post.hasBookmark == true) {
                    post.hasBookmark = false
                    Firestore.didBookmarkedPost(post: post, didBookmark: false)
                }
                else
                {
                    post.hasBookmark = true
                    Firestore.didBookmarkedPost(post: post, didBookmark: true)
                }
        self.posts[indexPath.item] = post
        //self.collectionView?.reloadItems(at: [indexPath])
        
        if post.hasBookmark == true {
            self.setButtonImage(button: cell.bookmarkButton, btnName: "ic_bookmark", color: UIColor.orange)
        }
        else{
            self.setButtonImage(button: cell.bookmarkButton, btnName: "ic_bookmark_border", color: UIColor.orange)
        }
    }
    
    
    func didLike(for cell: HomePostCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        var post = self.posts[indexPath.item]
        if let postId = post.id {
            if let uid = Auth.auth().currentUser?.uid {
                if (post.hasLiked == true) {
                    post.hasLiked = false
                    Firestore.didLikePost(postId: postId, uidLiked: uid, didLike: false)
                }
                else
                {
                    post.hasLiked = true
                    Firestore.didLikePost(postId: postId, uidLiked: uid, didLike: true)
                }
            }
        }
        self.posts[indexPath.item] = post
        // self.collectionView?.reloadItems(at: [indexPath])
        if post.hasLiked == true {
            self.setButtonImage(button: cell.likeButton, btnName: "ic_favorite", color: UIColor.red)
        }
        else{
            self.setButtonImage(button: cell.likeButton, btnName: "ic_favorite_border", color: UIColor.red)
        }
    }
}


