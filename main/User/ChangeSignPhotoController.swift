//  ViewController.swift
//  InstagramFirebase
//
//  Created by Murray Toews on 6/3/17.
//  Copyright © 2017 maple.com

import UIKit
import Firebase
import FirebaseUI
import FBSDKCoreKit
import FBSDKLoginKit
import MaterialComponents



protocol ChangeSignPhotoControllerDelegate {
    func didChangeSignUpPhoto()
}


class ChangeSignPhotoController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    var spinner: UIView?

    var delegate: ChangeSignPhotoControllerDelegate?
    
    lazy var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        button.layer.borderColor = UIColor.themeColor().cgColor
        button.layer.borderWidth = CGFloat(1.0)
        return button
    }()
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.layer.borderColor = UIColor.themeColor().cgColor
        return iv
    }()
    
    @objc func handlePlusPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
        }
        appDelegate.signOut()
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    @objc func handleLogOut() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Sign Out", style: .default, handler: { (_) in
            do {
                self.signOut()
                let authViewController = FUIAuth.defaultAuthUI()?.authViewController()
                authViewController?.navigationBar.isHidden = true
                self.present(authViewController!, animated: true, completion: nil)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage =
            info["UIImagePickerControllerOriginalImage"] as? UIImage {
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.keyboardType = .emailAddress
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        tf.text = "Something"
        return tf
    }()
    
    @objc func handleTextInputChange() {
        let isFormValid =  usernameTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = .mainBlue()
        } else {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.keyboardType = .alphabet
        tf.backgroundColor = UIColor.collectionCell()
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Update User Data", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleUpdate), for: .touchUpInside)
        button.isEnabled = true
        return button
    }()
    
    let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Out", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleLogOut), for: .touchUpInside)
        button.isEnabled = true
        return button
    }()
    
    fileprivate func setupNavigationButtons() {
//        let leftImage = UIImage(named: "Cancel")?.withRenderingMode(.alwaysOriginal)
//        let leftButton = UIBarButtonItem(image: leftImage, style: .done , target: self, action: #selector(handleCancel))
//        leftButton.tintColor = .black
//        navigationItem.leftBarButtonItem = leftButton
    }
    
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    var user: MapleUser?
    fileprivate func fetchUser() {
        
        let uid = Auth.auth().currentUser?.uid
        
        // The uid is being passed from the navigation control, if the user ID is nil this will fail ...
        // best to double check that the code is still working under different circumstances.
        
        Database.fetchUserWithUID(uid: uid!) { (user) in
            self.user = user
            self.navigationItem.title = self.user?.username
            self.usernameTextField.text = self.user?.username
            if let profileImageUrl = self.user?.profileImageUrl {
                self.profileImageView.loadImage(urlString: profileImageUrl)
            }
            else
            {
                return
              
            }
        }
    }
    
    @objc func handleUpdate() {
        
        spinner = displaySpinner()
        
           guard let image = self.plusPhotoButton.imageView?.image else {
                let alertController = UIAlertController(title: "", message: "select a photo", preferredStyle: UIAlertControllerStyle.actionSheet)
                let cancelAction = UIAlertAction(title: "戻る", style: .cancel) { (result : UIAlertAction) -> Void in
                    //action when pressed button
                }
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            guard let username = usernameTextField.text, username.count > 0 else {
                usernameTextField.text = self.title
                return
            }
            
            
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
                 
                guard let uid = Auth.auth().currentUser?.uid else { return }
                Database.fetchUserWithUID(uid: uid) { (user) in
                    self.user = user
                }
                
                let urlString = "\(url)"
                    
                let dictionaryValues = ["username": username, "profileImageUrl":  urlString] as [String : Any]
                let values = [uid: dictionaryValues]
                print (values)
                
                Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
                    if let err = err {
                        print("Failed to save user info into db:", err)
                        return
                    }
                    self.delegate?.didChangeSignUpPhoto()
                    
                    if let spinner = self.spinner {
                        self.removeSpinner(spinner)
                    }
                    _ = self.navigationController?.popViewController(animated: true)
                })
                }
            }
        }
    }
    
    let textFieldExplain: UILabel = {
        let tf = UILabel()
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 5
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()

    
    let allowPhotosLabel: UILabel = {
        let tf = UILabel()
        //tf.backgroundColor = #colorLiteral(red: 0.6197646856, green: 0.7577223182, blue: 1, alpha: 1)
        tf.layer.cornerRadius = 5
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.text = "Allow Maple access to photos"
        tf.textColor = .blue
        tf.textAlignment = .right
        return tf
    }()

    
    let allowLocationLabel: UILabel = {
        let tf = UILabel()
        //tf.backgroundColor = #colorLiteral(red: 0.6197646856, green: 0.7577223182, blue: 1, alpha: 1)
        tf.layer.cornerRadius = 5
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.text = "Allow Maple to see your location"
        tf.textColor = .blue
        tf.textAlignment = .right
        return tf
    }()
    let allowPhotos: UISwitch = {
        let button = UISwitch()
        //button.backgroundColor = #colorLiteral(red: 0.6197646856, green: 0.7577223182, blue: 1, alpha: 1)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(switchValueDidChange(sender:)), for: .valueChanged)
        button.isEnabled = true
        return button
    }()
    
    let allowLocation: UISwitch = {
        let button = UISwitch()
        //button.backgroundColor = #colorLiteral(red: 0.6197646856, green: 0.7577223182, blue: 1, alpha: 1)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(switchAllowLocation(sender:)), for: .valueChanged)
        button.isEnabled = true
        return button
    }()
    
    @objc func switchAllowLocation(sender:UISwitch!) {
        print("Locatoin value is \(sender.isOn)")
    }
    
    @objc func switchValueDidChange(sender:UISwitch!) {
        print("Photos value is \(sender.isOn)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let Width : CGFloat  = 80
        
        fetchUser()
        view.backgroundColor = .white
        view.addSubview(plusPhotoButton)
        plusPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 100 , paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: Width, height: Width)
        plusPhotoButton.layer.cornerRadius =  Width  / 2
        plusPhotoButton.clipsToBounds = true
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        setupNavigationButtons()
        setupInputFields()
}
    
    fileprivate func setupInputFields() {
        
        let stackView = UIStackView(arrangedSubviews: [usernameTextField, signUpButton, textFieldExplain,logoutButton])
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 200)
        
      
    }
    
}









