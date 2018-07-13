//
//  ModifyPhotoController.swift
//  maple-release
//
//  Created by Murray Toews on 3/22/18.
//  Copyright © 2018 Murray Toews. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
import DKImagePickerController
import Sharaku
import os.log
import AlgoliaSearch
import InstantSearchCore
//import Floaty




class ModifyPhotoController : SharePhotoController {

    func fetchPostById (uid : String , postid: String, completion: @escaping (Post)->() )
    {
        Database.fetchUserWithUID(uid: uid) { (user) in
            let ref = Database.database().reference()
            ref.child("posts").child(uid).child(postid).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                let key = snapshot.key
                var post = Post(user: user, dictionary: dictionary)
                post.id = key
                completion(post)
            })
        }
    }
    
    @objc func handleSharePost(_ sender: UIButton) {
        print("handleShareFromMain")
        
        guard let  caption = Products.text, caption.count > 0  else {
            //presentWindow!.makeToast(message: "Add a product name", duration: 1, position: "center" as AnyObject)
            return
        }
        
        guard let description = Description.text,  description.count > 0  else {
            //presentWindow!.makeToast(message: "Add a description", duration: 1, position: "center" as AnyObject)
            return
        }
        
        if mapObjects.count == 0 {
            //let image = UIImage(named: "icons8-marker-50")
            //presentWindow!.makeToast(message: "Select at least one location", duration: 1, position: "center" as AnyObject, image: image!)
            return
        }
        
        if imageArray.count == 0 {
            ///let image = UIImage(named: "icons8-Photo Gallery Filled-50")
            //presentWindow!.makeToast(message: "Select at least one image", duration: 1, position: "center" as AnyObject, image: image!)
            return
        }
        
        self.modifyToDatabase() {(postid) in
            self.modifyImages(postid)
            self.modifyLocations(postid)
            if let uid = Auth.auth().currentUser?.uid {
                Database.fetchPostByUidPostId(uid: uid, postId: postid) { (Post) in
                    //self.updateAlgoliaStore(post: Post)
                }
            }
            
         NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
         //self.presentWindow!.makeToast(message: "Post has been shared", duration: 3, position: "center" as AnyObject)
        }
        self.clearFields()
    }
    
    
    func modifyLocations(_ postid: String) {
        if mapObjects.count > 0 {
            for location in mapObjects {
                //var website : String?
                guard let uid = Auth.auth().currentUser?.uid else { return }
                let locationsRef = Database.database().reference().child("locations").child(postid).childByAutoId()
                let locationByUidRef = Database.database().reference().child("posts").child(uid).child(postid).child("locations").childByAutoId()
                let priceLevel = text(for: (location.place?.priceLevel)!)
                
                if let types = location.place?.types.joined(separator: ", ") {
                    let values : [String:Any] = [
                        // "web": website ?? "https//www.google.com",
                        "latitude" : location.place?.coordinate.latitude  ?? noneText,
                        "longitude": location.place?.coordinate.longitude  ?? noneText,
                        "address": location.place?.formattedAddress  ?? noneText,
                        "place":location.place?.name  ?? noneText,
                        "phoneNumber": location.place?.phoneNumber ?? noneText,
                        "priceLevel": priceLevel ,
                        "rating":location.place?.rating ?? noneText,
                        "types": types,
                        "creationDate": Date().timeIntervalSince1970]
                    
                    // update a table for individual locations by post
                    locationsRef.updateChildValues(values) { (err, ref) in
                        if let err = err {
                            self.navigationItem.rightBarButtonItem?.isEnabled = true
                            print("Failed to save post to DB", err)
                            return
                        }
                        print("Successfully saved post to DB")
                    }
                    
                    // update locations by UID for each post within the post
                    locationByUidRef.updateChildValues(values) { (err, ref) in
                        if let err = err {
                            self.navigationItem.rightBarButtonItem?.isEnabled = true
                            print("Failed to save post to DB", err)
                            return
                        }
                        print("Successfully saved post to DB")
                    }
                    
                    // update algo to for locations
                    AlgoliaManager.sharedInstance.location.addObject(values, withID: postid , completionHandler: { (content, error) -> Void in
                        if error == nil {
                            if let objectID = content!["objectID"] as? String {
                                print("Object ID: \(objectID)")
                            }
                        }
                    })
                }
                
            }
        }
    }
    
    
    
    func modifyAlgoliaStore(post: Post)
    {
        let values : [String: Any] = ["userid" : post.user.uid,
                                      "name" : post.user.username,
                                      "profileUrl" : post.user.profileImageUrl,
                                      "product": post.caption,
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
    
    func modifyToDatabase( _ completion: @escaping (String) -> () )
    {
        guard let product = Products.text else { Products.text = "Set a product" ; return }
        guard let desc = Description.text else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userPostRef = Database.database().reference().child("posts").child(uid)
        let ref = userPostRef.childByAutoId()
        
        let values : [String:Any] = ["product": product, "description" : desc,  "creationDate": Date().timeIntervalSince1970]
        
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
    
    func modifyImages(_ postid: String) {
        if postid.count > 0 {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            for image in imageArray {
                guard let uploadData = UIImageJPEGRepresentation(image, 0.8) else { return }
                
                navigationItem.rightBarButtonItem?.isEnabled = true
                let filename = NSUUID().uuidString
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                let storageRef = Storage.storage().reference().child("posts_images").child(filename)
                storageRef.putData(uploadData, metadata: metadata) { (metadata, err) in
                    if let err = err {
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        print("Failed to upload post image:", err)
                        return
                    }
                    
                    storageRef.downloadURL( completion: { (url, err) in
                        if let err = err {
                            self.navigationItem.rightBarButtonItem?.isEnabled = true
                            print("Failed to upload post image:", err)
                            return
                        }
                        
                        if let imageUrl = url?.absoluteString
                        {
                            let userPostRef = Database.database().reference().child("imagebypost").child(uid).child(postid).childByAutoId()
                            let values = [ "url": imageUrl, "creationDate": Date().timeIntervalSince1970] as [String : Any]
                            
                            userPostRef.updateChildValues(values) { (err, ref) in
                                if let err = err {
                                    print("Failed to save post to DB", err)
                                    return
                                }
                            }
                            let PostRef = Database.database().reference().child("posts").child(uid).child(postid).child("imagesUrl").childByAutoId()
                            
                            PostRef.updateChildValues(values) { (err, ref) in
                                if let err = err {
                                    print("Failed to save post to DB", err)
                                    return
                                }
                            }
                        }
                    })
                    
                }
            }
        }
    }
    
    func clearFields() {
        self.imageArray.removeAll()
        self.mapObjects.removeAll()
        self.Products.text?.removeAll()
        self.Description.text?.removeAll()
        self.imageCollectionView.reloadData()
        self.locationCollectionView.reloadData()
    }

    func deletePosts(uid : String , postId: String)
    {
        CellType = CT.PIC
        print("The post will be deleted.... \(uid) : \(postId)")
        //Database.database().reference().child("posts").child(uid).child(postId).setValue(1)
        AlgoliaManager.sharedInstance.posts.deleteObject(withID: postId)
        AlgoliaManager.sharedInstance.location.deleteObject(withID: postId)
        clearFields()
    }
    
    @objc func deletePost(uid: String, postId: String)
       {
                let alert = UIAlertController(title: "Delete Product Post", message: "Current post will be permanently deleted. Continue?", preferredStyle: UIAlertControllerStyle.alert)
                
                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler:
                    { action in
                        switch action.style{
                        case .default:
                            self.deletePosts(uid: uid, postId: postId)
                        case .cancel:
                            print("cancel")
                            
                        case .destructive:
                            print("destructive")
                        }}))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
        
        }
    
    @objc override func handleClearAllFields()
    {
//        CellType = CT.PIC
//        if let uid = Auth.auth().currentUser?.uid {
//            if let postid = post?.id {
//                deletePost(uid: uid, postId: postid)
//            }
//        }
    }
    
    
    override func viewDidLoad() {
        /***** Set up toasts *****/
        edgesForExtendedLayout = UIRectEdge()
        //UIView.hr_setToastThemeColor(color: UIColor.themeColor())
        //presentWindow = UIApplication.shared.keyWindow
        
        
        imageCollectionView.register(PostImageObject.self, forCellWithReuseIdentifier: imageCellId)
        locationCollectionView.register(MapCell.self, forCellWithReuseIdentifier: mapCellId)
        view.backgroundColor = UIColor.themeColor()
        self.view.tintColor  = UIColor.themeColor()
        navigationItem.title = "Amend Post"
        
        Products.delegate = self
        //Description.delegate = self
        tableProductsView.delegate = self
        tableProductsView.dataSource =  self
        setupImageAndTextViews()
        setNavigationButtons()
        
        
        /****** Tap to dismiss KeyBoard ******/
        
        let tapImageCollectionView = UITapGestureRecognizer(target: self, action: #selector(imageCollectionViewTapped(tapGestureRecognizer: )))
        imageCollectionView.isUserInteractionEnabled = true
        imageCollectionView.addGestureRecognizer(tapImageCollectionView)
        //view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dissmissKeyboard)))
        /****** End Gestures           ******/
        
        
        /******  Algolia Search ******/
        postSearcher = Searcher(index: AlgoliaManager.sharedInstance.posts, resultHandler: self.handleSearchResults)
        postSearcher.params.hitsPerPage = 15
        postSearcher.params.attributesToRetrieve = ["*" ]
        postSearcher.params.attributesToHighlight = ["product"]
        tableProductsView.tableHeaderView?.isHidden = true
        definesPresentationContext = true
        updateSearchResults(for: Products)
        
//        if let uid = Auth.auth().currentUser?.uid {
//            if let postid = post?.id {
//                   Database.fetchPostByUidPostId(uid: uid, postId: postid) { (Post) in
//                   self.post = Post
//                    if self.post  != nil {
//                        self.imageCollectionView.reloadData()
//                        self.locationCollectionView.reloadData()
//                        
//                    }
//                }
//            }
//        }
    
            
        // End Algolia Search
        
    }
}
