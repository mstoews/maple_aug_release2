//
//  UserProductController.swift
//  Maple
//
//  Created by Murray Toews on 4/24/19.
//  Copyright © 2019 Murray Toews. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import Photos
import VideoToolbox
import FBSDKLoginKit
import GoogleMaps
import GooglePlaces
import Lightbox
import MaterialComponents

class UserProductController: UserProfileController {
    
    private var fs_posts: [FSPost] = []
    private var docs: [DocumentSnapshot] = []
    private var bookMarkListener: ListenerRegistration?
    private var postId: String = ""
    
    func setPostId(postId: String) {
        self.postId = postId
    }
    
    override func didChangeToListView() {
        print("didChangeToListView")
        cellType = CellType.LIST
        observeQuery(postId: postId)
        collectionView?.reloadData()
    }
    
    override func didChangeToGridView() {
        print("didChangeToGridView")
        cellType = CellType.GRID
        observeQuery(postId: postId)
        collectionView?.reloadData()
    }
    
    
    fileprivate func fetchUser() {
        self.observeQuery(postId: self.postId)
    }
    
    fileprivate  func observeQuery(postId : String)
    {
        stopObserving()
        self.listener = self.db.collection("posts")
            .whereField("postid", isEqualTo: postId)
            .order(by: "creationDate", descending: true)
            .addSnapshotListener{  (snapshot, error) in
                guard let snapshot = snapshot else {
                    print("Error fetching snapshot results: \(error!)")
                    return
                }
                
                let models = snapshot.documents.map { (document) -> FSPost in
                    if let model = FSPost(dictionary: document.data(), postId: document.documentID) {
                        return model
                    }
                    else {
                        // Don't use fatalError here in a real app.
                        fatalError("Unable to initialize type \(FSPost.self) with dictionary \(document.data())")
                    }
                }
                
                self.fs_posts = models
                print (self.fs_posts)
                self.docs = snapshot.documents
                
                if self.docs.count > 0 {
                    self.collectionView?.backgroundView = nil
                }
                else
                {
                    self.collectionView?.backgroundView = nil
                }
                self.collectionView?.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.collectionBackGround()
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerCellId)
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(UserGridPostCell.self, forCellWithReuseIdentifier: userGridCellId)
        collectionView?.register(UserListPostCell.self, forCellWithReuseIdentifier: userListCellId)
        collectionView?.register(MapViewCell.self, forCellWithReuseIdentifier: mapViewCell)
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        self.navigationItem.title = "Product Page"
        fetchPost()
    }
    
    func fetchPost() {
        observeQuery(postId: postId)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 0, 5)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var rc = 0
        switch cellType
        {
        case CellType.BKMK :
            rc = fs_posts.count
            break
            
        case CellType.GRID :
            rc = fs_posts.count
            break
            
        case CellType.LIST:
            rc = fs_posts.count
            break
            
        case CellType.MAP :
            rc = fs_posts.count
            break
        }
        
        return rc
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var rc  = collectionView.dequeueReusableCell(withReuseIdentifier: userGridCellId, for: indexPath)
        switch cellType
        {
        case CellType.BKMK :
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userGridCellId, for: indexPath) as! UserGridPostCell
            cell.post = fs_posts[indexPath.item]
            cell.delegate = self
            rc = cell
            break
            
        case CellType.GRID :
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userGridCellId, for: indexPath) as! UserGridPostCell
            if (fs_posts.count > 0 ){
                cell.post = fs_posts[indexPath.item]
                cell.delegate = self
            }
            rc = cell
            break
            
        case CellType.LIST :
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userListCellId, for: indexPath) as! UserListPostCell
            if (fs_posts.count > 0 ){
                cell.post = fs_posts[indexPath.item]
                cell.delegate = self
            }
            rc = cell
            break
            
        case CellType.MAP :
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: mapViewCell, for: indexPath) as! MapViewCell
            if (fs_posts.count > 0 ){
                //cell.mapLocation = fs_locations
            }
            rc = cell
            break
        }
        return rc
    }
    
    
   
    
    override func  collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        
        let cell : UICollectionViewCell = collectionView.cellForItem(at: indexPath as IndexPath)!
        cell.backgroundColor = UIColor.magenta
    }
    
    
    override func  collectionView(collectionView: UICollectionView, cellForItemAtIndexPath  indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : UICollectionViewCell = collectionView.cellForItem(at: indexPath as IndexPath)!
        cell.backgroundColor = UIColor.magenta
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerCellId , for: indexPath) as! UserProfileHeader
        if indexPath.section == 0 {
            header.inkView.removeFromSuperview()
            headerView = header
            headerView?.userView = self.user
            headerView?.delegate = self
            return header
        }
        header.userView = self.user
        header.delegate = self
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var rc = CGSize()
        switch cellType
        {
        case CellType.GRID :
            //let width = view.frame.width
            let approximateWidthOfBioTextView = view.frame.width
            let size = CGSize(width: approximateWidthOfBioTextView, height: 1200)
            let attributes = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: CGFloat(15))]
            let post = fs_posts[indexPath.item]
            let estimatedFrame = NSString(string: post.description).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            rc = CGSize(width: view.frame.width - 15 , height: estimatedFrame.height + view.frame.width - 60 )
            break
            
        case CellType.LIST  :
            //let width = view.frame.width
            let approximateWidthOfBioTextView = view.frame.width
            let size = CGSize(width: approximateWidthOfBioTextView, height: 1200)
            let attributes = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: CGFloat(15))]
            let post = fs_posts[indexPath.item]
            let estimatedFrame = NSString(string: post.description).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            rc = CGSize(width: view.frame.width - 15, height: estimatedFrame.height + view.frame.width - 180 )
            break
            
        case CellType.MAP :
            let width = view.frame.width
            let height = view.frame.height
            rc = CGSize(width: width, height: height)
            break
            
        case CellType.BKMK :
            let approximateWidthOfBioTextView = view.frame.width
            let size = CGSize(width: approximateWidthOfBioTextView, height: 1200)
            let attributes = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: CGFloat(15))]
            let post = fs_posts[indexPath.item]
            let estimatedFrame = NSString(string: post.description).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            rc = CGSize(width: view.frame.width - 15 , height: estimatedFrame.height + view.frame.width - 60 )
            break
        }
        return rc
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    
    
}


