//
//  Helper.swift
//  Maple
//
//  Created by Murray Toews on 2019/07/03.
//  Copyright © 2019 Murray Toews. All rights reserved.
//

import JJFloatingActionButton
import UIKit

internal struct Helper {
    static func showAlert(for item: JJActionItem) {
        showAlert(title: item.titleLabel.text, message: "Item tapped!")
    }
    
    static func showAlert(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    static var rootViewController: UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController
    }
}

