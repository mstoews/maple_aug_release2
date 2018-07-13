import Firebase
import FirebaseUI
import GoogleSignIn
import MaterialComponents
import UserNotifications
import GoogleMaps
import GooglePlaces

private let kFirebaseTermsOfService = URL(string: "https://mapleon.com/terms/")!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let mdcMessage = MDCSnackbarMessage()
    let mdcAction = MDCSnackbarMessageAction()
    var window: UIWindow?
    lazy var database = Database.database()
    var blockedRef: DatabaseReference!
    var blockingRef: DatabaseReference!
    let gcmMessageIDKey = "gcm.message_id"
    var notificationGranted = false
    var blocked = Set<String>()
    var blocking = Set<String>()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        if let uid = Auth.auth().currentUser?.uid {
            blockedRef = database.reference(withPath: "blocked/\(uid)")
            blockingRef = database.reference(withPath: "blocking/\(uid)")
            observeBlocks()
        }
        
        // Set up an on-disk URL cache.
        //let urlCache = URLCache(memoryCapacity: 0, diskCapacity:50 * 1024 * 1024, diskPath:nil)
        //URLCache.shared = urlCache
        
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { granted, _ in
                    if granted {
                        if let uid = Auth.auth().currentUser?.uid {
                            self.database.reference(withPath: "users/\(uid)/notificationEnabled").setValue(true)
                        } else {
                            self.notificationGranted = true
                        }
                    }
            })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        let db = Firestore.firestore()
        db.settings = settings
        application.registerForRemoteNotifications()
        
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        authUI?.tosurl = kFirebaseTermsOfService
        authUI?.isSignInWithEmailHidden = false
        let providers: [FUIAuthProvider] = [FUIGoogleAuth(), FUIFacebookAuth()]
        authUI?.providers = providers
        
        UINavigationBar.appearance().backgroundColor = UIColor.themeColor()
        UIBarButtonItem.appearance().tintColor = UIColor.themeColor()
        UITabBar.appearance().backgroundColor = UIColor.themeColor()
        
        window?.rootViewController = MainTabBarController()
        GMSPlacesClient.provideAPIKey(kPlacesAPIKey)
        GMSServices.provideAPIKey(kMapsAPIKey)
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        return true
    }
    
    
    func showAlert(_ userInfo: [AnyHashable: Any]) {
        let apsKey = "aps"
        let gcmMessage = "alert"
        let gcmLabel = "google.c.a.c_l"
        if let aps = userInfo[apsKey] as? [String: String], !aps.isEmpty, let message = aps[gcmMessage],
            let label = userInfo[gcmLabel] as? String {
            mdcMessage.text = "\(label): \(message)"
            MDCSnackbarManager.show(mdcMessage)
        }
    }
    
    func showContent(_ content: UNNotificationContent) {
        mdcMessage.text = content.body
        mdcAction.title = content.title
        mdcMessage.duration = 10_000
        mdcAction.handler = {
            guard let feed = self.window?.rootViewController?.childViewControllers[0] as? MainTabBarController else { return }
            let userId = content.categoryIdentifier.components(separatedBy: "/user/")[1]
            Database.fetchUserWithUID(uid: userId,  completion: { (user) in
                feed.showProfile(user)
            })
        }
        mdcMessage.action = mdcAction
        MDCSnackbarManager.show(mdcMessage)
    }

    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
        guard let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String else {
            return false
        }
        return self.handleOpenUrl(url, sourceApplication: sourceApplication)
    }
    
    @available(iOS 8.0, *)
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return self.handleOpenUrl(url, sourceApplication: sourceApplication)
    }
    
    func handleOpenUrl(_ url: URL, sourceApplication: String?) -> Bool {
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: nil)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        showAlert(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        showAlert(userInfo)
        completionHandler(.newData)
    }
    
    func observeBlocks() {
        blockedRef.observe(.childAdded) { self.blocked.insert($0.key) }
        blockingRef.observe(.childAdded) { self.blocking.insert($0.key) }
        blockedRef.observe(.childRemoved) { self.blocked.remove($0.key) }
        blockingRef.observe(.childRemoved) { self.blocking.remove($0.key) }
    }
    
    
    func isBlocked(_ snapshot: DataSnapshot) -> Bool {
        let author = snapshot.childSnapshot(forPath: "users/uid").value as! String
        if blocked.contains(author) || blocking.contains(author) {
            return true
        }
        return false
    }
    
    func isBlocked(by person: String) -> Bool {
        return blocked.contains(person)
    }
    
    func isBlocking(_ person: String) -> Bool {
        return blocking.contains(person)
    }
}

extension AppDelegate: FUIAuthDelegate {
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
                window?.rootViewController = MainTabBarController()
            }
        }
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return FPAuthPickerViewController(nibName: "FPAuthPickerViewController", bundle: Bundle.main, authUI: authUI)
    }
    
    func signOut() {
        blockedRef.removeAllObservers()
        blockingRef.removeAllObservers()
        blocked.removeAll()
        blocking.removeAll()
    }
    
    func signed(in user: User) {
        blockedRef = database.reference(withPath: "blocked/\(user.uid)")
        blockingRef = database.reference(withPath: "blocking/\(user.uid)")
        observeBlocks()
        
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
        database.reference(withPath: "users/\(user.uid)").updateChildValues(values)
        Firestore.firestore().collection("users").document(user.uid).collection("profile").document(user.uid).setData(values)
    }
}



@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void) {
        showContent(notification.request.content)
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        showContent(response.notification.request.content)
        completionHandler()
    }
}


extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference(withPath: "/users/\(uid)/notificationTokens/\(fcmToken)").setValue(true)
    }
    
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        let data = remoteMessage.appData
        showAlert(data)
    }
}

