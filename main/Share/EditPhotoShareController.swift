//
//  EditPhotoShareController.swift
//  Maple
//
//  Created by Murray Toews on 6/13/19.
//  Copyright © 2019 Murray Toews. All rights reserved.
//

import UIKit
import Firebase
import Photos
import AssetsLibrary
import FirebaseUI
import AFNetworking
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
import os.log
import AlgoliaSearch
import InstantSearchCore
import MaterialComponents
import Gallery
import Lightbox
import AVFoundation
import AVKit
import SVProgressHUD
import CropViewController
import ActiveLabel


class EditPhotoController: SharePhotoController {
    
    var postId: String?
    
    
    let customImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Gallery.Config.VideoEditor.savesEditedVideoToLibrary = true
        Gallery.Config.initialTab = Gallery.Config.GalleryTab.imageTab
        Gallery.Config.tabsToShow = [Gallery.Config.GalleryTab.imageTab, Gallery.Config.GalleryTab.cameraTab]
        
        updateConstraints()
        navigationItem.title = "Edit Post"
        
        /***** Set up toasts *****/
        edgesForExtendedLayout = UIRectEdge()
        presentWindow = UIApplication.shared.keyWindow
        
        imageCollectionView.register(PostImageObject.self, forCellWithReuseIdentifier: imageCellId)
        locationCollectionView.register(MapCell.self, forCellWithReuseIdentifier: mapCellId)
        
        view.backgroundColor = UIColor.collectionCell()
        self.view.tintColor  = UIColor.buttonThemeColor()
        imageCollectionView.backgroundView = backGroundView
        
        Products.delegate = self
        Description.delegate = self
        //tableProductsView.delegate = self
        //tableProductsView.dataSource =  self
        
        setupImageAndTextViews()
        setNavigationButtons()
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.fetchUserWithUID(uid: uid, completion: { (user) in
            self.user = user
        })
        
        /****** Tap to dismiss KeyBoard ******/
        
        let tapImageCollectionView = UITapGestureRecognizer(target: self, action: #selector(imageCollectionViewTapped(tapGestureRecognizer: )))
        imageCollectionView.isUserInteractionEnabled = true
        imageCollectionView.addGestureRecognizer(tapImageCollectionView)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dissmissKeyboard)))
        /****** End Gestures           ******/
        
        
        /******  Algolia Search Products ******/
        //tableProductsView.register(SearchTableCell.self, forCellReuseIdentifier: searchTableCellId)
        //postSearcher = Searcher(index: AlgoliaManager.sharedInstance.posts, resultHandler: self.handleSearchResults)
        //postSearcher.params.hitsPerPage = 15
        //postSearcher.params.attributesToRetrieve = ["*" ]
        //postSearcher.params.attributesToHighlight = ["product"]
        //tableProductsView.tableHeaderView?.isHidden = true
        
        definesPresentationContext = true
        
        VIEW_SCROLL_HEIGHT? = 400.0
        print("viewDidLoad")
        
}
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        print("viewDidAppear")
        
        if let postId = postId {
            Firestore.fetchPostByPostId(postId: postId) { (post) in
                Firestore.fetchUserWithUID(uid: post.uid) { (user) in
                    self.Products.text = post.product
                    self.Description.text = post.description
                    for url in post.imageUrlArray {
                        print(url)
                        self.imageUrlArray.append(url)
                        let ci = CustomImageView()
                        ci.loadImage(urlString: url)
                        // self.customImageView.loadImage(urlString: url)
                        self.imageArray.append(ci.image!)
                        print("Number of images: \(self.imageArray.count)")
                        self.CellType = CT.PIC
                        self.imageCollectionView.reloadData()
                        
                    }
//                    self.CellType = CT.MAP
//                    self.locationCollectionView.reloadData()
                    
                }
                //self.locationCollectionView.reloadData()
                
            }
            
        }
    }
}

    
