//
//  LocationCarasel.swift
//  Maple
//
//  Created by Murray Toews on 4/30/20.
//  Copyright © 2020 Murray Toews. All rights reserved.
//

import UIKit
import LBTATools
import MapKit

class LocationCell: LBTAListCell<MKMapItem> {
    
    override var item: MKMapItem! {
        didSet {
            label.text = item.name
            addressLabel.text = item.address()
        }
    }
    
    let label = UILabel(text: "Location", font: .boldSystemFont(ofSize: 16))
    
    let addressLabel = UILabel(text: "Address", numberOfLines: 0)
    
    override func setupViews() {
        backgroundColor = .white
        
        setupShadow(opacity: 0.2, radius: 5, offset: .zero, color: .black)
        layer.cornerRadius = 5
        
        // apply hstack first and alignment center for vertical aligment
        hstack(stack(label, addressLabel, spacing: 12).withMargins(.allSides(16)),
               alignment: .center)
    }
}

@available(iOS 13.0, *)
class LocationsCarouselController: LBTAListController<LocationCell, MKMapItem> {
    
    weak var mainController: MapBoxSingleLocalViewController?
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.clipsToBounds = false
        collectionView.backgroundColor = .clear
        
        let placemark = MKPlacemark(coordinate: .init(latitude: 10, longitude: 55))
        let dummyMapItem = MKMapItem(placemark: placemark)
        dummyMapItem.name = "Dummy location for example"
        self.items = [dummyMapItem]
    }
}

@available(iOS 13.0, *)
extension LocationsCarouselController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width - 64, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
}

