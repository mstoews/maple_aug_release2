//
//  ProductController.swift
//  maple
//
//  Created by Murray Toews on 2018/05/23.
//  Copyright © 2018 Murray Toews. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseUI
//import FirebaseAuthUI
//import FirebaseInvites
import AlgoliaSearch
import InstantSearchCore
import Kingfisher
//import INSPhotoGallery
import GoogleSignIn
import GoogleToolboxForMac
import GoogleMaps
import GooglePlaces
import MaterialComponents


class ProductController: UICollectionViewController, ProductCellDelegate, ProductHeaderCardDelegate {
    
    
    func didShowTopUsers() {
    
    }
    
    func didTapModify(post: FSPost) {
        
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
            let activityController = UIActivityViewController(activityItems: [post.description] , applicationActivities: nil)
            present(activityController, animated: true, completion: nil)
        }
    }
    
    
    func didTapImage(for cell: PostImage, post: FSPost) {
        var photos: [PhotoViewModel] = []
        if post.largeUrlArray.count > 0 {
            for url in post.largeUrlArray {
                let pt = PhotoViewModel(imageURL: URL(string: url),thumbnailImageURL: URL(string: url))
                pt.caption = post.product + "\n" + post.description
                photos.append(pt)
            }
        }
        
        
        if post.largeUrlArray.count > 0 {
            var count : Int
            count = 0
            if post.imageUrlArray.count > 0 {
                for url in post.imageUrlArray {
                    photos[count].thumbnailImageURL = URL(string: url)
                    count = count + 1
                }
            }
        }
        else
        {
            if post.imageUrlArray.count > 0 {
                for url in post.imageUrlArray {
                    let pt = PhotoViewModel(imageURL: URL(string: url),thumbnailImageURL: URL(string: url))
                    pt.caption = post.product + "\n" + post.description
                    photos.append(pt)
                }
            }
        }
        //let currentPhoto = photos[0]
        //let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: cell)
        //present(galleryPreview, animated: true, completion: nil)
        
    }

    func didTapImageCell(for cell: UserImageCell, post: FSPost) {
        var photos: [PhotoViewModel] = []
        
        for url in post.imageUrlArray {
            let pt = PhotoViewModel(imageURL: URL(string: url),thumbnailImageURL: URL(string: url))
            pt.caption = post.product
            photos.append(pt)
        }
        
        //let currentPhoto = photos[0]
        //let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: cell)
        //present(galleryPreview, animated: true, completion: nil)
    }
    
    var headerViewController = MDCFlexibleHeaderViewController()
    
    //fileprivate var headerContentView = ProductHeaderContentView(frame: CGRect.zero)
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        addChildViewController(headerViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
         addChildViewController(headerViewController)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerViewController.scrollViewDidScroll(scrollView)
        let scrollOffsetY = scrollView.contentOffset.y
        let duration = 0.5
        var opacity: CGFloat = 1.0
        var logoTextImageViewOpacity: CGFloat = 0
        if scrollOffsetY > -240 {
            opacity = 0
            logoTextImageViewOpacity = 1
        }
//        UIView.animate(withDuration: duration, animations: {
//            self.headerContentView.scrollView.alpha = opacity
//            self.headerContentView.pageControl.alpha = opacity
//            self.headerContentView.logoImageView.alpha = opacity
//            self.headerContentView.logoTextImageView.alpha = logoTextImageViewOpacity
//        })
        
    }
    
    func sizeHeaderView() {
        let headerView = headerViewController.headerView
        let bounds = UIScreen.main.bounds
        if bounds.size.width < bounds.size.height {
            headerView.maximumHeight = 440
        } else {
            headerView.maximumHeight = 72
        }
        headerView.minimumHeight = 72
    }
    
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation,
                                      duration: TimeInterval) {
        sizeHeaderView()
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sizeHeaderView()
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func setupHeaderView() {
        let headerView = headerViewController.headerView
        headerView.trackingScrollView = collectionView
        headerView.maximumHeight = 440
        headerView.minimumHeight = 72
        headerView.minMaxHeightIncludesSafeArea = false
        headerView.backgroundColor = UIColor.white
        headerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        headerContentView.frame = (headerView.bounds)
//        headerContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        headerView.addSubview(headerContentView)
    }
    
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
    
    
    
    var FETCH_TYPE = FetchType.USER
    var docRef : DocumentReference!
    let db = Firestore.firestore()
    let productCellId = "productCellId"
    let productHeaderId = "productHeaderId"
    var placesClient: GMSPlacesClient!
    var numberOfLikes : Int?
    var locations = [LocationObject]()
    
    let locationManager = CLLocationManager()
    
    
    var posts = [FSPost]()
    let defaultStore = Firestore.firestore()
    
    
    var floatingButtonOffset: CGFloat = 0.0
    var spinner: UIView?
    static let postsPerLoad: Int = 5
    static let postsLimit: UInt = 4
    var lightboxCurrentPage: Int?
    
    var loadingPostCount = 0
    var nextEntry: String?
    let bottomBarView = MDCBottomAppBarView()
    var showFeed = true
    
    lazy var uid = Auth.auth().currentUser!.uid
    
    lazy var database = Database.database()
    lazy var ref = self.database.reference()
    
    lazy var postsRef    = self.database.reference(withPath: "posts")
    lazy var commentsRef = self.database.reference(withPath: "comments")
    lazy var likesRef    = self.database.reference(withPath: "likes")
    
    
    let red = MDCPalette.red.tint600
    var observers = [DatabaseQuery]()
    var newPost = false
    var followChanged = false
    var isFirstOpen = true
    
    var followingRef: DatabaseReference?
    
    let shareImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    var post: FSPost? {
        didSet {
            title =  "Post"
            
            if let postId = post?.id {
                
                let description = post?.description
                let product = post?.product
                //post?.imageUrlArray
                
                Database.fetchLocationByPostId(postId){ (locationObjects) in
                    for location in locationObjects {
                        self.locateWithLongitude(location, (self.post?.description)! , (self.post?.product)!)
                    }
                }
                
                
            }
        }
        
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
    
    private var fs_posts: [FSPost] = []
    private var documents: [DocumentSnapshot] = []
    
    fileprivate var query: Firebase.Query? {
        didSet {
            if let listener = listener {
                listener.remove()
                observeQuery()
            }
        }
    }
    
    private var listener: ListenerRegistration?
    
    fileprivate func observeQuery() {
        guard let query = query else { return }
        stopObserving()
        
        listener = query.addSnapshotListener { [unowned self] (snapshot, error) in
            
            guard let snapshot = snapshot else {
                print("Error fetching snapshot results: \(error!)")
                return
            }
            
            let models = snapshot.documents.map { (document) -> FSPost in
        
                document.data().forEach({ (key, value) in
                    guard let dictionary = value as? [String] else { return }
                    for url in dictionary {
                        print("Key: \(key) URL: \(url)")
                    }
                })
                
                if let model = FSPost(dictionary: document.data(), postId: document.documentID) {
                    return model
                } else {
                    // Don't use fatalError here in a real app.
                    fatalError("Unable to initialize type \(FSPost.self) with dictionary \(document.data())")
                }
            }
            self.fs_posts = models
            self.documents = snapshot.documents
            
            if self.documents.count > 0 {
                
            } else {
                
            }
            
            //self.tableView.reloadData()
        }
    }
    
    fileprivate func stopObserving() {
        listener?.remove()
    }
    
    fileprivate func baseQuery() -> Firebase.Query {
        // return Firestore.firestore().collection("posts").document("LCTj63lMjvWNP8d76NG").collection("thumbnail").limit(to: 50)
        return Firestore.firestore().collection("posts").order(by: "name").limit(to: 3)
    }
    
    
    func didTapUserNameLabel(uid: String) {
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        Database.fetchUserWithUID(uid: uid, completion: { (user) in
            userProfileController.user = user
            self.navigationController?.pushViewController(userProfileController, animated: true)
        })
    }
    
    
    func didShowFollowersPosts() {
        FETCH_TYPE = FetchType.ALL
        print("didShowFollowerPosts")
        fetchAllPosts()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        MDCSnackbarManager.setBottomOffset(bottomBarView.frame.height)
        //didShowFollowersPosts()
        //observeQuery()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObserving()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateFeedNotificationName, object: nil)
        collectionView?.backgroundColor = UIColor.collectionBackGround()
        collectionView?.register(ProductCell.self, forCellWithReuseIdentifier: productCellId)
        collectionView?.register(ProductHeaderCard.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: productHeaderId)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        setupNavigationItems()
        query = baseQuery()
        didShowFollowersPosts()
        
        headerViewController.view.frame = view.bounds
        view.addSubview(headerViewController.view)
        headerViewController.didMove(toParentViewController: self)
        
    }
    
    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    @objc func handleRefresh() {
        print("Handling refresh..")
        if (FETCH_TYPE == FetchType.ALL){
            fetchAllPosts()
        }
        else {
            FETCH_TYPE = FetchType.USER
            //fetchFollowingUserIds()
        }
    }
    
    
    func fetchAllPosts() {
        
        spinner = displaySpinner()
        posts.removeAll()
        cleanCollectionView()
        let myGroup = DispatchGroup()
        myGroup.enter()
        if (posts.count == 0){
            self.fetchPostsByUser()
            myGroup.leave()
        }
        myGroup.notify(queue: .main) {
            if let spinner = self.spinner {
                self.removeSpinner(spinner)
            }
        }
    }
    
    
    func updateFireStore (post: Post)
    {
        if let postid = post.id {
            let values : [String: Any] = [
                "name" : post.user.username,
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
    
    
    func didUploadUsersAglolia()
    {
        Database.fetchAllUser ( completion: { (users) in
            for user in users {
                let values : [String: Any] = [
                    "name" : user.username,
                    "profileImageUrl" :  user.profileImageUrl,
                    "creationDate": Date().timeIntervalSince1970
                ]
                AlgoliaManager.sharedInstance.users.addObject(values, withID: user.uid , completionHandler: { (content, error) -> Void in
                    if error == nil {
                        if let objectID = content!["objectID"] as? String {
                            print("Object ID: \(objectID)")
                        }
                    }
                })
            }
        })
        
    }
    
    
    func fetchPostsByUser() {
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userIdsDictionary = snapshot.value as? [String: Any] else { return }
            userIdsDictionary.forEach({(arg) in
                let (key, _) = arg
                Database.fetchUserWithUID(uid: key, completion: { (user) in
                    // Update FirebaseStore
                    //self.fetchPostByUserFromFireStore(user: user)
                    self.fetchPostsByUserAscendingFirestore(user: user)
                })
            })
        }) { (err) in
            print("Failed to fetch following user ids:", err)
        }
    }
    
    
    fileprivate func fetchPostsByUserAscendingFirestore(user: MapleUser)
    {
        db.collection("posts").limit(to: 50).order(by: "createDate").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                let models = querySnapshot?.documents.map { (document) -> FSPost in
                    if let model = FSPost(dictionary: document.data(), postId: document.documentID) {
                        return model
                    } else {
                        // Don't use fatalError here in a real app.
                        fatalError("Unable to initialize type \(FSPost.self) with dictionary \(document.data())")
                    }
                }
                self.fs_posts = models!
                self.documents = (querySnapshot?.documents)!
            }
            
            
            if self.documents.count > 0 {
                self.collectionView?.reloadData()
                self.collectionView?.backgroundView = nil
            }
            else
            {
                //self.collectionView?.backgroundView = self.backgroundView
            }
        }
    }

    
    
    func fetchFollowingUserIds(completion: @escaping ([String])->() ) {
        var userFollowing = [String]()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userIdsDictionary = snapshot.value as? [String: Any] else { return }
            userIdsDictionary.forEach({ (key, value) in
                print(key)
                userFollowing.append(key)
            })
            completion(userFollowing)
        }) { (err) in
            print("Failed to fetch following user ids:", err)
        }
    }
    
//    enum Result<T>{
//        case success(result: T)
//        case failure(error: Error)
//    }
//    
//    func wrap<T>(_ body: (@escaping (Result<T>) -> Void) throws -> Void) -> Promise<T>  {
//        return Promise { fulfill, reject in
//            try body { result in
//                switch result{
//                case .success(let result):
//                    fulfill(result)
//                    break
//                case .failure(let error):
//                    reject(error)
//                    break
//                }
//            }
//        }
//    }
//    
   
    func fetchChildWithUser ()
    {
        for post in self.posts {
            Database.fetchImageByUidPost(post.id!, post.uid) { (images) in
                for img in images {
                    print (img.url)
                }
            }
        }
    }
    
//    func getFirestorePostsByUserId(uid: String)
//    {
//        Database.fetchUserWithUID(uid: uid, completion: { (user) in
//            self.db.collection("maplefirebase/users/\(uid)")
//                .getDocuments() { (querySnapshot, err) in
//                    if let err = err {
//                        print("Error getting documents: \(err)")
//                    } else {
//                        for document in querySnapshot!.documents {
//                            let docData = document.data()
//                            //let post = Post(user : user , dictionary: docData)
//                            //self.posts.append(post)
//                            //print("\(document.documentID) => \(post)")
//                        }
//                    }
//            }
//        })
//    }
    
    internal func cleanCollectionView() {
        if collectionView!.numberOfItems(inSection: 0) > 0 {
            collectionView!.reloadSections([0])
        }
    }
    
    func setupNavigationItems() {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
        
        let rightImage = UIImage(named: "ic_person_add")?.withRenderingMode(.alwaysOriginal)
//        let rightButton = UIBarButtonItem(image: rightImage, style: .done , target: self, action: #selector(inviteTapped))
//        rightButton.tintColor = UIColor.themeColor()
//        navigationItem.rightBarButtonItem = rightButton
    }
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let approximateWidthOfBioTextView = view.frame.width
        let size = CGSize(width: approximateWidthOfBioTextView, height: 1000)
        let attributes = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: CGFloat(15))]
        let post = posts[indexPath.item]
        let estimatedFrame = NSString(string: post.description).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return CGSize(width: view.frame.width - 15 , height: estimatedFrame.height + view.frame.width - 45 )
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let cell : UICollectionViewCell = collectionView.cellForItem(at: indexPath as IndexPath)!
        if posts.count > 0 {
            let productPageController = ProductPageController()
            var index: Int
            index = indexPath.item
            productPageController.post = self.posts[index]
            navigationController?.pushViewController(productPageController, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productCellId, for: indexPath) as! ProductCell
        if (posts.count > 0 ){
            cell.post = posts[indexPath.item]
        }
        cell.delegate = self
        return cell
    }
    
//    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: productHeaderId, for: indexPath) as! ProductHeaderCard
//        header.delegate = self
//        return header
//    }
//    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(7, 1, 1, 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 40)
    }
    
    
    
    func didOptions()
    {
        let mapController = MapController()
        present(mapController, animated:  true, completion: nil)
    }
    
    func didModifyOptions(for cell: HomePostCell)
    {
        print("Did modify options")
    }
    
    func didTapComment(post: FSPost) {
        print("Message coming from home controller ... didTapComment")
        print(post.product)
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
   
    
//    func startHomeFeedLiveUpdaters() {
//        // Make sure we listen on each followed people's posts.
//        followingRef?.observe(.childAdded, with: { followingSnapshot in
//            // Start listening the followed user's posts to populate the home feed.
//            let followedUid = followingSnapshot.key
//            //var followedUserPostsRef: DatabaseQuery = self.database.reference(withPath: "people/\(followedUid)/posts")
//            var followedUserPostsRef: DatabaseQuery = self.database.reference(withPath: "posts/\(followedUid)")
//            if followingSnapshot.exists() && (followingSnapshot.value is String) {
//                followedUserPostsRef = followedUserPostsRef.queryOrderedByKey().queryStarting(atValue: followingSnapshot.value)
//            }
//            followedUserPostsRef.observe(.childAdded, with: { postSnapshot in
//                if postSnapshot.key != followingSnapshot.key {
//                    let updates = ["/feed/\(self.uid)/\(postSnapshot.key)": true,
//                                   "/people/\(self.uid)/following/\(followedUid)": postSnapshot.key] as [String: Any]
//                    self.ref.updateChildValues(updates)
//                }
//            })
//            self.observers.append(followedUserPostsRef)
//        })
//        // Stop listening to users we unfollow.
//        followingRef?.observe(.childRemoved, with: { snapshot in
//            // Stop listening the followed user's posts to populate the home feed.
//            let followedUserId: String = snapshot.key
//            self.database.reference(withPath: "people/\(followedUserId)/posts").removeAllObservers()
//        })
//    }
    
    
    
    func didTapBookmark(for cell: ProductCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        var post = self.posts[indexPath.item]
        print(post.product)
        if let postId = post.id {
            if let uid = Auth.auth().currentUser?.uid {
                
                if (post.hasBookmark == true) {
                    post.hasBookmark = false
                }
                else
                {
                    post.hasBookmark = true
                }
                let values = [post.uid : post.hasBookmark] as [String : Any]
                if (post.hasBookmark == true) {
                    Database.database().reference().child("posts").child(uid).child(postId).child("bookmark").updateChildValues(values) { (err, _) in
                        if let err = err {
                            print("Failed to bookmark post:", err)
                            return
                        }
                        post.hasBookmark = true
                        post.noOfBookMarks = post.noOfBookMarks + 1
                        print("Successfully bookmarked post.")
                    }
                } else {
                    let values = [post.uid : post.hasBookmark] as [String : Any]
                    Database.database().reference().child("posts").child(uid).child(postId).child("bookmark").updateChildValues(values) { (err, _) in
                        if let err = err {
                            print("Failed to bookmarked post:", err)
                            return
                        }
                        post.hasBookmark = false
                        //post.noOfBookMarks = post.noOfBookMarks - 1
                        if (post.noOfBookMarks < 0 ) {post.noOfBookMarks = 0 }
                        print("Successfully unbookmarked post.")
                    }
                    
                }
                
            }
        }
        
        self.posts[indexPath.item] = post
        self.collectionView?.reloadItems(at: [indexPath])
    }
    
    
    func didLike(for cell: ProductCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        var post = self.posts[indexPath.item]
        print(post.product)
        if let postId = post.id {
            if let uid = Auth.auth().currentUser?.uid {
                
                if (post.hasLiked == true) {
                    post.hasLiked = false
                }
                else
                {
                    post.hasLiked = true
                }
                let values = [post.uid : post.hasLiked] as [String : Any]
                if (post.hasLiked == true) {
                    Database.database().reference().child("likes").child(postId).child(uid).child("likes").updateChildValues(values) { (err, _) in
                        if let err = err {
                            print("Failed to like post:", err)
                            return
                        }
                        post.hasLiked = true
                        post.noOfLikes = post.noOfLikes + 1
                        print("Successfully liked post.")
                    }
                } else {
                    Database.database().reference().child("likes").child(postId).child(uid).child("likes").child(post.uid).removeValue() { (err, _) in
                        if let err = err {
                            print("Failed to like post:", err)
                            return
                        }
                        post.hasLiked = false
                        if post.noOfLikes > 0 {
                            post.noOfLikes = post.noOfLikes - 1
                        }
                        else
                        {
                            if (post.noOfLikes < 0 ) {post.noOfLikes = 0 }
                        }
                        print("Successfully unliked post.")
                    }
                    
                }
                
            }
        }
        
        self.posts[indexPath.item] = post
        self.collectionView?.reloadItems(at: [indexPath])
    }
}


