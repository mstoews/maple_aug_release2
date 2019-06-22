//
//  MainTabBarController.swift
//  InstagramFirebase
//
//  Created by Murray Toews on 6/3/17.
//  Copyright © 2017 maple.com

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseUI
import FBSDKLoginKit
import GoogleMaps
import GooglePlaces
import MaterialComponents
import Lightbox
import GoogleSignIn
import UserNotifications

private let kFirebaseTermsOfService = URL(string: "https://mapleon.com/terms/")!

protocol SharePhotoControllerDelegate  {
    func handleShareFromMain()
    func handleAddPlace()
}


class MainTabBarController: UITabBarController, AuthUIDelegate  {
    
    lazy var uid = Auth.auth().currentUser!.uid
    var notificationGranted = false
    let imageView = CustomImageView()
    
    var posts = [Post]()
    var observers = [DatabaseQuery]()
    lazy var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    deinit {
        listener?.remove()
    }
    
    private var listener: ListenerRegistration?
    
    fileprivate func observeNotifications()
    {
        stopObserving()
        
        if let uid = Auth.auth().currentUser?.uid {
            self.listener =
                Firestore.firestore().collection("users").document(uid).collection("events").whereField("deleted", isEqualTo: false)
                    //.whereField("deleted", isEqualTo: false)
                    .addSnapshotListener{  (snapshot, error) in
                        guard let snapshot = snapshot else {
                            print("Error fetching snapshot results: \(error!)")
                            return
                        }
                        let application = UIApplication.shared
                        let center = UNUserNotificationCenter.current()
                        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
                            // Enable or disable features based on authorization.
                        }
                        application.registerForRemoteNotifications()
                        application.applicationIconBadgeNumber = snapshot.count
                        self.setNotificationBadgeCount(count: snapshot.count)
                        
            }
        }
    }
    
    fileprivate func stopObserving() {
        listener?.remove()
    }
    
    @objc func setNotificationBadgeCount(count: Int)
    {
        if count == 0 {
            self.tabBar.items?[3].badgeValue = nil
            return
        }
        let strNotificationCount = "\(count)"
        self.tabBar.items?[3].badgeValue = strNotificationCount
    }
    
    func setTabBarHome() {
        tabBar.selectedItem = tabBar.items![0] as UITabBarItem
        tabBar.tintColor = UIColor.red
    }
    
    func showProfile(_ profile: MapleUser) {
        //performSegue(withIdentifier: "account", sender: profile)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        _ = viewControllers?.firstIndex(of: viewController)
        return true
    }
    
    
    let authUI: FUIAuth? = FUIAuth.defaultAuthUI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authUI?.delegate = self
        authUI?.tosurl = kFirebaseTermsOfService
        let providers: [FUIAuthProvider] = [FUIEmailAuth(), FUIGoogleAuth(), FUIFacebookAuth()]
        authUI?.providers = providers
        setupViewControllers()
        observeNotifications()
        
        UINavigationBar.appearance().prefersLargeTitles = true
        UINavigationBar.appearance().backgroundColor = UIColor.themeColor()
        UINavigationBar.appearance().alpha = CGFloat(0.1)
    
        
        tabBar.tintColor = UIColor.buttonThemeColor()
        
        //NotificationCenter.default.addObserver(self, selector: #selector(resetBadges), name: NSNotification.Name(rawValue : "Badge Changed"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isUserSignedIn() {
            showLoginView()
        }
        
        
    }
    
    let followersLabel: UILabel = {
        var label = UILabel()
        var iPosts = 0
        let strPosts = "\(iPosts)"
        let attributedText = NSMutableAttributedString(string: strPosts , attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        label.attributedText = attributedText
        print("Realtime Update Followers: ", Int32((iPosts)))
        return label
    }()
    
    
    lazy var FAB :  MDCFloatingButton = {
        let fb = MDCFloatingButton()
        return fb
    }()
    
    
    
    func setupViewControllers() {
        
        let homeNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "ic_home_white"), selectedImage: #imageLiteral(resourceName: "ic_home"), rootViewController: HomeController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        let searchNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "ic_search_white"), selectedImage: #imageLiteral(resourceName: "ic_search"), rootViewController: SearchAlgoliaCollectionView(collectionViewLayout: UICollectionViewFlowLayout()))
        
        
        // let searchNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "ic_search_white"), selectedImage: #imageLiteral(resourceName: "ic_search"), rootViewController: PodcastsSearchController())
        
        let sharePhotoNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"), rootViewController: ShareController())
        
        //let notificationNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "ic_favorite_border"), selectedImage: #imageLiteral(resourceName: "ic_favorite"), rootViewController: NotificationViewController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        let notificationNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "ic_notifications_white"), selectedImage: #imageLiteral(resourceName: "ic_notifications"), rootViewController: NotificationViewController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        
        let layout = UICollectionViewFlowLayout()
        let userProfileController = UserProfileController(collectionViewLayout: layout)
        let userProfileNavController = UINavigationController(rootViewController: userProfileController)
        userProfileNavController.tabBarItem.image = #imageLiteral(resourceName: "profile_unselected")
        userProfileNavController.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected")
        
        if let uid = Auth.auth().currentUser?.uid {
            Firestore.fetchUserWithUID(uid: uid) { (user) in
                userProfileController.user = user
            }
        }
        
        let plusImage = UIImage(named: "trending")?.withRenderingMode(.alwaysTemplate)
        let button = MDCFloatingButton()
        button.setImage(plusImage, for: .normal)
        //MDCFloatingActionButtonThemer.applyScheme(buttonScheme, to: button)
        
        tabBar.addSubview(button)
        
        button.anchor(top: tabBar.bottomAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 100, paddingRight: 10, width: 50, height: 50)
        
        
       
        
        viewControllers = [
            homeNavController,
            searchNavController,
            sharePhotoNavController,
            notificationNavController,
            userProfileNavController]
        
        guard let items = tabBar.items else { return }
        
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
        
        
    }
    
    
    
    fileprivate func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.tabBarController?.tabBar.tintColor = UIColor.themeColor()
        return navController
    }
}


extension MainTabBarController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        switch error {
        case .some(let error as NSError) where UInt(error.code) == FUIAuthErrorCode.userCancelledSignIn.rawValue:
            print("User cancelled sign-in")
        case .some(let error as NSError) where error.userInfo[NSUnderlyingErrorKey] != nil:
            print("Login error: \(error.userInfo[NSUnderlyingErrorKey]!)")
        case .some(let error):
            print("Login error: \(error.localizedDescription)")
        case .none:
            if let user = authDataResult?.user {
                signed(in: user)
            }
        }
    }
    
    private func isUserSignedIn() -> Bool {
        guard Auth.auth().currentUser != nil else {return false}
        return true
    }
    
    private func showLoginView(){
        if let authVC = FUIAuth.defaultAuthUI()?.authViewController() {
            present(authVC,animated: true, completion: nil)
        }
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return FPAuthPickerViewController(nibName: "FPAuthPickerViewController", bundle: Bundle.main, authUI: authUI)
    }
    
    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            //AppState.sharedInstance.signedIn = false
            dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError)")
        } catch {
            print("Unknown error.")
        }
    }
    
    func signed(in user: User) {
        Firestore.fetchUserWithUID(uid: user.uid, completion: { (user) in
            Firestore.updateUserProfile(user: user)
            let url = NSURL(fileURLWithPath: user.profileImageUrl)
            self.downloadImage(url: url as URL, user: user)
            self.savePhotoImage(user: user)
        })
    }
    
    func downloadImage(url: URL, user: MapleUser) {
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                self.imageView.image = UIImage(data: data)
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    func savePhotoImage(user: MapleUser)
    {
        //self.imageView.loadImage(urlString: (user.photoURL?.absoluteString)!)
        if let image = self.imageView.image {
            let size = CGSize(width: 320.0, height: 320)
            let uploadData = image.RBResizeImage(image: image, targetSize: size)
            
            let filename = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            let storeRef = Storage.storage().reference().child("profile_images").child(filename).child(filename)
            storeRef.putData(uploadData.sd_imageData()!, metadata: metadata) { (metadata, err) in
                if let err = err {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    print("Failed to upload post image:", err)
                    return
                }
                
                storeRef.downloadURL { (url, err)  in
                    if let err = err {
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        print("Failed to upload post image:", err)
                        return
                    }
                    if let url = url {
                        let values: [String: Any] = ["profileImageUrl": url]
                        Firestore.firestore().collection("users").document(user.uid).collection("profile").document(user.uid).updateData(values)
                    }
                }
            }
        }
    }
    
}






