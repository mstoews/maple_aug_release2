//
//  PhotoSelectorController.swift
//  InstagramFirebase
//
//  Created by Murray Toews on 6/3/17.
//  Copyright © 2017 maple.com

import UIKit
import Photos


/*
 let croppingEnabled = true
 /// Provides an image picker wrapped inside a UINavigationController instance
 let imagePickerViewController = CameraViewController.imagePickerViewController(croppingEnabled: croppingEnabled) { [weak self] image, asset in
 // Do something with your image here.
 // If cropping is enabled this image will be the cropped version
 
 self?.dismiss(animated: true, completion: nil)
 }
 
 present(imagePickerViewController, animated: true, completion: nil)
 return false
 */


class PhotoSelectionController: UIViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
}


class PhotoSelectorController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    let headerId = "headerId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photo Selection"
        collectionView?.backgroundColor = .white
        setNavigationButtons()
        collectionView?.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(PhotoSelectorHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.allowsMultipleSelection = true
        fetchPhotos()
    }
    
    func didSelectPhoto(photoSelectedCell : PhotoSelectorCell)
    {
        print("Photo celled ... ")
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImage = images[indexPath.item]
        self.collectionView?.reloadData()
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
       
        
    }
    
    var selectedImage: UIImage?
    var images = [UIImage]()
    var assets = [PHAsset]()
    
    
    fileprivate func assetsFetchOptions() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 3000
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        return fetchOptions
    }
    
    fileprivate func fetchPhotos() {
        let allPhotos = PHAsset.fetchAssets(with: .image, options: assetsFetchOptions())
        
        DispatchQueue.global(qos: .background).async {
            allPhotos.enumerateObjects({ (asset, count, stop) in
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                    
                    if let image = image {
                        self.images.append(image)
                        self.assets.append(asset)
                        
                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                    }
                    
                    if count == allPhotos.count - 1 {
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                    }
                    
                })
                
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
    
    var header: PhotoSelectorHeader?
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! PhotoSelectorHeader
        
        self.header = header
    
        header.photoImageView.image = selectedImage
        
        print("Image was selected ...")
        
        if let selectedImage = selectedImage {
            if let index = self.images.index(of: selectedImage) {
                let selectedAsset = self.assets[index]

                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 600, height: 600)
                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .default, options: nil, resultHandler: { (image, info) in
                    header.photoImageView.image = image
                    
                })

            }
        }
        
        
        return header
    }
    
    /*
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        
        let cell = collectionView.cellForItem(at: indexPath as IndexPath)
        let centerCell = cell?.center
        
        if cell!.frame.size.width == cellWidth {
            cell?.frame.size.width = (cell?.frame.size.width)!/1.12
            cell?.frame.size.height = (cell?.frame.size.height)!/1.12
            cell?.center = centerCell!
            
            let imageView = UIImageView()
            imageView.image = MaterialIcon.check?.imageWithColor(MaterialColor.white)
            imageView.backgroundColor = MaterialColor.blue.accent2
            imageView.frame = CGRectMake(1, 1, 20, 20)
            imageView.layer.cornerRadius = imageView.frame.height/2
            imageView.clipsToBounds = true
            if indexPath.section == 0 {
                imageView.tag = indexPath.row+4000
            } else {
                imageView.tag = indexPath.row+5000
            }
            print("IMAGEVIEW TAG: ",imageView.tag)
            cell?.addSubview(imageView)                
        }
    }
   */
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = view.frame.width - 7
        width = width  / 4.0
        return CGSize(width: width, height: width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PhotoSelectorCell
        
        cell.photoImageView.image = images[indexPath.item]
        return cell
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    fileprivate func setNavigationButtons() {
        
        let image = UIImage(named: "Share")?.withRenderingMode(.alwaysOriginal)
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNext))
        button.tintColor = .red
        navigationItem.rightBarButtonItem = button
        
        let leftImage = UIImage(named: "cancel")?.withRenderingMode(.alwaysOriginal)
        let leftButton = UIBarButtonItem(image: leftImage, style: .plain, target: self, action: #selector(handleCancel))
        leftButton.tintColor = .red
        navigationItem.leftBarButtonItem = leftButton
    }
    
    @objc func handleNext() {
        let sharePhotoController = SharePhotoController()
        sharePhotoController.selectedImage = header?.photoImageView.image
        let navController = UINavigationController(rootViewController: sharePhotoController)
        present(navController, animated: true, completion: nil)
        //navigationController?.pushViewController(sharePhotoController, animated: true)
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
}
