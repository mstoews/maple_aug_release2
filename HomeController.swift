//
//  HomeController.swift
//  InstagramFirebase
//
//  Created by Murray Toews on 6/3/17.
//  Copyright © 2017 maple.com

import UIKit
import Firebase
import FirebaseUI
import AlgoliaSearch
import InstantSearchCore
import Kingfisher
import Lightbox
import GoogleSignIn
import GoogleToolboxForMac
import MaterialComponents
import JGProgressHUD


enum  FetchType {
    case ALL
    case USER
}

class HomeController: MDCCollectionViewController, HomePostCellDelegate,  HomeHeaderCellDelegate {
    
    func didTapModify(post: FSPost) {
        print("Did tap modify ... ")
        let editPostController = PostViewerController()
        editPostController.post = post
        navigationController?.pushViewController(editPostController, animated: true)
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
    
    var FETCH_TYPE = FetchType.USER
    let db = Firestore.firestore()
    let cellId = "cellId"
    let cellHeaderId = "cellHeaderId"
    
    //var posts = [Post]()
    
    var spinner: UIView?
    static let postsPerLoad: Int = 5
    static let postsLimit: Int = 4
    
    var loadingPostCount = 0
    var nextEntry: String?
    let bottomBarView = MDCBottomAppBarView()
    var showFeed = true
    var refreshPageNationation = 20
    
    lazy var uid = Auth.auth().currentUser!.uid
    lazy var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let red = MDCPalette.red.tint600
    var observers = [DatabaseQuery]()
    var newPost = false
    var followChanged = false
    var isFirstOpen = true
    
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
    
    private var fs_posts: [FSPost] = []
    private var documents: [DocumentSnapshot] = []
    
    
    deinit {
        listener?.remove()
    }
    
    private var listener: ListenerRegistration?
    
    fileprivate func observeQuery()
    {
        stopObserving()
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Fetching Posts"
        hud.show(in: view)
        
        self.listener = self.db.collection("posts")
            .order(by: "creationDate", descending: true).limit(to: 60)
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
                
                self.fs_posts = models
                
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
    
    
    fileprivate func stopObserving() {
        listener?.remove()
    }
    
    func didShowTopPosts(){
        stopObserving()
        self.listener = self.db.collection("posts")
            .order(by: "creationDate", descending: false).limit(to: 5)
            .addSnapshotListener{  (snapshot, error) in
                guard let snapshot = snapshot else {
                    print("Error fetching snapshot results: \(error!)")
                    return
                }
                
                let models = snapshot.documents.map { (document) -> FSPost in
                    if let model = FSPost(dictionary: document.data(), postId: document.documentID) {
                        return model
                    }
                    else {
                        // Don't use fatalError here in a real app.
                        fatalError("Unable to initialize type \(FSPost.self) with dictionary \(document.data())")
                    }
                }
                
                self.fs_posts = models
                self.documents = snapshot.documents
                
                if self.documents.count > 0 {
                    //print("Number of posts: \(self.documents.count)")
                    self.collectionView?.backgroundView = nil
                    self.collectionView?.reloadData()
                }
                else
                {
                    self.collectionView?.backgroundView = nil
                }
                
        }
    }
    
    fileprivate func baseQuery() -> Firebase.Query {
        return db.collection("posts").limit(to: 50)
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
        Database.fetchUserWithUID(uid: uid, completion: { (user) in
            userProfileController.user = user
            self.navigationController?.pushViewController(userProfileController, animated: true)
        })
    }
    
    func didShowTopUsers() {
        FETCH_TYPE = FetchType.USER
        print("didShowTopUsers")
        didShowTopPosts()
    }
    
    func didShowFollowersPosts() {
        FETCH_TYPE = FetchType.ALL
        print("didShowFollowerPosts")
        observeQuery()
    }
    
    
    private let refreshControl = UIRefreshControl()
    
    
    override func viewDidAppear(_ animated: Bool) {
        MDCSnackbarManager.setBottomOffset(bottomBarView.frame.height)
        //observeQuery()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //stopObserving()
    }
    
    let backgroundView = UIImageView()
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "handleRefresh")
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: HomeController.updateFeedNotificationName, object: nil)
        collectionView?.backgroundColor = UIColor.collectionBackGround()
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(HomeHeaderCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: cellHeaderId)
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged )
        
        collectionView?.refreshControl = refreshControl
        collectionView?.backgroundView = nil
        //Firestore.updateDocCounts()
        setupNavigationItems()
        observeQuery()
        
        // didShowAllPosts()
        // didShowFollowersPosts()
        // sidUploadUsersAglolia()
        
    }
    
    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    @objc func handleRefresh() {
      refreshControl.beginRefreshing()
        
      refreshControl.endRefreshing()
    }
    
    
    func fetchAllPosts() {
        spinner = displaySpinner()
        //posts.removeAll()
        cleanCollectionView()
        let myGroup = DispatchGroup()
        myGroup.enter()
        //if (posts.count == 0){
        //     self.fetchPostsByUser()
        //     myGroup.leave()
        //}
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
    
    
    internal func cleanCollectionView() {
        if collectionView!.numberOfItems(inSection: 0) > 0 {
            collectionView!.reloadSections([0])
        }
    }
    
    func setupNavigationItems() {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
        
        let rightImage = UIImage(named: "ic_people")?.withRenderingMode(.alwaysOriginal)
        let rightButton = UIBarButtonItem(image: rightImage, style: .done , target: self, action: #selector(inviteTapped))
        rightButton.tintColor = UIColor.themeColor()
        navigationItem.rightBarButtonItem = rightButton
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let approximateWidthOfBioTextView = view.frame.width
        let size = CGSize(width: approximateWidthOfBioTextView, height: 1000)
        let attributes = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: CGFloat(15))]
        let post = fs_posts[indexPath.item]
        let estimatedFrame = NSString(string: post.description).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return CGSize(width: view.frame.width - 15 , height: estimatedFrame.height + view.frame.width - 45 )
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if fs_posts.count > 0 {
            return fs_posts.count
        }
        else
        {
            return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let cell : UICollectionViewCell = collectionView.cellForItem(at: indexPath as IndexPath)!
//        if fs_posts.count > 0 {
//            let fs_post = fs_posts[indexPath.item]
//            let  productController = ProductController(collectionViewLayout: UICollectionViewFlowLayout())
//            // todo
//            productController.post = fs_post
//            // navigationController?.pushViewController(productController, animated: true)
//        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        if (fs_posts.count > 0 ){
            cell.fs_post = fs_posts[indexPath.item]
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
        return UIEdgeInsetsMake(7, 1, 1, 1)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 40)
    }
    
    
    
    func didOptions()
    {
        //let mapController = MapController()
        //present(mapController, animated:  true, completion: nil)
    }
    
    func didModifyOptions(for cell: HomePostCell)
    {
        print("Did modify options")
        let editPostController = PostViewerController()
        editPostController.post = cell.fs_post
        navigationController?.pushViewController(editPostController, animated: true)
    }
    
    func didTapComment(post: FSPost) {
        print("Message coming from home controller ... didTapComment")
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    func didTapImage(for cell: PostImage, post: FSPost) {
        /* var photos: [PhotoViewModel] = []
        
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
       */
        
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
            present(controller, animated: true, completion: nil)
        }
       
    }
    
    func didTapBookmark(for cell: HomePostCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        var post = self.fs_posts[indexPath.item]
                 if (post.hasBookmark == true) {
                    post.hasBookmark = false
                    Firestore.didBookmarkedPost(post: post, didBookmark: false)
                }
                else
                {
                    post.hasBookmark = true
                    Firestore.didBookmarkedPost(post: post, didBookmark: true)
                }
        self.fs_posts[indexPath.item] = post
        self.collectionView?.reloadItems(at: [indexPath])
    }
    
    
    func didLike(for cell: HomePostCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        var post = self.fs_posts[indexPath.item]
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
        self.fs_posts[indexPath.item] = post
        self.collectionView?.reloadItems(at: [indexPath])
    }
}


extension HomeController: InviteDelegate, GIDSignInDelegate, GIDSignInUIDelegate {
    
    @objc func inviteTapped() {
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/userinfo.email", "https://www.googleapis.com/auth/userinfo.profile"]
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signInSilently()
    }
    
    func inviteFinished(withInvitations invitationIds: [String], error: Error?) {
        switch error {
        case .some(let error as NSError) where error.code == -1009:
            MDCSnackbarManager.show(MDCSnackbarMessage(text: error.localizedDescription))
        case .some(let error):
            print("Failed: \(error.localizedDescription)")
        case .none:
            print("\(invitationIds.count) invites sent")
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        switch error {
        case .some(let error as NSError) where error.code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue:
            GIDSignIn.sharedInstance().signIn()
        case .some(let error as NSError) where error.code == -1009:
            MDCSnackbarManager.show(MDCSnackbarMessage(text: error.localizedDescription))
        case .some(let error):
            print("Login error: \(error.localizedDescription)")
        case .none:
            if let invite = Invites.inviteDialog() {
                invite.setInviteDelegate(self)
                // NOTE: You must have the App Store ID set in your developer console project
                // in order for invitations to successfully be sent.
                // A message hint for the dialog. Note this manifests differently depending on the
                // received invitation type. For example, in an email invite this appears as the subject.
                invite.setMessage("Try this out!\n -\(Auth.auth().currentUser!.displayName ?? "")")
                // Title for the dialog, this is what the user sees before sending the invites.
                //invite.setCustomImage(#imageLiteral(resourceName: "ic_insert_photo_white").imageAsset.)
                invite.setTitle("Maple")
                invite.setDeepLink("app_url")
                invite.setCallToActionText("Install!")
                invite.open()
            }
        }
    }
}


