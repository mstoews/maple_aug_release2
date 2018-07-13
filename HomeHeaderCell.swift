//
//  HomeHeaderCell.swift
//  maple-release
//
//  Created by Murray Toews on 1/9/18.
//  Copyright © 2018 Murray Toews. All rights reserved.
//

import UIKit
import Firebase
import MaterialComponents

protocol HomeHeaderCellDelegate {
    func didShowTopUsers()
    func didShowFollowersPosts()
    
}

class HomeHeaderCell: MDCCardCollectionCell {
    
    var delegate: HomeHeaderCellDelegate?
    
    lazy var topUsersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_whatshot"), for: .normal)
        button.setTitle(" Whats Hot", for: .normal)
        button.addTarget(self, action: #selector(handleTopUsersButton), for: .touchUpInside)
        return button
    }()
    
    lazy var followPostsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_favorite"), for: .normal)
        button.setTitle(" Posts", for: .normal)
        button.addTarget(self, action: #selector(handleFollowPostsButton), for: .touchUpInside)
        return button
    }()
    
    func resetButtons()
    {
        topUsersButton.tintColor = UIColor(white: 0, alpha: 0.2)
        followPostsButton.tintColor = UIColor(white: 0, alpha: 0.2)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBottomToolbar()
    }
    
    @objc func handleFollowPostsButton()
    {
        print("Search Occation")
        resetButtons()
        followPostsButton.tintColor = UIColor.themeColor()
        delegate?.didShowFollowersPosts()
    }
    
    
    @objc func handleTopUsersButton()
    {
        print("Seach Locations")
        resetButtons()
        topUsersButton.tintColor = UIColor.themeColor()
        delegate?.didShowTopUsers()
    }
    
    
    fileprivate func setupBottomToolbar() {
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor.darkGray
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor.lightGray
        
        let stackView = UIStackView(arrangedSubviews: [  followPostsButton,topUsersButton])
        
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
        handleFollowPostsButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}






