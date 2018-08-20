//
//  CommentInputAccessoryView.swift
//  maple-release
//
//  Created by Murray Toews on 2018/01/07.
//  Copyright © 2018 Murray Toews. All rights reserved.
//
import UIKit



class UIImageEditFilter : UIImageView {
    
    var delegate: UIImageEditFilterDelegate?
    
    var lastURLUsedToLoadImage: String?
    
    func loadImage(urlString: String) {
        lastURLUsedToLoadImage = urlString
        
        self.image = nil
        
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        guard let url = URL(string: urlString) else { return }
        self.sd_setImage(with: url)
    }
    
    fileprivate let productImage : UIImageView = {
       let iv = UIImageView()
       return iv
    }()

    fileprivate let filterButton: UIButton = {
        let sb = UIButton(type: .system)
        sb.setImage(#imageLiteral(resourceName: "ic_filter"), for: .normal)
        sb.setTitleColor(.black, for: .normal)
        sb.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        sb.addTarget(self, action: #selector(handleFilter), for: .touchUpInside)
        return sb
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_delete"), for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        return button
    }()
    
    @objc func handleFilter()
    {
     print("Filter")
     delegate?.didHandleFilter()
        
    }
    
    @objc func handleDelete()
    {
         print("handle delete from image")
       delegate?.didHandleDelete()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        autoresizingMask = .flexibleHeight
        
        backgroundColor = .white
        
        addSubview(filterButton)
        addSubview(deleteButton)
        addSubview(productImage)
        
        productImage.anchor(top: topAnchor , left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        deleteButton.anchor(top: topAnchor, left: nil, bottom: nil , right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 0)
        filterButton.anchor(top: deleteButton.bottomAnchor, left: nil, bottom: nil, right: rightAnchor,paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 0)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


protocol CommentInputAccessoryViewDelegate {
    func didSubmit(for comment: String)
}


class CommentInputAccessoryView: UIView {
    
    var delegate: CommentInputAccessoryViewDelegate?
    
    func clearCommentTextField() {
        commentTextView.text = nil
        commentTextView.showPlaceholderLabel()
    }
    
    fileprivate let commentTextView: CommentInputTextView = {
        let tv = CommentInputTextView()
        tv.isScrollEnabled = false
        tv.font = UIFont.systemFont(ofSize: 18)
        return tv
    }()
    
    fileprivate let submitButton: UIButton = {
        let sb = UIButton(type: .system)
        sb.setTitle("Submit", for: .normal)
        sb.setTitleColor(.black, for: .normal)
        sb.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        sb.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return sb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 1
        autoresizingMask = .flexibleHeight
        
        backgroundColor = .white
        
        addSubview(submitButton)
        submitButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 50)
        
        addSubview(commentTextView)
        // 3
        if #available(iOS 11.0, *) {
            commentTextView.anchor(top: topAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: submitButton.leftAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 0, height: 0)
        } else {
            // Fallback on earlier versions
             commentTextView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: submitButton.leftAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 0, height: 0)
            
        }
        
        setupLineSeparatorView()
    }
    
    // 2
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    fileprivate func setupLineSeparatorView() {
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        addSubview(lineSeparatorView)
        lineSeparatorView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    @objc func handleSubmit() {
        guard let commentText = commentTextView.text else { return }
        delegate?.didSubmit(for: commentText)
        clearCommentTextField() 
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


/*
 

 2018-08-08 07:21:31.331417+0900 Maple[3305:1939472] [ImageManager] Unable to load image data, /var/mobile/Media/DCIM/100APPLE/IMG_0223.HEIC
 2018-08-08 07:21:31.524889+0900 Maple[3305:1936360] The behavior of the UICollectionViewFlowLayout is not defined because:
 2018-08-08 07:21:31.524940+0900 Maple[3305:1936360] the item height must be less than the height of the UICollectionView minus the section insets top and bottom values, minus the content insets top and bottom values.
 2018-08-08 07:21:31.525074+0900 Maple[3305:1936360] The relevant UICollectionViewFlowLayout instance is <UICollectionViewFlowLayout: 0x10fde8e00>, and it is attached to <UICollectionView: 0x10a0e9e00; frame = (0 0; 347 243); clipsToBounds = YES; gestureRecognizers = <NSArray: 0x1d0656d40>; layer = <CALayer: 0x1d0e3a0e0>; contentOffset: {0, 0}; contentSize: {2, 243}; adjustedContentInset: {0, 0, 0, 0}> collection view layout: <UICollectionViewFlowLayout: 0x10fde8e00>.
 2018-08-08 07:21:31.525096+0900 Maple[3305:1936360] Make a symbolic breakpoint at UICollectionViewFlowLayoutBreakForInvalidSizes to catch this in the debugger.
 2018-08-08 07:21:31.528012+0900 Maple[3305:1936360] [Graphics] UIColor created with component values far outside the expected range. Set a breakpoint on UIColorBreakForOutOfRangeColorComponents to debug. This message will only be logged once.
 2018-08-08 07:21:32.099857+0900 Maple[3305:1936360] [framework] CUICatalog: Invalid asset name supplied: ''
 2018-08-08 07:21:32.099900+0900 Maple[3305:1936360] [framework] CUICatalog: Invalid asset name supplied: ''
 Post Hits : 0
 Post Hits : 0
 2018-08-08 07:21:32.149737+0900 Maple[3305:1936360] [LayoutConstraints] Unable to simultaneously satisfy constraints.
 Probably at least one of the constraints in the following list is one you don't want.
 Try this:
 (1) look at each constraint and try to figure out which you don't expect;
 (2) find the code that added the unwanted constraint or constraints and fix it.
 (
 "<NSLayoutConstraint:0x1d469e000 UICollectionView:0x1099c4200.width == 336   (active)>",
 "<NSLayoutConstraint:0x1d4699eb0 H:|-(0)-[UICollectionView:0x1099c4200](LTR)   (active, names: '|':MDCCard:0x11fa1aca0 )>",
 "<NSLayoutConstraint:0x1d4880cd0 UICollectionView:0x1099c4200.right == MDCCard:0x11fa1aca0.right   (active)>",
 "<NSLayoutConstraint:0x1d4899f50 H:|-(7)-[MDCCard:0x1114f1870](LTR)   (active, names: '|':UIView:0x1114de940 )>",
 "<NSLayoutConstraint:0x1d489afe0 MDCCard:0x1114f1870.right == UIView:0x1114de940.right - 7   (active)>",
 "<NSLayoutConstraint:0x1d489b080 H:|-(7)-[MDCCard:0x11fa1aca0](LTR)   (active, names: '|':MDCCard:0x1114f1870 )>",
 "<NSLayoutConstraint:0x1d489af40 MDCCard:0x11fa1aca0.right == MDCCard:0x1114f1870.right - 7   (active)>",
 "<NSLayoutConstraint:0x1d4a898d0 'UIView-Encapsulated-Layout-Width' UIView:0x1114de940.width == 375   (active)>"
 )
 
 Will attempt to recover by breaking constraint
 <NSLayoutConstraint:0x1d469e000 UICollectionView:0x1099c4200.width == 336   (active)>
 

 */

