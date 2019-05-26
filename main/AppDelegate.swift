import Firebase
import FirebaseFirestore
import FirebaseUI
import GoogleSignIn
import MaterialComponents
import UserNotifications
import GoogleMaps
import GooglePlaces



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
//        if let uid = Auth.auth().currentUser?.uid {
//            blockedRef = database.reference(withPath: "blocked/\(uid)")
//            blockingRef = database.reference(withPath: "blocking/\(uid)")
//            observeBlocks()
//        }
//        
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
        let setting = db.settings
        setting.areTimestampsInSnapshotsEnabled = true
        db.settings = setting
       
        application.registerForRemoteNotifications()
        
        UINavigationBar.appearance().backgroundColor = UIColor.themeColor()
        UIBarButtonItem.appearance().tintColor = UIColor.buttonThemeColor()
        UITabBar.appearance().backgroundColor = UIColor.themeColor()
        window?.backgroundColor = UIColor.themeColor()
        
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
        mdcMessage.duration = 3
        mdcAction.handler = {
            guard let feed = self.window?.rootViewController?.childViewControllers[0] as? MainTabBarController else { return }
            let userId = content.categoryIdentifier.components(separatedBy: "/user/")[1]
            Firestore.fetchUserWithUID(uid: userId,  completion: { (user) in
                feed.showProfile(user)
            })
        }
        mdcMessage.action = mdcAction
        MDCSnackbarManager.show(mdcMessage)
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
        let values: [String: Any] = ["token": fcmToken ]
        Firestore.firestore().collection("users").document(uid).collection("profile").document(uid).updateData(values)
    }
    
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        let data = remoteMessage.appData
        showAlert(data)
    }
}

