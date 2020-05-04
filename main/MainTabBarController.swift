//
//  MainTabBarController.swift
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
import JGProgressHUD

private let kFirebaseTermsOfService = URL(string: "https://mapleon.com/terms/")!

protocol SharePhotoControllerDelegate  {
    func handleShareFromMain()
    func handleAddPlace()
}

func globalContainerScheme() -> ApplicationScheme {
    let containerScheme = ApplicationScheme()
    return containerScheme
}



class MainTabBarController: UITabBarController, MDCBottomNavigationBarDelegate, AuthUIDelegate  {
    
    lazy var uid = Auth.auth().currentUser!.uid
    var notificationGranted = false
    let imageView = CustomImageView()
    fileprivate let hud = JGProgressHUD(style: .dark)
    
    let containerScheme = globalContainerScheme()
    
    let layout = UICollectionViewFlowLayout()
    lazy var userProfileController = UserProfileController (collectionViewLayout: layout).self
    
    var posts = [Post]()
    var observers = [DatabaseQuery]()
    lazy var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    deinit {
        listener?.remove()
    }
    
    private var listener: ListenerRegistration?
    
    let bottomNavBar = MDCBottomNavigationBar()
    override func viewDidLoad() {
        view.backgroundColor = containerScheme.colorScheme.backgroundColor
        let tabBarItem1 = UITabBarItem(title: "Home", image: UIImage(named: "ic_home"), tag: 0)
        let tabBarItem2 = UITabBarItem(title: "Search", image: UIImage(named: "ic_search"), tag: 1)
        let tabBarItem3 = UITabBarItem(title: "Post", image: UIImage(named: "plus_unselected"), tag: 2)
        let tabBarItem4 = UITabBarItem(title: "Updates", image: UIImage(named: "ic_notifications"), tag: 3)
        let tabBarItem5 = UITabBarItem(title: "Profile", image: UIImage(named: "ic_person"), tag: 4)
        // tabBarItem3.selectedImage = UIImage(named: "Favorite")
        bottomNavBar.items = [ tabBarItem1, tabBarItem2, tabBarItem3, tabBarItem4, tabBarItem5 ]
        
        let containerScheme = MDCContainerScheme()
     
        // Either Primary Theme
       // bottomNavBar.applyPrimaryTheme(withScheme: containerScheme)

        // Or Surface Theme
        containerScheme.colorScheme.primaryColor = UIColor.buttonThemeColor()
        bottomNavBar.applySurfaceTheme(withScheme: containerScheme)
        
        bottomNavBar.selectedItem = tabBarItem1
        view.addSubview(bottomNavBar)
        bottomNavBar.delegate = self
        
        
//        let homeNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "ic_home_white"), selectedImage: #imageLiteral(resourceName: "ic_home"), rootViewController: HomeController(collectionViewLayout: UICollectionViewFlowLayout()))
//
//
//        viewControllers = [homeNavController]
        
        authUI?.delegate = self
        authUI?.tosurl = kFirebaseTermsOfService
        
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://example.appspot.com")
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setAndroidPackageName("com.firebase.example", installIfNotAvailable: false, minimumVersion: "12")
        
        let provider = FUIEmailAuth(authAuthUI: FUIAuth.defaultAuthUI()!,
                                    signInMethod: EmailLinkAuthSignInMethod,
                                    forceSameDevice: false,
                                    allowNewEmailAccounts: true,
                                    actionCodeSetting: actionCodeSettings)
        
        let providers: [FUIAuthProvider] = [provider, FUIGoogleAuth(), FUIFacebookAuth()]
        authUI?.providers = providers
        setupViewControllers()
        //observeNotifications()
        
     }
    
    func layoutBottomNavBar() {
          let size = bottomNavBar.sizeThatFits(view.bounds.size)
           var bottomNavBarFrame = CGRect(x: 0,
                                          y: view.bounds.height - size.height,
                                          width: size.width,
                                          height: size.height)
        if #available(iOS 11.0, *) {
          bottomNavBarFrame.size.height += view.safeAreaInsets.bottom
          bottomNavBarFrame.origin.y -= view.safeAreaInsets.bottom
        }
        bottomNavBar.frame = bottomNavBarFrame
           bottomNavBar.frame = bottomNavBarFrame
       }
       override func viewWillLayoutSubviews() {
           super.viewWillLayoutSubviews()
           layoutBottomNavBar()
       }
    
    fileprivate func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
//        navController.tabBarItem.image = unselectedImage
//        navController.tabBarItem.selectedImage = selectedImage
//        navController.tabBarItem.selectedImage?.withTintColor( containerScheme.colorScheme.primaryColor)
//        navController.tabBarController?.tabBar.tintColor =  containerScheme.colorScheme.primaryColor
//        navController.tabBarController?.tabBar.backgroundColor = containerScheme.colorScheme.primaryColor
        return navController
    }
    
    func bottomNavigationBar(_ bottomNavigationBar: MDCBottomNavigationBar, didSelect item: UITabBarItem){
        guard let fromView = selectedViewController?.view, let toView = customizableViewControllers?[item.tag].view else {
            return
        }
        
        if fromView != toView {
            UIView.transition(from: fromView, to: toView, duration: 0.3, options: [.transitionCrossDissolve], completion: nil)
        }
        self.selectedIndex = item.tag
    }
    
//    func layoutBottomNavBar() {
//        let size = bottomNavBar.sizeThatFits(view.bounds.size)
//        let bottomNavBarFrame = CGRect(x: 0,
//                                       y: view.bounds.height - size.height,
//                                       width: size.width,
//                                       height: size.height)
//        bottomNavBar.frame = bottomNavBarFrame
//    }
    
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
    }
    
    func showProfile(_ profile: MapleUser) {
        //performSegue(withIdentifier: "account", sender: profile)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        _ = viewControllers?.firstIndex(of: viewController)
        return true
    }
    
    
    let authUI: FUIAuth? = FUIAuth.defaultAuthUI()
    
    
    //    override func viewDidLoad() {
    //        super.viewDidLoad()
    //
    //        authUI?.delegate = self
    //        authUI?.tosurl = kFirebaseTermsOfService
    //
    //        let actionCodeSettings = ActionCodeSettings()
    //        actionCodeSettings.url = URL(string: "https://example.appspot.com")
    //        actionCodeSettings.handleCodeInApp = true
    //        actionCodeSettings.setAndroidPackageName("com.firebase.example", installIfNotAvailable: false, minimumVersion: "12")
    //
    //        let provider = FUIEmailAuth(authAuthUI: FUIAuth.defaultAuthUI()!,
    //                                    signInMethod: EmailLinkAuthSignInMethod,
    //                                    forceSameDevice: false,
    //                                    allowNewEmailAccounts: true,
    //                                    actionCodeSetting: actionCodeSettings)
    //
    //        let providers: [FUIAuthProvider] = [provider, FUIGoogleAuth(), FUIFacebookAuth()]
    //        authUI?.providers = providers
    //        setupViewControllers()
    //        observeNotifications()
    //
    //        UINavigationBar.appearance().prefersLargeTitles = false
    //
    //        //NotificationCenter.default.addObserver(self, selector: #selector(resetBadges), name: NSNotification.Name(rawValue : "Badge Changed"), object: nil)
    //    }
    
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
    
    
    func setUserProfile() {
        if let uid = Auth.auth().currentUser?.uid {
            Firestore.fetchUserWithUID(uid: uid) { (user) in
                self.userProfileController.user = user
                self.userProfileController.didChangeSignUpPhoto()
            }
        }
    }
    
    func setupViewControllers() {
        
        let homeNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "ic_home_white"), selectedImage: #imageLiteral(resourceName: "ic_home"), rootViewController: HomeController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        let searchNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "ic_search_white"),
                                                        selectedImage: #imageLiteral(resourceName: "ic_search"),
                                                        rootViewController: SearchAlgoliaCollectionView(collectionViewLayout: CollectionLayout()))
        
        let sharePhotoNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"), rootViewController: ShareController())
        
        let notificationNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "ic_notifications_white"), selectedImage: #imageLiteral(resourceName: "ic_notifications"), rootViewController: NotificationViewController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        
        let userProfileNavController = UINavigationController(rootViewController: userProfileController)
     userProfileNavController.tabBarItem.image = #imageLiteral(resourceName: "profile_unselected")
        userProfileNavController.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected")
        
        setUserProfile()
        
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
    
    fileprivate func setUser(){
        
    }
    
    
    
}


extension MainTabBarController: FUIAuthDelegate, LoginControllerDelegate {
    func didFinishLoggingIn() {
        fetchCurrentUser()
    }
    
    
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
    
    fileprivate func fetchCurrentUser() {
        hud.textLabel.text = "Loading"
        hud.show(in: view)
        Firestore.firestore().fetchCurrentUser { (user, err) in
            if let err = err {
                print("Failed to fetch user:", err)
                self.hud.dismiss()
                return
            }
        }
        self.hud.dismiss()
    }
    
    private func showLoginView(){
        print("MainTabBarController did appear")
        // you want to kick the user out when they log out
        if Auth.auth().currentUser == nil {
            let loginController = LoginController()
            loginController.delegate = self
            let navController = UINavigationController(rootViewController: loginController)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        }
        
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return FPAuthPickerViewController(nibName: "FPAuthPickerViewController", bundle: Bundle.main, authUI: authUI)
    }
    
    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError)")
        } catch {
            print("Unknown error.")
        }
    }
    
    func signed(in user: Firebase.User) {
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






