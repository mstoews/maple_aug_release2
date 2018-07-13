//
//  LoginController.swift
//  mapp
//
//  Created by Murray Toews on 6/3/17.
//  Copyright © 2017 maple.com

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn
import Fabric


struct FacebookPermission
{
    static let ID: String = "id"
    static let NAME: String = "name"
    static let EMAIL: String = "email"
    static let PROFILE_PIC: String = "picture"
    static let LAST_NAME: String = "last_name"
    static let FIRST_NAME: String = "first_name"
    static let USER_FRIENDS: String = "user_friends"
    static let PUBLIC_PROFILE: String = "public_profile"
}


class LoginController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate, GIDSignInUIDelegate {
    
    fileprivate func setupGoogleButtons() {
        //add google sign in button
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 16, y: 116 + 66, width: view.frame.width - 32, height: 50)
        view.addSubview(googleButton)
        
        let customButton = UIButton(type: .system)
        customButton.frame = CGRect(x: 16, y: 116 + 66 + 66, width: view.frame.width - 32, height: 50)
        customButton.backgroundColor = .orange
        customButton.setTitle("Custom Google Sign In", for: .normal)
        customButton.addTarget(self, action: #selector(handleCustomGoogleSign), for: .touchUpInside)
        customButton.setTitleColor(.white, for: .normal)
        customButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        view.addSubview(customButton)
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    @objc func handleCustomGoogleSign() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    fileprivate func setupFacebookButtons() {
        let loginButton = FBSDKLoginButton()
        view.addSubview(loginButton)
        //frame's are obselete, please use constraints instead because its 2016 after all
        loginButton.frame = CGRect(x: 16, y: 50, width: view.frame.width - 32, height: 50)
        
        loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile"]
        
        //add our custom fb login button here
        let customFBButton = UIButton(type: .system)
        customFBButton.backgroundColor = .blue
        customFBButton.frame = CGRect(x: 16, y: 116, width: view.frame.width - 32, height: 50)
        customFBButton.setTitle("Custom FB Login here", for: .normal)
        customFBButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        customFBButton.setTitleColor(.white, for: .normal)
        view.addSubview(customFBButton)
        
        customFBButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
    }
    
    @objc func handleCustomFBLogin() {
        FBSDKLoginManager().logIn(withReadPermissions: ["email"], from: self) { (result, err) in
            if err != nil {
                print("Custom FB Login failed:", err!)
                return
            }
            
            self.showEmailAddress()
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of facebook")
    }
    
//    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
//        if error != nil {
//            print(error)
//            return
//        }
//
//        showEmailAddress()
//    }
    
    func showEmailAddress() {
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
//        Auth.auth().signIn(with: credentials, completion: { (user, error) in
//            if error != nil {
//                print("Something went wrong with our FB user: ", error ?? "")
//                return
//            }
//
//            print("Successfully logged in with our user: ", user ?? "")
//        })
//
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, err) in
            
            if err != nil {
                print("Failed to start graph request:", err ?? "")
                return
            }
            print(result ?? "")
        }
    }
    
    
    let logoContainerView: UIView = {
        let view = UIView()
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white"))
        logoImageView.contentMode = .scaleAspectFill
        view.addSubview(logoImageView)
        logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 60 , paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 30)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.backgroundColor = .white
        return view
    }()
    
    
    
    func LinkWithAccount()
    {
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        let user = Auth.auth().currentUser
        user?.link(with: credential) { (user, error) in
        }
    }
    
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if (error != nil)
        {
            print("unable to login via Facebook")
            return
        }
        else
        {
            if result == nil {
                return
            }
            if result.isCancelled == true {
                return
            }
        }
               
         guard let fbuser: String = result.token.userID else {return}
        
         print ("Facebook USER ID : \(fbuser)")
        
        
         let graphRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "\(FacebookPermission.NAME), \(FacebookPermission.FIRST_NAME), \(FacebookPermission.LAST_NAME), \(FacebookPermission.EMAIL), \(FacebookPermission.PROFILE_PIC).type(large)"])
  
            graphRequest.start { (connection: FBSDKGraphRequestConnection?, result: Any?, error: Error?) in
            if ((error) != nil)
            {
                
                print("Error: \(String(describing: error))")
            }
            else
            {
                print(connection.debugDescription)
                let data:[String:AnyObject] = result as! [String : AnyObject]
                print (data)
                
            }
        
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
//            Auth.auth().signIn(with: credential) { (user, error) in
//                if let error = error {
//                    // ...
//                    print(error)
//                    return
//                }
//                self.ValidateFacebookLogin(FbUser: fbuser)
//                guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
//                mainTabBarController.setupViewControllers()
//                self.dismiss(animated: false, completion: nil)
//                
//            }
        }
        
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    var imageView: UIImageView?
    
    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                self.imageView?.image = UIImage(data: data)
            }
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .blue
        return iv
    }()
    
    var currentUser : User?
    
//    func ValidateFacebookLogin(FbUser: String)
//    {
//        //guard let uploadData = UIImageJPEGRepresentation(image, 0.3) else { return }
//        let imageURL = "https://graph.facebook.com/\(FbUser)/picture?type=large"
//        guard let url = URL(string: imageURL) else {return}
//        
//        //self.profileImageView.image = UIImage(data: try ? Data(contentsOf: url as URL) as Data)
//        let data = try? Data(contentsOf: url)
//        profileImageView.image = UIImage(data: data!)
//        
//        let filename = NSUUID().uuidString
//        guard profileImageView.image != nil else {return}
//        guard let uploadData = UIImageJPEGRepresentation(profileImageView.image!, 1.0) else { return }
//        let storage = Storage.storage().reference().child("profile_images")
//        
//        storage.child(filename).putData(uploadData , metadata: nil, completion: { (metadata, err) in
//            
//            if let err = err {
//                print("Failed to upload profile image:", err)
//                return
//            }
//            
//            guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else { return }
//            
//            print("Successfully uploaded profile image:", profileImageUrl)
//            
//            let values = [FbUser: self.currentUser]
//            
//            Database.database().reference().child("users").updateChildValues(values as Any as! [AnyHashable : Any], withCompletionBlock: { (err, ref) in
//                if let err = err {
//                    print("Failed to save user info into db:", err)
//                    return
//                }
//                print("Successfully saved user info to db")
//                
//            })
//        })
//    }
    
    
    
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.keyboardType = .emailAddress
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    
    let textFieldExplain: UILabel = {
        let tf = UILabel()
        tf.backgroundColor = .white
       tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()

    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            loginAuthButton.isEnabled = true
            loginAuthButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        } else {
            loginAuthButton.isEnabled = false
            loginAuthButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    let loginAuthButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    @objc func handleLogin() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, err) in
            
            if let err = err {
                print("Failed to sign in with email:", err)
                
                let eMessage : String
                eMessage = "Failed to login ... check connection or user/password combination"
                
                let alertController = UIAlertController(title: "Failed to sign in with Email Account", message: eMessage , preferredStyle: UIAlertControllerStyle.actionSheet)
                let cancelAction = UIAlertAction(title: "戻る", style: .cancel) { (result : UIAlertAction) -> Void in
                    //action when pressed button
                }
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            //print("Successfully logged back in with user:", user?.uid ?? "")
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
            mainTabBarController.setupViewControllers()
            self.dismiss(animated: true, completion: nil)
            
        })
    }
    
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "まだアカウントがありませんか？", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "アカウントの作成", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.rgb(red: 17, green: 154, blue: 237)]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    @objc func handleShowSignUp() {
        let signUpController = SignUpController()
        navigationController?.pushViewController(signUpController, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        //GIDSignIn.sharedInstance().signIn()

        
        
        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        
        navigationController?.isNavigationBarHidden = true
        
        view.backgroundColor = .white
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        setupInputFields()
        
        //self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SharePhotoController.dissmissKeyboard)))
        passwordTextField.delegate = self
        emailTextField.delegate = self
        
        fbLoginButton.delegate = self
        fbLoginButton.readPermissions = ["email","public_profile", "user_friends" ]
        
        
    }
    
    let fbLoginButton = FBSDKLoginButton()
    
    let googleButton = GIDSignInButton()
    
    func dissmissKeyboard()
    {
        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        return true
    }
    

    
    fileprivate func setupInputFields() {
        
//       
//        let twitterButton = TWTRLogInButton { (session, error) in
//            if let err = error {
//                print("Failed to login via Twitter: ", err)
//                return
//            }
//            
//            //print("Successfully logged in under Twitter...")
//            
//            //lets login with Firebase
//            
//            guard let token = session?.authToken else { return }
//            guard let secret = session?.authTokenSecret else { return }
//            let credentials = TwitterAuthProvider.credential(withToken: token, secret: secret)
//            
//            Auth.auth().signIn(with: credentials, completion: { (user, error) in
//                
//                if let err = error {
//                    print("Failed to login to Firebase with Twitter: ", err)
//                    return
//                }
//                
//                print("Successfully created a Firebase-Twitter user: ", user?.uid ?? "")
//                
//            })
//        }
//        
        let stackView = UIStackView(arrangedSubviews: [ emailTextField, passwordTextField, loginAuthButton, textFieldExplain, fbLoginButton, googleButton])
        //let stackView = UIStackView(arrangedSubviews: [ emailTextField, passwordTextField, loginAuthButton, textFieldExplain, fbLoginButton, googleButton])
        //let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginAuthButton, textFieldExplain, fbLoginButton, googleButton, twitterButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        stackView.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 43, paddingLeft: 43, paddingBottom: 0, paddingRight: 40, width: 0, height: 360)
        //view.addSubview(twitterButton)
        //twitterButton.anchor(top: stackView.bottomAnchor, left: stackView.leftAnchor, bottom: nil, right: stackView.rightAnchor)
    }
    
 
    
   }











