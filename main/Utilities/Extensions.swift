//
//  Extensions.swift
//  InstagramFirebase
//
//  Created by Brian Voong on 3/18/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import UIKit
import Foundation

extension Notification.Name {
    static let pickersChanged = NSNotification.Name("pickersChanged")
}

extension Date {
    
    func timeAgoToDisplay() -> String {
        
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "SECOND"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "MIN"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "HOUR"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "DAY"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "WEEK"
        } else {
            quotient = secondsAgo / month
            unit = "MONTH"
        }
        
        return "\(quotient) \(unit)\(quotient == 1 ? "" : "S") AGO"
    }
    
}



extension UITextView {
    
    public convenience init(placeholder: String) {
        self.init()
        self.placeholder = placeholder
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textViewDidChange(notification:)),  name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(  self, selector: #selector(didKeyboardShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
    
    }
    

    @objc func didKeyboardShow(notification: Notification)
    {
        
    }
    
    @objc func textViewDidChange(notification: Notification) {
        
    }
    
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// The UITextView placeholder text
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    
    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    @objc public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = !self.text.isEmpty
        }
    }
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = !self.text.isEmpty
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
    }
    
}



extension UIViewController {
    func displaySpinner() -> UIView {
        let spinnerView = UIView.init(frame: view.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            self.view.addSubview(spinnerView)
        }
        return spinnerView
    }
    
    func removeSpinner(_ spinner: UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}

extension UILabel {
    var highlightedText: String? {
        get {
            return attributedText?.string
        }
        set {
            let color = highlightedTextColor ?? self.tintColor ?? UIColor.blue
            attributedText = newValue == nil ? nil : Highlighter(highlightAttrs: [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): color]).render(text: newValue!)
        }
    }
}

@objc public class Highlighter: NSObject {
    // MARK: Properties
    
    /// Visual attributes to apply to the highlights.
    @objc public var highlightAttrs: [NSAttributedString.Key: Any]
    
    /// Markup identifying the beginning of a highlight. Defaults to `<em>`.
    @objc public var preTag: String = "<em>"
    
    /// Markup identifying the end of a highlight. Defaults to `</em>`.
    @objc public var postTag: String = "</em>"
    
    /// Whether the markup is case sensitive. Defaults to `false`.
    @objc public var caseSensitive: Bool = false
    
    // MARK: Initialization
    
    /// Create a new highlighter with the specified text attributes for highlights.
    ///
    /// - parameter highlightAttrs: Text attributes to apply to highlights. The content must be suitable for use within
    ///   an `NSAttributedString`.
    ///
    @objc public init(highlightAttrs: [NSAttributedString.Key: Any]) {
        self.highlightAttrs = highlightAttrs
    }
    
    // MARK: Rendering
    
    /// Render the specified text.
    ///
    /// - parameter text: The marked up text to render.
    /// - returns: An atributed string with highlights outlined.
    ///
    @objc(renderText:)
    public func render(text: String) -> NSAttributedString {
        let newText = NSMutableString(string: text)
        var rangesToHighlight = [NSRange]()
        
        // Remove markup and identify ranges to highlight at the same time.
        while true {
            let matchBegin = newText.range(of: preTag, options: caseSensitive ? [] : [.caseInsensitive])
            if matchBegin.location != NSNotFound {
                newText.deleteCharacters(in: matchBegin)
                let range = NSRange(location: matchBegin.location, length: newText.length - matchBegin.location)
                let matchEnd = newText.range(of: postTag, options: .caseInsensitive, range: range)
                if matchEnd.location != NSNotFound {
                    newText.deleteCharacters(in: matchEnd)
                    rangesToHighlight.append(NSRange(location: matchBegin.location, length: matchEnd.location - matchBegin.location))
                }
            } else {
                break
            }
        }
        
        // Apply the specified attributes to the highlighted ranges.
        let attributedString = NSMutableAttributedString(string: String(newText))
        for range in rangesToHighlight {
            attributedString.addAttributes(highlightAttrs, range: range)
        }
        return attributedString
    }
}

extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }

    static func mainBlue() -> UIColor {
        return UIColor.rgb(red: 17, green: 154, blue: 237)
    }
    
    static func veryLightGray() -> UIColor {
        return UIColor.rgb(red: 240, green: 240, blue: 240)
    }
    
    static func themeColor() -> UIColor {
      return .white
    }
    
    static func buttonThemeColor() -> UIColor {
        let mapleThemeColor = UIColor.rgb(red: 199, green: 63, blue: 74)
        return mapleThemeColor
    }
    
    static func mainBlack() -> UIColor{
        return UIColor.rgb(red: 255, green: 255, blue: 255)
    }
    
    static func backGroundTheme() -> UIColor {
        return UIColor.rgb(red: 17, green: 154, blue: 200)
    }
    
    static func collectionBackGround() -> UIColor {
         return UIColor.rgb(red: 240, green: 240, blue: 240)
    }
    
    static func collectionCell()-> UIColor {
        return .white
    }
    
    
    /*
     
     Logo: FF0000
     Selected icon: FF0000
     Unselected icon: D2B48C
     Top bar: FFD700
     Tool bar: White (no color)
     Background: FFFAFA
     Follow & Unfollow button: FF0000
     */
    
}

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,  paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: 0).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: 0).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: 0).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: 0).isActive = true
        }
    }
    
}



extension UIColor {
    static func rgb(_ red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

extension UIView {
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
}


extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset =
            CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                    y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer =
            CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                    y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer,
                                                            in: textContainer,
                                                            fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}


