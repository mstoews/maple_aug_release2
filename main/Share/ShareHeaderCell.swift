//
//  ShareHeaderCell.swift
//  Maple
//
//  Created by Murray Toews on 7/12/18.
//  Copyright © 2018 Murray Toews. All rights reserved.
//

import UIKit
import Firebase
import MaterialComponents

protocol ShareHeaderCellDelegate {
    func didHandleCamera()
    func didHandelLocation()
    func didHandleClear()
    
}

class ShareHeaderCell: MDCCardCollectionCell {
    
    var delegate: ShareHeaderCellDelegate?
    
    lazy var cameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_camera_white"), for: .normal)
        button.setTitle(" Whats Hot", for: .normal)
        button.addTarget(self, action: #selector(handleCamera), for: .touchUpInside)
        return button
    }()
    
    lazy var locationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_location_on_white"), for: .normal)
        button.setTitle(" Posts", for: .normal)
        button.addTarget(self, action: #selector(handleLocation), for: .touchUpInside)
        return button
    }()
    
    lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_favorite_white"), for: .normal)
        button.setTitle(" Posts", for: .normal)
        button.addTarget(self, action: #selector(handleClear), for: .touchUpInside)
        return button
    }()
    
    
    
    func resetButtons()
    {
       cameraButton.tintColor = UIColor.themeColor()
       clearButton.tintColor = UIColor.themeColor()
       locationButton.tintColor = UIColor.themeColor()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBottomToolbar()
    }
    
    @objc func handleCamera()
    {
        delegate?.didHandleCamera()
    }
    
    @objc func handleClear()
    {
        delegate?.didHandleClear()
    }
    
    @objc func handleLocation()
    {
         delegate?.didHandelLocation()
    }
    
    
    fileprivate func setupBottomToolbar() {
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor.darkGray
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor.lightGray
        
        let stackView = UIStackView(arrangedSubviews: [cameraButton,locationButton,clearButton])
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        stackView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 40)
        bottomDividerView.anchor(top: stackView.bottomAnchor,
                                 left: leftAnchor,
                                 bottom: nil,
                                 right:rightAnchor,
                                 paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        resetButtons()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}







