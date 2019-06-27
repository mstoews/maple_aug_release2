import Foundation
import UIKit

class SearchCollectionLayout: UICollectionViewFlowLayout {
    
    fileprivate var numberOfColumns: Int = 3
    
    fileprivate var cellPadding: CGFloat = 3
    
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    
    private var headerAttributesCache: Array<UICollectionViewLayoutAttributes> = []
    
    fileprivate var contentWidth: CGFloat {
        
        guard let collectionView = collectionView else {
            
            return 0
            
        }
        
        let insets = collectionView.contentInset
        
        return collectionView.bounds.width - (insets.left + insets.right) - (cellPadding * (CGFloat(numberOfColumns) - 1))
        
    }
    
    fileprivate var contentHeight: CGFloat = 0
    
    
    override var collectionViewContentSize: CGSize {
        
        return CGSize(width: contentWidth, height: contentHeight )
        
    }
    
    func cleanCache() {
        cache.removeAll()
    }
    
    override func prepare() {
        
        //guard  headerAttributesCache.isEmpty else { return }
        
        
        let frame: CGRect
        
        guard  let collectionView = collectionView else {

            return

        }
        
        if scrollDirection == .vertical {
            frame = CGRect(x: 0, y: 0, width: contentWidth, height: 40)
        } else {
            frame = CGRect(x: 0, y: 0, width: 40, height: contentWidth)
        }
        let headerLayoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: IndexPath(item: 0, section: 0))
        headerLayoutAttributes.frame = frame
        
        headerAttributesCache.append(headerLayoutAttributes)
        
        cleanCache()
        
        let itemsPerRow: UInt = 3
        
        let normalColumnWidth: CGFloat = contentWidth / CGFloat(itemsPerRow)
        
        let normalColumnHeight: CGFloat = normalColumnWidth
        
        let featuredColumnWidth: CGFloat = (normalColumnWidth * 2) + cellPadding
        
        let featuredColumnHeight: CGFloat = featuredColumnWidth
        
        var xOffsets: [CGFloat] = [CGFloat]()
        
        for item in 0..<6 {
            
            let multiplier = item % 3
            
            let xPos = CGFloat(multiplier) * (normalColumnWidth + cellPadding)
            
            xOffsets.append(xPos)
            
        }
        
        xOffsets.append(0.0)
        
        for _ in 0..<2 {
            
            xOffsets.append(featuredColumnWidth + cellPadding)
            
        }
        
        var yOffsets: [CGFloat] = [CGFloat]()
        
        for item in 0..<9 {
            
            var _yPos = floor(Double(item / 3)) * (Double(normalColumnHeight) + Double(cellPadding))
            
            if item == 8 {
                
                _yPos += (Double(normalColumnHeight) + Double(cellPadding))
                
            }
            
            yOffsets.append(CGFloat(_yPos))
            
        }
        
        let numberOfItemsPerSection: UInt = 9
        
        let heightOfSection: CGFloat = 4 * normalColumnHeight + (4 * cellPadding)
        
        var itemInSection: Int = 0
        
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            
            let xPos = xOffsets[itemInSection]
            
            let multiplier: Double = floor(Double(item) / Double(numberOfItemsPerSection))
            
            let yPos = yOffsets[itemInSection] + (heightOfSection * CGFloat(multiplier))
            
            var cellWidth = normalColumnWidth
            
            var cellHeight = normalColumnHeight
            
            if (itemInSection + 1) % 7 == 0 && itemInSection != 0 {
                
                cellWidth = featuredColumnWidth
                
                cellHeight = featuredColumnHeight
                
            }
            
            let frame = CGRect(x: xPos, y: yPos, width: cellWidth, height: cellHeight)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            attributes.frame = frame
            
            cache.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            
            itemInSection = itemInSection < (numberOfItemsPerSection - 1) ? (itemInSection + 1) : 0
            
        }
        
    }
    
  
    override func initialLayoutAttributesForAppearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard elementKind == UICollectionView.elementKindSectionHeader else { return nil }
        return headerAttributesCache.first {
            $0.indexPath == elementIndexPath
        }
    }
    

    func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        var attributes = [UICollectionViewLayoutAttributes]()
        
        let sectionsCount = self.collectionView!.dataSource!.numberOfSections!(in: self.collectionView!)
        for section in 0..<sectionsCount {
            /// add header
            attributes.append(self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: NSIndexPath(item: 0, section: section) as IndexPath)!)
            
            let itemsCount = self.collectionView!.numberOfItems(inSection: section)
            for item in 0..<itemsCount {
                let indexPath = NSIndexPath(item: item, section: section)
                attributes.append(self.layoutAttributesForItem(at: indexPath as IndexPath)!)
            }
        }
        
        return attributes
    }
    
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            
            
            if attributes.frame.intersects(rect) {
                
                visibleLayoutAttributes.append(attributes)
                
            }
            
        }
        
        return visibleLayoutAttributes
        
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        return cache[indexPath.item]
        
    }
    
    
}
