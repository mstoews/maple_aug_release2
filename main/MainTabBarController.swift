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



protocol SharePhotoControllerDelegate  {
    func handleShareFromMain()
    func handleAddPlace()
}


class MainTabBarController: UITabBarController, UITabBarControllerDelegate, SharePhotoDelegate  {
    
    lazy var uid = Auth.auth().currentUser!.uid
    
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
    
    

    
    private func observeBadges(ObserveChild : String, BarItem : Int, StartAt: Int) -> Int
    {
        var iCount = StartAt
        if let uid = Auth.auth().currentUser?.uid {
            //let uid = "ygyHgVCY5BPfSsIr98O5c1hxtsK2"
            
            Database.fetchNotification(uid: uid) { message in
                if message == "success" {
                    iCount = notifications.count
                    if iCount > 0 {
                        let strComments = "\(iCount)\n"
                        self.tabBar.items?[BarItem].badgeValue = strComments
                    }
                    else
                    {
                        self.tabBar.items?[3].badgeValue = nil
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue : "Got Values"), object: nil)
                }
            }
        }
        
        return iCount
    }
    
    @objc func resetBadges() {
        let iNoticifations = notifications.count
        if iNoticifations > 0 {
            let strComments = "\(iNoticifations)\n"
            self.tabBar.items?[3].badgeValue = strComments
        }
        else
        {
            self.tabBar.items?[3].badgeValue = nil
        }
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetBadges), name: NSNotification.Name(rawValue : "Badge Changed"), object: nil)
        // Open the FUIAuthentication window rather than the current one.
        
        var Count = 0
        Count = observeBadges(ObserveChild: "likes", BarItem: 3 , StartAt: Count)
        
        if let currentUser  = Auth.auth().currentUser {
            self.uid = currentUser.uid
            setupViewControllers()
        }
        else
        {
            let authViewController = FUIAuth.defaultAuthUI()?.authViewController()
            authViewController?.navigationBar.isHidden = true
            self.present(authViewController!, animated: true, completion: nil)
            return
        }
        resetBadges()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let currentUser = Auth.auth().currentUser  {
            self.uid = currentUser.uid
            self.followingRef = database.reference(withPath: "people/\(uid)/following")
        } else {
            let authViewController = FUIAuth.defaultAuthUI()?.authViewController()
            authViewController?.navigationBar.isHidden = true
            self.present(authViewController!, animated: true, completion: nil)
            return
        }
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




