//
//  ShrineInkOverlay.swift
//  maple_release
//
//  Created by Murray Toews on 2018/05/23.
//  Copyright © 2018 Murray Toews. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialInk

class ShrineInkOverlay: UIView, MDCInkTouchControllerDelegate {
    
    fileprivate var inkTouchController: MDCInkTouchController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let cyan = UIColor(red: 22 / 255, green: 240 / 255, blue: 240 / 255, alpha: 0.2)
        self.inkTouchController = MDCInkTouchController(view:self)
        self.inkTouchController!.defaultInkView.inkColor = cyan
        self.inkTouchController!.addInkView()
        self.inkTouchController!.delegate = self
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}
