//
//  BaseCell.swift
//  Maple
//
//  Created by Murray Toews on 2019/05/29.
//  Copyright © 2019 Murray Toews. All rights reserved.
//

import UIKit
import MaterialComponents


class BaseCell: MDCCardCollectionCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
