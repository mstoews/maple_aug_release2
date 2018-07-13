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

extension SharePhotoController
    
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
        MDCSnackbarManager.snackbarMessageViewBackgroundColor  = UIColor.themeColor()
        
        guard let product = Products.text, product.count > 0  else {
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
        
        guard let description = Description.text,  description.count > 0  else {
            message.text = "Please enter a description ..."
            MDCSnackbarManager.show(message)
            return
        }
        
        if imageArray.count == 0 {
            message.text = "Select at least one image ..."
            let action = MDCSnackbarMessageAction()
            action.handler = actionGoToSelectImages
            action.title = "OK"
            message.action = action
            MDCSnackbarManager.show(message)
            return
        }
        
       
        
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
                "numberOfLikes": "0",
                "numberOfComments" : "0",
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
        
        
        spinner = displaySpinner()
//        myGroup.enter()
//        self.saveImages(postid: docId, typeName: "originalImages", imageSize: 640 , images: self.imageArray) { (imgId) in
//            docId = imgId
//            print("original completed")
//            myGroup.leave()
//        }
//
        myGroup.enter()
        saveImages(postid: docId, typeName: "thumbImages", imageSize: 320, images: self.imageArray)
        
        myGroup.enter()
        self.saveLocations(docId) { (locId) in
            docId = locId
            print("Locations completed")
        }
        
        myGroup.notify(queue: .main) {
            if let spinner = self.spinner {
                self.removeSpinner(spinner)
            }
            self.imageArray.removeAll()
            self.mapObjects.removeAll()
            self.Products.text?.removeAll()
            self.Description.text?.removeAll()
            self.CategoryDesc.text?.removeAll()
            self.imageCollectionView.reloadData()
            self.locationCollectionView.reloadData()
            print("main queue updated")
            message.text = "Upload completed successfully"
            MDCSnackbarManager.show(message)
            self.tabBarController?.selectedIndex = 0
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            
        }
        
    }
    
    func saveImages( postid: String,  typeName: String, imageSize: CGFloat, images: [UIImage] ) {
        var urlArray = [String]()
        if postid.count > 0 {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            for image in images {
                var uploadData: UIImage!
                
                if imageSize == 160 {
                    let size = CGSize(width: 320.0, height: 320)
                    uploadData = image.RBResizeImage(image: image, targetSize: size)
                }
                else{ uploadData = image.resizeImage(imageSize) }
                let filename = NSUUID().uuidString
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                
                let storeRef = Storage.storage().reference().child(uid).child(typeName).child(filename)
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
            myGroup.leave()
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
                
                let storeRef = Storage.storage().reference().child(uid).child(typeName).child(filename)
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
                "numberOfLikes": "0",
                "numberOfComments" : "0"]
            
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
        guard let product = Products.text else { Products.text = "Set a product" ; return }
        guard let desc = Description.text else { return }
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
        print("postid : \(ref.key)")
        completion(ref.key)
    }
    
    
    
    func saveLocations(_ postId: String, _ completion: @escaping (String) -> ()) {
        if mapObjects.count > 0 {
            for location in mapObjects {
                
                var priceLevel : String?
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                
                if  let pl = location.place?.priceLevel {
                    priceLevel = text(for: pl)
                }
                
                if let types = location.place?.types.joined(separator: ", ") {
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
         myGroup.leave()
    }
    
}
