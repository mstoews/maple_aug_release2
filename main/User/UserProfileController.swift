//
//  UserProfileController.swift
//  InstagramFirebase
//
//  Created by Murray Toews on 6/3/17.
//  Copyright © 2017 maple.com

import UIKit
import Firebase
import FirebaseUI
import Photos
import VideoToolbox
import FBSDKLoginKit
import GoogleMaps
import GooglePlaces
import Kingfisher
import INSPhotoGallery
import MaterialComponents


enum  CellType {
    case GRID
    case LIST
    case BKMK
    case MAP
}

class UserProfileController: MDCCollectionViewController,
    UserProfileHeaderDelegate,
    ChangeSignPhotoControllerDelegate,
    UserGridPostCellDelegate
{

    let db = Firestore.firestore()
    let cellId = "cellId"
    let userGridCellId = "userGridCellId"
    let userListCellId = "userListCellId"
    let mapViewCell = "mapViewCell"
    let userBookmarkCellId = "userBookmarkCellId"
    let headerCellId = "headerCellId"
    
    lazy var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
   
    var userId: String?
    //var posts = [Post]()
   
    private var fs_posts: [FSPost] = []
    private var documents: [DocumentSnapshot] = []
    
    private var fs_locations : [LocationObject] = []
    private var locationDoc : [DocumentSnapshot] = []
    
    
    var isGridView = true
    var isMapView = false
    var isFavoritesView = false
    var isCurrentUser = true
    var  cellType = CellType.GRID
    
    var isFinishedPaging = false
    
    let database = Database.database()
    let ref = Database.database().reference()
    var postIds: [String: Any]?
    var postSnapshots = [DataSnapshot]()
    var loadingPostCount = 0
    var firebaseRefs = [DatabaseReference]()
    var insets: UIEdgeInsets!
    
    var user: MapleUser?
    var profile: MapleUser!
    //let uid = Auth.auth().currentUser!.uid
    
    
    deinit {
        stopObserving()
        stopBookMarkObserving()
    }
    
    private var listener: ListenerRegistration?
    private var bookMarkListener: ListenerRegistration?
    
    fileprivate func observeQuery(uid : String)
    {
        stopObserving()
        
        self.listener = self.db.collection("posts")
            .whereField("uid", isEqualTo: uid)
            .order(by: "creationDate", descending: true)
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
                }
                else
                {
                    self.collectionView?.backgroundView = nil
                }
                self.collectionView?.reloadData()
        }
    }
    
    
    // bookmarks should be recorded under the user collection as they are particular to the user rather than the post.
    //
    
    fileprivate func observeBookmarkedPosts(uid : String)
    {
        stopBookMarkObserving()
        
        self.bookMarkListener = self.db.collection("posts")
            .document("bookmarked")
            .collection(uid)
            .whereField("uid", isEqualTo: "test")
            .addSnapshotListener{  (snapshot, error) in
                guard let snapshot = snapshot else {
                    print("Error fetching snapshot results: \(error!)")
                    return
                }
                
                let models = snapshot.documents.map { (document) -> FSPost in
                    print(document)
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
                }
                else
                {
                    self.collectionView?.backgroundView = nil
                }
                self.collectionView?.reloadData()
        }
    }
    
    
    
    fileprivate func stopObserving() {
        listener?.remove()
    }
   
    
    fileprivate func stopBookMarkObserving() {
        bookMarkListener?.remove()
    }
    

  
    func didTapBookmark(for cell: UserGridPostCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        var post = self.fs_posts[indexPath.item]
        if let postId = post.id {
            if let uid = Auth.auth().currentUser?.uid {
                
                if (post.hasBookmark == true) {
                    post.hasBookmark = false
                    Firestore.didBookmarkedPost(postId: postId, uidLiked: uid, didLike: post.hasBookmark)
                }
                else
                {
                    post.hasBookmark = true
                    Firestore.didBookmarkedPost(postId: postId, uidLiked: uid, didLike: post.hasBookmark)
                }
            }
        }
        self.fs_posts[indexPath.item] = post
        self.collectionView?.reloadItems(at: [indexPath])
    }
    
    
    func didLike(for cell: UserGridPostCell) {
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
    
    
    func didTapImageCell(for cell: UserImageCell, post: FSPost) {

        var photos: [PhotoViewModel] = []

        if post.largeUrlArray.count > 0 {
            for url in post.largeUrlArray {
                let pt = PhotoViewModel(imageURL: URL(string: url),thumbnailImageURL: URL(string: url))
                pt.caption = post.product  + "\n" + post.description
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
        let currentPhoto = photos[0]
        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: cell)
        present(galleryPreview, animated: true, completion: nil)
        
    }
    
    func didTapImage(for cell: PostImage, post: FSPost) {
        
    }
    
    
    func didTapImage(post: Post) {
    
    }

    func didTapComment(post: FSPost) {
        print("Message coming from home controller ... didTapComment")
        print(post.product)
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    
    func didTapModify(post: FSPost) {
        if let postId = post.id {
            deletePost(postId: postId)
            fetchUser()
        }
    }
    
    
    func didTapImage(for cell: PostImage, post: Post) {
         print ("didTapImage")
    }
    
    func didSharePost(post: FSPost, imageObject: ImageObject) {
         print ("didSharePost")
    }
    
    func didTapUserNameLabel(uid: String) {
         print ("didTapUserNameLabel")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.collectionBackGround()
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerCellId)
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(UserGridPostCell.self, forCellWithReuseIdentifier: userGridCellId)
        collectionView?.register(UserListPostCell.self, forCellWithReuseIdentifier: userListCellId)
        collectionView?.register(MapViewCell.self, forCellWithReuseIdentifier: mapViewCell)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
               
        setupSettingsButton()
        fetchUser()
    }
    
    @objc func handleRefresh()
    {
        //fetchUser()
    }
    
    // MARK :  SharePhotoControllerUpdateDelegate.refreshUsers()
    
    func refeshUsers() {
        // Post is already deleted so just refresh the screen
        fetchUser()
    }

    func didChangeSignUpPhoto()
    {
        print("didChangeSignUpdate")
        if let uid = Auth.auth().currentUser?.uid {
            Database.fetchUserWithUID(uid: uid) { (user) in
                self.user = user
                self.navigationItem.title = (self.user?.username)!
                self.isCurrentUser = true
                
            }
        }
    }
    
    
    fileprivate func fetchUser() {
        fs_posts.removeAll()
        if let uid = Auth.auth().currentUser?.uid {
            if let userid = self.user?.uid {
                if userid != uid {
                    Database.fetchUserWithUID(uid: userid) { (user) in
                        self.user = user
                        self.navigationItem.title = "User Page"
                        self.isCurrentUser = false
                        self.observeQuery(uid: user.uid)
                    }
                } else {
                    Database.fetchUserWithUID(uid: uid) { (user) in
                        self.user = user
                        self.navigationItem.title = (self.user?.username)!
                        self.observeQuery(uid: user.uid)
                        self.isCurrentUser = true
                    }
                }
            }
        }
    }
    
    @objc func didChangeSignUpFoto()
    {
        print ("didChangeSignFoto")
        let changePhotoSelectorController = ChangeSignPhotoController()
        //handleLogOut()
        if let profileImageUrl = user?.profileImageUrl {
            changePhotoSelectorController.profileImageView.loadImage(urlString: profileImageUrl)
            changePhotoSelectorController.plusPhotoButton.setImage( changePhotoSelectorController.profileImageView.image?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        changePhotoSelectorController.delegate = self
        
        let backItem = UIBarButtonItem(title: "", style: .bordered, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        let transition = CATransition()
        transition.duration = 0.75
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.view.layer.add(transition, forKey: nil)
        _ = self.navigationController?.popToRootViewController(animated: false)
        
        navigationController?.pushViewController(changePhotoSelectorController, animated: true)
    }
    
    
    
    
    @objc func didEditPost() {
        setTransition()
        //deletePost(postId: <#T##String#>)
        //let sharePhotoController = SharePhotoController(collectionViewLayout: UICollectionViewFlowLayout())
        //let sharePhotoController = SharePhotoController()
        //]sharePhotoController.shareDelegate = self
        //navigationController?.pushViewController(sharePhotoController, animated: true)
    }
    
   
    func didChangeToListView() {
        print("didChangeToListView")
        cellType = CellType.LIST
        observeQuery(uid: user!.uid)
        collectionView?.reloadData()
    }
    
    func didChangeToGridView() {
        print("didChangeToGridView")
        cellType = CellType.GRID
        observeQuery(uid: user!.uid)
        collectionView?.reloadData()
    }
    
    // Open the map window called from the UserProfileHeader
    func didMapViewOpen()
    {
        print("didMapViewOpen")
        cellType = CellType.MAP
        fetchMapMarkers()
        collectionView?.reloadData()
    }

    
    func fetchLocations()
    {
        fs_locations.removeAll()
        let uid = Auth.auth().currentUser!.uid
        Firestore.fetchLocationByUserId( uid: uid) { (locObj) in
            for location in locObj {
                self.fs_locations.append(location)
            }
        }
        
        if self.fs_locations.count > 0 {
            self.collectionView?.reloadData()
            self.collectionView?.backgroundView = nil
        }
    }
    
    func fetchMapMarkers()
    {
       guard let uid = Auth.auth().currentUser?.uid else { return }
        fs_locations.removeAll()
        
        db.collection("location").whereField("uid", isEqualTo: uid).getDocuments()  { (snapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                let models = snapshot?.documents.map { (document) -> LocationObject in
                    if let model = LocationObject(dictionary: document.data()) {
                        return model
                    } else {
                        // Don't use fatalError here in a real app.
                        fatalError("Unable to initialize type \(self.fs_locations) with dictionary \(document.data())")
                    }
                }
                self.fs_locations = models!
                self.documents = (snapshot?.documents)!
            }
            
            if self.fs_locations.count > 0 {
                self.collectionView?.reloadData()
                self.collectionView?.backgroundView = nil
            }
            else
            {
                self.collectionView?.reloadData()
                self.collectionView?.backgroundView = nil
            }
        }
        
    }
    
    // Open the favourites window called from the UserProfileHeader
    func didFavoritesOpen()
    {
        print("didFavouriteOpen")
        cellType = CellType.BKMK
        //fetchBookmarkedPosts()
        observeBookmarkedPosts(uid: user!.uid)
        collectionView?.reloadData()
    }
    
    func setTransition(){
        
        let backItem = UIBarButtonItem(title: "Back", style: .bordered, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        let transition = CATransition()
        transition.duration = 0.75
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.navigationController?.view.layer.add(transition, forKey: nil)
        _ = self.navigationController?.popToRootViewController(animated: false)
    }
    
    
    func didOpenFollowersList() {
        // This is followERS!
        setTransition()
        let userController = UserFollowersController(collectionViewLayout: UICollectionViewFlowLayout())
        userController.user = user 
        navigationController?.pushViewController(userController, animated: true)
    }
    
    func didOpenFollowingList() {
        setTransition()
        let userController = UserFollowingController(collectionViewLayout: UICollectionViewFlowLayout())
        userController.user = user
        navigationController?.pushViewController(userController, animated: true)
        
    }
    
    func didOpenProductsList() {
        setTransition()
        let userController = UserFollowingController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController?.pushViewController(userController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setTransition()
        let editPostController = EditPostController()
        let index = indexPath.item
        editPostController.post = self.fs_posts[index]
        navigationController?.pushViewController(editPostController, animated: false)
    }
    

    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 0, 5)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    fileprivate func setupSettingsButton() {
        //guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        //guard let userId = user?.uid else { return }
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_settings").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(didChangeSignUpFoto))
      
    }
    
    func deletePost(postId: String)
    {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Delete Current Post", style: .default, handler: { (_) in
            do {
                 Firestore.deletePost(postId: postId)
            } catch let signOutErr {
                print("Failed to sign out:", signOutErr)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func handleLogOut() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Log Out", style: .default, handler: { (_) in
            do {
                
                //self.appDelegate.signOut()
                do {
                    try Auth.auth().signOut()
                } catch {
                }
                //self.appDelegate.signOut()
                self.navigationController?.popToRootViewController(animated: false)
                
                let authViewController = FUIAuth.defaultAuthUI()?.authViewController()
                authViewController?.navigationBar.isHidden = true
                self.present(authViewController!, animated: true, completion: nil)
                
                //let loginController = LoginController()
                //let navController = UINavigationController(rootViewController: loginController)
                //self.present(navController, animated: true, completion: nil)
                
            } catch let signOutErr {
                print("Failed to sign out:", signOutErr)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var rc = 0
        switch cellType
        {
            case CellType.BKMK :
                rc = fs_posts.count
                break
       
            case CellType.GRID :
                rc = fs_posts.count
                break
            
            case CellType.LIST:
                rc = fs_posts.count
                break
            
            case CellType.MAP :
                rc = fs_locations.count
                break
            }
        
        return rc
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var rc  = collectionView.dequeueReusableCell(withReuseIdentifier: userGridCellId, for: indexPath)
        switch cellType
        {
            case CellType.BKMK :
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userGridCellId, for: indexPath) as! UserGridPostCell
                cell.post = fs_posts[indexPath.item]
                cell.delegate = self
                rc = cell
                break
            
            case CellType.GRID :
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userGridCellId, for: indexPath) as! UserGridPostCell
                if (fs_posts.count > 0 ){
                    cell.post = fs_posts[indexPath.item]
                     cell.delegate = self
                }
                rc = cell
                break
          
          case CellType.LIST :
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userListCellId, for: indexPath) as! UserListPostCell
            if (fs_posts.count > 0 ){
                cell.post = fs_posts[indexPath.item]
                cell.delegate = self
            }
            rc = cell
            break
            
            case CellType.MAP :
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: mapViewCell, for: indexPath) as! MapViewCell
                if (fs_locations.count > 0 ){
                    cell.mapLocation = fs_locations
                }
                rc = cell
                break
        }
        return rc
    }
    
    
    var headerView: UserProfileHeader?
    var selectedImage: UIImage?
    
    var images = [UIImage]()
    var assets = [PHAsset]()
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        
        let cell : UICollectionViewCell = collectionView.cellForItem(at: indexPath as IndexPath)!
        cell.backgroundColor = UIColor.magenta
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath  indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : UICollectionViewCell = collectionView.cellForItem(at: indexPath as IndexPath)!
        cell.backgroundColor = UIColor.magenta
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerCellId , for: indexPath) as! UserProfileHeader
        if indexPath.section == 0 {
            header.inkView.removeFromSuperview()
            headerView = header
            headerView?.userView = self.user
            headerView?.delegate = self
//            if profile.uid == uid {
//                header.editProfileFollowButton.isHidden = true
//                header.editProfileFollowedButton.isHidden = true
//             } else {
//                header.editProfileFollowButton.isHidden = false
//                header.editProfileFollowedButton.isHidden = false
//            }
            //header.profileImageView.sd_setImage(with: NSURL(profile.profileImageUrl), completed: nil)
            return header
        }
        header.userView = self.user
        header.delegate = self
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var rc = CGSize()
        switch cellType
        {
        case CellType.GRID :
            //let width = view.frame.width
            let approximateWidthOfBioTextView = view.frame.width
            let size = CGSize(width: approximateWidthOfBioTextView, height: 1200)
            let attributes = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: CGFloat(15))]
            let post = fs_posts[indexPath.item]
            let estimatedFrame = NSString(string: post.description).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            rc = CGSize(width: view.frame.width - 15 , height: estimatedFrame.height + view.frame.width - 60 )
            break
            
        case CellType.LIST  :
            //let width = view.frame.width
            let approximateWidthOfBioTextView = view.frame.width
            let size = CGSize(width: approximateWidthOfBioTextView, height: 1200)
            let attributes = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: CGFloat(15))]
            let post = fs_posts[indexPath.item]
            let estimatedFrame = NSString(string: post.description).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            rc = CGSize(width: view.frame.width - 15, height: estimatedFrame.height + view.frame.width - 180 )
            break
   
        case CellType.MAP :
            let width = view.frame.width
            let height = view.frame.height
            rc = CGSize(width: width, height: height)
            break
            
        case CellType.BKMK :
            let approximateWidthOfBioTextView = view.frame.width
            let size = CGSize(width: approximateWidthOfBioTextView, height: 1200)
            let attributes = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: CGFloat(15))]
            let post = fs_posts[indexPath.item]
            let estimatedFrame = NSString(string: post.description).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            rc = CGSize(width: view.frame.width - 15 , height: estimatedFrame.height + view.frame.width - 60 )
            break
        }
        return rc
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
}






