//
//  ShareSettingsController.swift
//  Maple
//
//  Created by Murray Toews on 7/12/18.
//  Copyright © 2018 Murray Toews. All rights reserved.
//

import Foundation
import UIKit


class ShareSetting: NSObject {
    let name: ShareSettingName
    let imageName: String
    
    init(name: ShareSettingName, imageName: String) {
        self.name = name
        self.imageName = imageName
    }
}


enum ShareSettingName: String {
    case Cancel = "Close"
    case Settings = "Picture"
    case Navigation = "Navigate"
}


class ShareShowSettings: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let blackView = UIView()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    let cellId = "cellId"
    let cellHeight: CGFloat = 50
    
    let shareSettings: [ShareSetting] = {
        let settingsSetting = ShareSetting(name: .Settings, imageName: "ic_shopping_cart")
        
        let cancelSetting = ShareSetting(name: .Cancel, imageName: "ic_cancel")
        
        let navigation = ShareSetting(name: .Navigation, imageName : "ic_navigation")
        
        return [settingsSetting,
                navigation,
                cancelSetting]
    }()
    
    var homeController: SharePhotoController?
    var headerView: UserProfileHeader?
    let pictureCellHeight = CGFloat(250.0)
    
    func showSettings() {
        //show menu
        
        if let window = UIApplication.shared.keyWindow {
            
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            window.addSubview(blackView)
            
            window.addSubview(collectionView)
            
            let height: CGFloat = CGFloat(shareSettings.count) * cellHeight + pictureCellHeight
            let y = window.frame.height - height
            collectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackView.alpha = 1
                
                self.collectionView.frame = CGRect(x: 0, y: y, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                
            }, completion: nil)
        }
    }
    
    @objc func handleDismiss(_ setting: ShareSetting) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.blackView.alpha = 0
            
            if let window = UIApplication.shared.keyWindow {
                self.collectionView.frame = CGRect(x: 0, y: window.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }
            
        }) { (completed: Bool) in
            if setting.name != .Cancel {
                //self.homeController?.showControllerForSetting(setting)
            }
        }
    }
    
     let headerCellId = "headerCellId"
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shareSettings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ShareSettingCell
        
        let setting = shareSettings[indexPath.item]
        cell.setting = setting
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize(width: collectionView.frame.width, height: cellHeight)
        
        if indexPath.item == 0 {
            size = CGSize(width: collectionView.frame.width, height: pictureCellHeight)
        }
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let share = self.shareSettings[indexPath.item]
        handleDismiss(share)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerCellId , for: indexPath) as! UserProfileHeader
        if indexPath.section == 0 {
            header.inkView.removeFromSuperview()
            headerView = header
            //headerView?.userView = self.user
            //headerView?.delegate = self
            return header
        }
        //header.userView = self.user
        //header.delegate = self
        return header
    }
    
    override init() {
        super.init()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ShareSettingCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerCellId)
    }
    
}

