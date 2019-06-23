
//
//  SharePhotoController+Save.swift
//  maple-release
//
//  Created by Murray Toews on 2018/03/03.
//  Copyright © 2018 Murray Toews. All rights reserved.
//
import UIKit
import Firebase
import FirebaseFirestore
import AlgoliaSearch
import InstantSearchCore
import MaterialComponents
import JGProgressHUD


extension ShareController
    
{
    
    func updateAlgoliaUsers(user: MapleUser)
    {
        let values : [String: Any] = ["userid" : user.uid,
                                      "name" : user.username,
                                      "profileUrl" : user.profileImageUrl]
        
        AlgoliaManager.sharedInstance.users.addObject(values, withID: user.uid , completionHandler: { (content, error) -> Void in
            if error == nil {
                if let objectID = content!["objectID"] as? String {
                    print("Object ID: \(objectID)")
                }
            }
        })
    }
    
    
    func updateAlgoliaStore(post: FSPost)
    {
        let values : [String: Any] = ["userid" : post.uid,
                                      "name" : post.userName,
                                      "profileUrl" : post.imageUrl,
                                      "product": post.product ,
                                      "description" : post.description,
                                      "urlArray" : post.imageUrlArray,
                                      "creationDate": Date().timeIntervalSince1970]
        
        AlgoliaManager.sharedInstance.posts.addObject(values, withID: post.id! , completionHandler: { (content, error) -> Void in
            if error == nil {
                if let objectID = content!["objectID"] as? String {
                    print("Object ID: \(objectID)")
                }
            }
        })
    }
    
    
    func imageWithImage (sourceImage:UIImage, scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width
        let scaleFactor = scaledToWidth / oldWidth
        
        let newHeight = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    
    @objc func handleShareAll(_ sender: UIButton) {
        
        
        let docRef =  db.collection("posts")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let actionGoToMaps = {() in
            self.openMapSelector()
        }
        
        let actionGoToSelectImages = {() in
            self.handleAddPhotos()
        }
        
        let message = MDCSnackbarMessage()
        MDCSnackbarManager.snackbarMessageViewBackgroundColor  = UIColor.buttonThemeColor()
        
        
        if imageArray.count == 0 {
            message.text = "Select at least one image ..."
            let action = MDCSnackbarMessageAction()
            action.handler = actionGoToSelectImages
            action.title = "OK"
            message.action = action
            MDCSnackbarManager.show(message)
            return
        }
        
        
        guard let product = products.text, product.count > 0  else {
            message.text = "Please enter a product name ..."
            MDCSnackbarManager.show(message)
            
            return
        }
        
        if mapObjects.count == 0 {
            message.text = "Select at least one location ..."
            let action = MDCSnackbarMessageAction()
            action.handler = actionGoToMaps
            action.title = "OK"
            message.action = action
            MDCSnackbarManager.show(message)
            return
        }
        
        guard let description = descriptionTextView.text,  description.count > 0  else {
            message.text = "Please enter a description ..."
            MDCSnackbarManager.show(message)
            return
        }
        
        progressIndicator.isHidden = false
        cancelButton.isHidden = false
        descriptionTextView.isHidden = true
        runningCountLabel.isHidden = true
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        var docId = docRef.document().documentID
        
        if user != nil {
            let values : [String: Any] = [
                "postid" : docId,
                "description" : description,
                "name" : user.username,
                "uid" : uid,
                "profileUrl" : user.profileImageUrl,
                "product": product,
                "numberOfLikes": 0,
                "numberOfComments" : 0,
                "creationDate": Date().timeIntervalSince1970
            ]
            self.db.collection("posts").document(docId).setData(values)
            { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully postId: " + docId)
                }
            }
        }
        
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Updating post ..."
        hud.show(in: view)
        
        saveLocations(docId) { (locId) in
            docId = locId
            print("Locations completed")
        }
        
        //saveImages(postid: docId, typeName: "thumbImages", imageSize: 160, images: self.imageArray)
        
        urlArray.removeAll()
        
        for image in imageArray {
            let size = CGSize(width: 1080, height: 1080)
            let uploadData = image.RBResizeImage(image: image, targetSize: size)
            if let data =  uploadData.jpegData(compressionQuality: 0.75)  {
                uploadImage(data: data, postId: docId)
            }
        }
        DispatchQueue.main.async {
            self.imageArray.removeAll()
            self.mapObjects.removeAll()
            self.products.text?.removeAll()
            self.descriptionTextView.text?.removeAll()
            self.imageCollectionView.reloadData()
            self.locationCollectionView.reloadData()
            self.progressIndicator.isHidden = true
            self.cancelButton.isHidden = true
            self.descriptionTextView.isHidden = false
            self.runningCountLabel.isHidden = false
                message.text = "Upload completed successfully"
                MDCSnackbarManager.show(message)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        hud.dismiss()
    }
    
    func uploadImage(data: Data, postId: String)
    {
        
        if let uid = Auth.auth().currentUser?.uid {
            
            
            let filename = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            progressIndicator.progress = Float(0)
            
            let storeRef = Storage.storage().reference().child(uid).child(postId).child(filename)
            uploadTask = storeRef.putData(data, metadata: metadata) { [weak self] (metadata, err) in
                guard let strongSelf = self else { return }
                
                DispatchQueue.main.async {
                    strongSelf.progressIndicator.isHidden = true
                    strongSelf.cancelButton.isHidden = true
                }
                
                
                if let err = err {
                    strongSelf.navigationItem.rightBarButtonItem?.isEnabled = true
                    print("Failed to upload post image:", err)
                    return
                }
                
                storeRef.downloadURL { (url, err)  in
                    if let err = err {
                        strongSelf.navigationItem.rightBarButtonItem?.isEnabled = true
                        print("Failed to upload post image:", err.localizedDescription)
                        return
                    }
                    if let url = url {
                        strongSelf.urlArray.append(url.absoluteString)
                        
                        let values = [ "url": url.absoluteString,
                                       "creationDate": Date().timeIntervalSince1970,
                                       "fileName": filename,
                                       "bucket": storeRef.bucket,
                                       "fullPath":storeRef.fullPath] as [String : Any]
                        
                        
                        strongSelf.db.collection("posts").document(postId).collection("thumbImages").document().setData(values) { err in
                            if let err = err {
                                print("Error writing document: \(err.localizedDescription)")
                            } else {
                                print("Document successfully images postId: " + postId)
                            }
                        }
                        
                        let valueImages = [ "thumbImages" : strongSelf.urlArray ]
                        strongSelf.db.collection("posts").document(postId).updateData(valueImages) { err in
                            if let err = err {
                                print("Error writing document: \(err.localizedDescription)")
                            } else {
                                print("Document urlArray postId: " + postId)
                            }
                        }
                        
                    }
                }
            }
            
            uploadTask?.observe(.progress) { [weak self] (snapshot) in
                guard let strongSelf = self else {return}
                let percentageComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)/Double(snapshot.progress!.totalUnitCount)
                DispatchQueue.main.async {
                    strongSelf.progressIndicator.setProgress(Float(percentageComplete), animated: true)
                }
            }
        }
    }
    
    
    func saveImages( postid: String,  typeName: String, imageSize: CGFloat, images: [UIImage] ) {
        
        if postid.count > 0 {
            for image in images {
                var uploadData: UIImage!
                
                if imageSize == 160 {
                    let size = CGSize(width: 1080, height: 1080)
                    uploadData = image.RBResizeImage(image: image, targetSize: size)
                }
                else {
                    uploadData = image.resizeImage(imageSize)
                }
                
                if let data =  uploadData.jpegData(compressionQuality: 0.75)  {
                    uploadImage(data: data, postId: postid)
                }
            }
        }
    }
    
    
    
    
    func saveImages( postid: String,  typeName: String, imageSize: CGFloat, images: [UIImage]  , _ completion: @escaping (String) -> ()) {
        var urlArray = [String]()
        
        if postid.count > 0 {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            for image in images {
                var uploadData: UIImage!
                
                if imageSize == 160 {
                    let size = CGSize(width: 160.0, height: 160)
                    uploadData = image.RBResizeImage(image: image, targetSize: size)
                }
                else{ uploadData = image.resizeImage(imageSize) }
                let filename = NSUUID().uuidString
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                
                let storeRef = Storage.storage().reference().child(uid).child(postid).child(typeName).child(filename)
                storeRef.putData(uploadData.sd_imageData()!, metadata: metadata) { (metadata, err) in
                    if let err = err {
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        print("Failed to upload post image:", err)
                        return
                    }
                }
                storeRef.downloadURL { (url, err)  in
                    if let err = err {
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        print("Failed to upload post image:", err)
                        return
                    }
                    if let url = url {
                        urlArray.append(url.absoluteString)
                        //imageUrl = url.absoluteString
                        
                        let values = [ "url": url.absoluteString, "creationDate": Date().timeIntervalSince1970] as [String : Any]
                        self.db.collection("posts").document(postid).collection(typeName).document().setData(values) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document successfully images postId: " + postid)
                            }
                        }
                        
                        let valueImages = [ typeName : urlArray ]
                        self.db.collection("posts").document(postid).updateData(valueImages) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document urlArray postId: " + postid)
                            }
                        }
                        
                    }
                }
            }
            
        }
    }
    
    
    func updateFireStore (post: Post)
    {
        if let postid = post.id {
            let values : [String: Any] = [
                "postid" : postid,
                "name" : post.user.username,
                "uid" : post.user.uid,
                "profileUrl" : post.user.profileImageUrl,
                "product": post.caption,
                "description" : post.description,
                "originalImages" : post.largeUrlArray,
                "thumbImages" : post.imageUrlArray,
                "creationDate": Date().timeIntervalSince1970,
                "numberOfLikes": 0,
                "numberOfComments" : 0]
            
            db.collection("posts").document(postid).setData(values)
            { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully postId: " + postid)
                }
            }
            
        }
    }
    
    
    fileprivate func saveToDatabase( _ completion: @escaping (String) -> () )
    {
        guard let product = products.text else { products.text = "Set a product" ; return }
        guard let desc = descriptionTextView.text else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userPostRef = Database.database().reference().child("posts").child(uid)
        let ref = userPostRef.childByAutoId()
        
        let values : [String:Any] = ["product": product,
                                     "description" : desc,
                                     "creationDate": Date().timeIntervalSince1970]
        
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to save post to DB", err)
                return
            }
            print("Successfully saved post to DB")
        }
        print("postid : \(String(describing: ref.key))")
        completion(ref.key!)
    }
    
    
    
    func saveLocations(_ postId: String, _ completion: @escaping (String) -> ()) {
        if mapObjects.count > 0 {
            for location in mapObjects {
                
                var priceLevel : String?
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                
                if  let pl = location.place?.priceLevel {
                    priceLevel = text(for: pl)
                }
                
                if let types = location.place?.types!.joined(separator: ", ") {
                    let values : [String:Any] = [
                        "uid" : uid,
                        "postId:" : postId,
                        "location": location.place?.name ?? noneText,
                        "latitude" : location.place?.coordinate.latitude  ?? noneText,
                        "longitude": location.place?.coordinate.longitude  ?? noneText,
                        "address": location.place?.formattedAddress  ?? noneText,
                        "place":location.place?.name  ?? noneText,
                        "phoneNumber": location.place?.phoneNumber ?? noneText,
                        "priceLevel": priceLevel ?? noneText,
                        "rating":location.place?.rating ?? noneText,
                        "types": types,
                        "creationDate": Date().timeIntervalSince1970]
                    
                    db.collection("posts").document(postId).collection("location").document().setData(values)
                    { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully postId: " + postId)
                        }
                    }
                    
                    db.collection("location").document().setData(values)
                    { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully postId: " + postId)
                        }
                    }
                    
                    completion(postId)
                    
                }
            }
        }
    }
    
}
