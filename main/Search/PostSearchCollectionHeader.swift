//
//  PostSearchCollectionHeader.swift
//  maple_release
//
//  Created by Murray Toews on 2018/05/05.
//  Copyright © 2018 Murray Toews. All rights reserved.
//

import Foundation
import MaterialComponents



protocol SearchHeaderDelegate {
    func didSearchLocation()
    func didSearchUser()
    func didSearchProducts()
}


class PostSearchCollectionHeader: UICollectionViewCell  {
    
    var delegate: SearchHeaderDelegate?
    
    lazy var userButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_account_circle"), for: .normal)
        button.addTarget(self, action: #selector(handleUserButton), for: .touchUpInside)
        return button
    }()
    
    lazy var mapButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_location_on"), for: .normal)
        button.addTarget(self, action: #selector(handleMapButton), for: .touchUpInside)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    lazy var prdButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_shopping_cart"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        button.addTarget(self, action: #selector(handlePrdButton), for: .touchUpInside)
        return button
    }()
    
    
    func resetButtons()
    {
        userButton.tintColor = .gray
        prdButton.tintColor = .gray
        mapButton.tintColor = .gray
    }
    
    @objc func handleUserButton()
    {
        print("Search Users")
        resetButtons()
        userButton.tintColor = UIColor.themeColor()
        delegate?.didSearchUser()
    }
    
    
    @objc func handleMapButton()
    {
        print("Seach Locations")
        resetButtons()
        mapButton.tintColor = UIColor.themeColor()
        delegate?.didSearchLocation()
    }
    
    @objc func handlePrdButton() {
        print("Search Products")
        resetButtons()
        prdButton.tintColor = UIColor.themeColor()
        delegate?.didSearchProducts()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBottomToolbar()
    }
    
    fileprivate func setupBottomToolbar() {
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor.darkGray
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor.lightGray
        
        let stackView = UIStackView(arrangedSubviews: [  prdButton, mapButton, userButton])
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        stackView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 35)
        bottomDividerView.anchor(top: bottomAnchor,
                                 left: leftAnchor,
                                 bottom: nil,
                                 right:rightAnchor,
                                 paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        resetButtons()
        prdButton.tintColor = UIColor.themeColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
