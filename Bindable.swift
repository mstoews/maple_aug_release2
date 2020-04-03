//
//  Bindable.swift
//  Maple
//
//  Created by Murray Toews on 4/2/20.
//  Copyright © 2020 Murray Toews. All rights reserved.
//

import Foundation

class Bindable<T> {
    var value: T? {
        didSet {
            observer?(value)
        }
    }
    
    var observer: ((T?)->())?
    
    func bind(observer: @escaping (T?) ->()) {
        self.observer = observer
    }
    
}

