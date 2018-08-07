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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


