//  ViewController.swift
//  InstagramFirebase
//
//  Created by Murray Toews on 6/3/17.
//  Copyright © 2017 maple.com

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseUI
import FBSDKCoreKit
import FBSDKLoginKit
import MaterialComponents
import Gallery
import Lightbox
import Photos
import AVFoundation
import AVKit



protocol ChangeSignPhotoControllerDelegate {
    func didChangeSignUpPhoto(user: MapleUser)
}


class ChangeSignPhotoController: UIViewController,
    GalleryControllerDelegate,
    LightboxControllerDismissalDelegate,
    UINavigationControllerDelegate  {
    
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        
    }
    
    var delegate : ChangeSignPhotoControllerDelegate?
    var imageArray = [UIImage]()
    var gallery: GalleryController!
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
    
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        LightboxConfig.DeleteButton.enabled = false
        Image.resolve(images: images, completion: { [weak self] resolvedImages in
            self?.showLightbox(images: resolvedImages.compactMap({ $0 }))
        })
    }
    
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        if images.count > 0 {
            sameProfileImage(image: getAssetThumbnail(asset: images[0].asset))
        }
        gallery.dismiss(animated: true, completion: nil)
    }
    
    func showLightbox(images: [UIImage]) {
        guard images.count > 0 else {
            return
        }
        
        let lightboxImages = images.map({ LightboxImage(image: $0) })
        let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
        lightbox.dismissalDelegate = self
        gallery.present(lightbox, animated: true, completion: nil)
    }
    
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
        
//        editor.edit(video: video) { (editedVideo: Video?, tempPath: URL?) in
//            DispatchQueue.main.async {
//                if let tempPath = tempPath {
//                    let controller = AVPlayerViewController()
//                    controller.player = AVPlayer(url: tempPath)
//
//                    self.present(controller, animated: true, completion: nil)
//                }
//            }
//        }
    }
    
    
    var spinner: UIView?

   
    
    lazy var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var url : URL?
    
    func sameProfileImage(image: UIImage){
        let filename = NSUUID().uuidString
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let storeRef = Storage.storage().reference().child("profile_images").child(filename).child(filename)
        if let data = image.sd_imageData() {
            storeRef.putData(data, metadata: metadata) { (metadata, err) in
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
                    else
                    {
                        self.url = url
                        if let urlString = url?.absoluteString {
                            self.profileImageView.loadImage(urlString: urlString)
                            self.plusPhotoButton.setImage(image, for: . normal)
                        }
                    }
                }
            }
        }
    }
    
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
        let url =  "https://firebasestorage.googleapis.com/v0/b/maplefirebase.appspot.com/o/profile_images%2F014BCC59-1498-4BC2-B542-77481DB47730?alt=media&token=a3cd97b9-1c82-4bdb-a49b-eb2057b0d9a4"
        iv.loadImage(urlString: url)
        return iv
    }()
    
    @objc func handlePlusPhoto() {
        gallery = GalleryController()
        gallery.delegate = self
        present(gallery, animated: true, completion: nil)
    }
    
    func signOut() {
        do {
            dismiss(animated: false, completion: nil)
            try Auth.auth().signOut()
        } catch {
        }
        //
        //appDelegate.signOut()
        //self.navigationController?.popToRootViewController(animated: false)
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
    
    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//
//        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
//            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
//        } else if let originalImage =
//            info["UIImagePickerControllerOriginalImage"] as? UIImage {
//            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
//        }
//        dismiss(animated: true, completion: nil)
//    }
    
    
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
        
        Firestore.fetchUserWithUID(uid: uid!) { (user) in
            self.user = user
            self.navigationItem.title = self.user?.username
            self.usernameTextField.text = self.user?.username
            if let profileImageUrl = self.user?.profileImageUrl {
                self.profileImageView.loadImage(urlString: profileImageUrl)
            }
            else
            {
                self.profileImageView.loadImage(urlString: "")
              
            }
        }
    }
    
    
    @objc func handleUpdate() {
        
        guard let url = self.url else {
            let alertController = UIAlertController(title: "", message: "select a photo", preferredStyle: UIAlertController.Style.actionSheet)
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
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        
        let urlString = "\(url)"
        user?.uid = uid
        user?.username = username
        user?.profileImageUrl = urlString
        
        self.delegate?.didChangeSignUpPhoto(user: user!)
        
        Firestore.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            
            let dictionaryValues = ["username": username, "profileImageUrl":  urlString] as [String : Any]
            let values = [uid: dictionaryValues]
            print (values)
            
            self.user!.profileImageUrl = urlString
            self.user!.username = username
            
            Firestore.firestore().collection("users").document(uid).collection("profile").document(uid).updateData(dictionaryValues)
            {
                err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    Firestore.updateUserProfile(user: self.user!)
                   
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
        tf.layer.cornerRadius = 5
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.text = "Allow Maple access to photos"
        tf.textColor = .blue
        tf.textAlignment = .right
        return tf
    }()

    
    let allowLocationLabel: UILabel = {
        let tf = UILabel()
        tf.layer.cornerRadius = 5
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.text = "Allow Maple to see your location"
        tf.textColor = .blue
        tf.textAlignment = .right
        return tf
    }()
    let allowPhotos: UISwitch = {
        let button = UISwitch()

        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(switchValueDidChange(sender:)), for: .valueChanged)
        button.isEnabled = true
        return button
    }()
    
    let allowLocation: UISwitch = {
        let button = UISwitch()

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
    
    private let insetView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Gallery.Config.VideoEditor.savesEditedVideoToLibrary = true
        Gallery.Config.initialTab = Gallery.Config.GalleryTab.imageTab
        Gallery.Config.tabsToShow = [Gallery.Config.GalleryTab.imageTab, Gallery.Config.GalleryTab.cameraTab]
        
        
        fetchUser()
        insetView.translatesAutoresizingMaskIntoConstraints = false
        insetView.backgroundColor = .lightGray
        view.addSubview(insetView)
        
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            insetView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            insetView.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
            ])
        
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                insetView.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0),
                guide.bottomAnchor.constraint(equalToSystemSpacingBelow: insetView.bottomAnchor, multiplier: 1.0)
                ])
            
        } else {
            let standardSpacing: CGFloat = 8.0
            NSLayoutConstraint.activate([
                insetView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing),
                bottomLayoutGuide.topAnchor.constraint(equalTo: insetView.bottomAnchor, constant: standardSpacing)
                ])
        }
      
        setupNavigationButtons()
        setupInputFields()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
}
    
    


    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        //let tappedImage = tapGestureRecognizer.view as! UIImageView
        handlePlusPhoto()
        
    }
    
    fileprivate func setupInputFields() {
          let Width : CGFloat  = 80
        
        insetView.addSubview(profileImageView)
        profileImageView.anchor(top: insetView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0 , paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: Width, height: Width)
        
        profileImageView.layer.cornerRadius =  Width  / 2
        profileImageView.clipsToBounds = true
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [usernameTextField, signUpButton, textFieldExplain,logoutButton])
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        
        stackView.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 200)
        
      
    }
    
}









