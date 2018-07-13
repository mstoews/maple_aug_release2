//
//  ImagesViewController.swift
//  maple-release
//
//  Created by Murray Toews on 3/26/18.
//  Copyright © 2018 Murray Toews. All rights reserved.
//

import Alamofire
import AlamofireImage
import Foundation
import UIKit


class ImageViewController : UIViewController {
    var gravatar: Gravatar!
    var imageView: UIImageView!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpInstanceProperties()
        setUpImageView()
    }
    
    // MARK: - Private - Setup Methods
    
    private func setUpInstanceProperties() {
        title = gravatar.email
        edgesForExtendedLayout = UIRectEdge()
        view.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
    }
    
    private func setUpImageView() {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        let URL = gravatar.url(size: view.bounds.size.width)
        
        imageView.af_setImage(
            withURL: URL,
            placeholderImage: nil,
            filter: CircleFilter(),
            imageTransition: .flipFromBottom(0.5)
        )
        
        view.addSubview(imageView)
        
        imageView.frame = view.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}


class ImageCell : UICollectionViewCell {
    class var ReuseIdentifier: String { return "org.alamofire.identifier.\(type(of: self))" }
    let imageView: UIImageView
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        imageView = {
            let imageView = UIImageView(frame: frame)
            
            imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            imageView.contentMode = .center
            imageView.clipsToBounds = true
            
            return imageView
        }()
        
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        
        imageView.frame = contentView.bounds
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    
    func configureCell(with URLString: String, placeholderImage: UIImage) {
        let size = imageView.frame.size
        
        imageView.af_setImage(
            withURL: URL(string: URLString)!,
            placeholderImage: placeholderImage,
            filter: AspectScaledToFillSizeWithRoundedCornersFilter(size: size, radius: 20.0),
            imageTransition: .crossDissolve(0.2)
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.af_cancelImageRequest()
        imageView.layer.removeAllAnimations()
        imageView.image = nil
    }
}


class ImagesViewController: UIViewController {
    lazy var gravatars: [Gravatar] = []
    
    lazy var placeholderImage: UIImage = {
        let image = UIImage(named: "windows")!
        return image
    }()
    
    var collectionView: UICollectionView!
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpInstanceProperties()
        setUpCollectionView()
    }
    
    // MARK: Private - Setup
    
    private func setUpInstanceProperties() {
        title = "Random Images"
        
        for _ in 1...1_000 {
            let gravatar = Gravatar(
                emailAddress: UUID().uuidString,
                defaultImage: Gravatar.DefaultImage.identicon, forceDefault: true
            )
            
            gravatars.append(gravatar)
        }
    }
    
    private func setUpCollectionView() {
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor.white
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.ReuseIdentifier)
        
        view.addSubview(self.collectionView)
        
        collectionView.frame = self.view.bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    fileprivate func sizeForCollectionViewItem() -> CGSize {
        let viewWidth = view.bounds.size.width
        
        var cellWidth = (viewWidth - 4 * 8) / 3.0
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            cellWidth = (viewWidth - 7 * 8) / 6.0
        }
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
}

// MARK: - UICollectionViewDataSource

extension ImagesViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gravatars.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImageCell.ReuseIdentifier,
            for: indexPath
            ) as! ImageCell
        
        let gravatar = gravatars[(indexPath as NSIndexPath).row]
        
        cell.configureCell(
            with: gravatar.url(size: sizeForCollectionViewItem().width).absoluteString,
            placeholderImage: placeholderImage
        )
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ImagesViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return sizeForCollectionViewItem()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 8.0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 8.0
    }
}

// MARK: - UICollectionViewDelegate

extension ImagesViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let gravatar = self.gravatars[(indexPath as NSIndexPath).row]
        
        let imageViewController = ImageViewController()
        imageViewController.gravatar = gravatar
        
        self.navigationController?.pushViewController(imageViewController, animated: true)
    }
}

