import UIKit
class CarouselFlowLayout: UICollectionViewFlowLayout {
    
    private var firstStupDone = false
    private let smallItemScale: CGFloat = 0.5
    private let smallItemAlpha: CGFloat = 0.2
    
    override func prepare() {
        super.prepare()
        if !firstStupDone {
            setup()
            firstStupDone = true
        }
    }
    
    private func setup() {
        scrollDirection = .horizontal
        minimumLineSpacing = -60
        itemSize = CGSize(width: collectionView!.bounds.width + minimumLineSpacing, height: collectionView!.bounds.height / 2)
        
        let inset = (collectionView!.bounds.width - itemSize.width) / 2
        collectionView!.contentInset = .init(top: 0, left: inset, bottom: 0, right: inset)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let allAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        for attributes in allAttributes {
            let collectionCenter = collectionView!.bounds.size.width / 2
            let offset = collectionView!.contentOffset.x
            let normalizedCenter = attributes.center.x - offset
            
            let maxDistance = itemSize.width + minimumLineSpacing
            let distanceFromCenter = min(collectionCenter - normalizedCenter, maxDistance)
            let ratio = (maxDistance - abs(distanceFromCenter)) / maxDistance
            
            let alpha = ratio * (1 - smallItemAlpha) + smallItemAlpha
            let scale = ratio * (1 - smallItemScale) + smallItemScale
            attributes.alpha = alpha
            
            let angleToSet = distanceFromCenter / (collectionView!.bounds.width / 2)
            var transform = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
            transform.m34 = 1.0 / 400
            transform = CATransform3DRotate(transform, angleToSet, 0, 1, 0)
            attributes.transform3D = transform
        }
        return allAttributes
    }
}