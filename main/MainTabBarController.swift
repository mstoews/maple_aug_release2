//
//  MainTabBarController.swift
//  InstagramFirebase
//
//  Created by Murray Toews on 6/3/17.
//  Copyright © 2017 maple.com

import UIKit
import Firebase
import FirebaseUI

import FBSDKLoginKit
import GoogleMaps
import GooglePlaces
import MaterialComponents
import Lightbox
import GoogleSignIn

private let kFirebaseTermsOfService = URL(string: "https://mapleon.com/terms/")!

protocol SharePhotoControllerDelegate  {
    func handleShareFromMain()
    func handleAddPlace()
}


class MainTabBarController: UITabBarController, AuthUIDelegate  {
    
    lazy var uid = Auth.auth().currentUser!.uid
    var notificationGranted = false
    
    
    
    var floatingButtonOffset: CGFloat = 0.0
    var spinner: UIView?
    static let postsPerLoad: Int = 3
    static let postsLimit: UInt = 4
    var lightboxCurrentPage: Int?
    
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
    
    var query: DatabaseReference!
    var posts = [Post]()
    var loadingPostCount = 0
    var nextEntry: String?
    //var sizingCell: FPCardCollectionViewCell!
    let bottomBarView = MDCBottomAppBarView()
    var followingRef: DatabaseReference?
    let blue = MDCPalette.red
    var observers = [DatabaseQuery]()
    var newPost = false
    var followChanged = false
    var isFirstOpen = true
    lazy var database = Database.database()
    lazy var ref = self.database.reference()
    lazy var postsRef = self.database.reference(withPath: "posts")
    lazy var commentsRef = self.database.reference(withPath: "comments")
    lazy var likesRef = self.database.reference(withPath: "likes")
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
                Firestore.firestore().collection("users").document(uid).collection("Events")
                    .addSnapshotListener{  (snapshot, error) in
                        guard let snapshot = snapshot else {
                            print("Error fetching snapshot results: \(error!)")
                            return
                        }
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
        _ = viewControllers?.index(of: viewController)
        return true
    }
    
    
    let authUI: FUIAuth? = FUIAuth.defaultAuthUI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authUI?.delegate = self 
        authUI?.tosurl = kFirebaseTermsOfService
        authUI?.isSignInWithEmailHidden = false
        let providers: [FUIAuthProvider] = [FUIGoogleAuth(), FUIFacebookAuth()]
        authUI?.providers = providers
        
        observeNotifications()
        
        //NotificationCenter.default.addObserver(self, selector: #selector(resetBadges), name: NSNotification.Name(rawValue : "Badge Changed"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isUserSignedIn() {
            showLoginView()
        }
        setupViewControllers()
        
    }
    
    
   
    let followersLabel: UILabel = {
        var label = UILabel()
        var iPosts = 0
        let strPosts = "\(iPosts)"
        let attributedText = NSMutableAttributedString(string: strPosts , attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        label.attributedText = attributedText
        print("Realtime Update Followers: ", Int32((iPosts)))
        return label
    }()
    
    
    func setupViewControllers() {
        
        let homeNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "ic_home_white"), selectedImage: #imageLiteral(resourceName: "ic_home"), rootViewController: HomeController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        let searchNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "ic_search_white"), selectedImage: #imageLiteral(resourceName: "ic_search"), rootViewController: SearchAlgoliaCollectionView(collectionViewLayout: UICollectionViewFlowLayout()))        

        let sharePhotoNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"), rootViewController: SharePhotoController())

        //let notificationNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "ic_favorite_border"), selectedImage: #imageLiteral(resourceName: "ic_favorite"), rootViewController: NotificationViewController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        let notificationNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "ic_notifications_white"), selectedImage: #imageLiteral(resourceName: "ic_notifications"), rootViewController: NotificationViewController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        
        let layout = UICollectionViewFlowLayout()
        let userProfileController = UserProfileController(collectionViewLayout: layout)
        let userProfileNavController = UINavigationController(rootViewController: userProfileController)
        userProfileNavController.tabBarItem.image = #imageLiteral(resourceName: "profile_unselected")
        userProfileNavController.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected")
        
        if let uid = Auth.auth().currentUser?.uid {
            Database.fetchUserWithUID(uid: uid) { (user) in
                userProfileController.user = user
            }
        }
        
        tabBar.tintColor = UIColor.red
        
        viewControllers = [homeNavController,
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
 
        //Storage.storage()

        var values: [String: Any] = ["profileImageUrl": user.photoURL?.absoluteString ?? "",
                                     "username": user.displayName ?? "",
                                     "_search_index": ["full_name": user.displayName?.lowercased(),
                                                       "reversed_full_name": user.displayName?.components(separatedBy: " ")
                                                        .reversed().joined(separator: "")]]

        if notificationGranted {
            values["notificationEnabled"] = true
            notificationGranted = false
        }
        //database.reference(withPath: "users/\(user.uid)").updateChildValues(values)
        Firestore.firestore().collection("users").document(user.uid).collection("profile").document(user.uid).updateData(values)
    }
}






