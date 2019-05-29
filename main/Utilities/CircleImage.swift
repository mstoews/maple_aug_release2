import SDWebImage
import CoreImage

extension UIImage {
    var circle: UIImage? {
        let square = CGSize(width: min(size.width, size.height), height: min(size.width, size.height))
        //let square = CGSize(width: 36, height: 36)
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = .scaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = square.width / 2
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContext(imageView.bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    func RBSquareImageTo(image: UIImage, size: CGSize) -> UIImage {
        return RBResizeImage(image: RBSquareImage(image: image), targetSize: size)
    }
    
    func RBSquareImage(image: UIImage) -> UIImage {
        let originalWidth  = image.size.width
        let originalHeight = image.size.height
        
        var edge: CGFloat
        if originalWidth > originalHeight {
            edge = originalHeight
        } else {
            edge = originalWidth
        }
        
        let posX = (originalWidth  - edge) / 2.0
        let posY = (originalHeight - edge) / 2.0
        
        let cropSquare = CGRect(x: posX, y:posY, width: edge, height: edge)
        
        let imageRef = image.cgImage?.cropping(to: cropSquare)
        return UIImage(cgImage: imageRef!, scale: edge, orientation: image.imageOrientation)
    }
    
    func RBResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        var heightRatio : CGFloat
        var widthRatio : CGFloat
        
        widthRatio  = targetSize.width  / image.size.width
        heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width : size.width * heightRatio, height : size.height * heightRatio)
        } else {
            newSize = CGSize(width : size.width * heightRatio, height : size.height * heightRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x:0, y:0,  width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    
    func resizeImage(_ dimension: CGFloat) -> UIImage {
        var width: CGFloat
        var height: CGFloat
        var newImage: UIImage
        
        
        let size = self.size
        let aspectRatio = size.width / size.height
        
        if aspectRatio > 1 {                            // Landscape image
            width = dimension
            height = dimension / aspectRatio
        } else {                                        // Portrait image
            height = dimension
            width = dimension * aspectRatio
        }
        
        if #available(iOS 10.0, *) {
            let renderFormat = UIGraphicsImageRendererFormat.default()
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: renderFormat)
            newImage = renderer.image { _ in
                self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            }
           
            var x : CGFloat
            var y : CGFloat
            var width : CGFloat
            var height : CGFloat
            
            x = 0.0
            y = 0.0
            width = 200.0
            height = 200.0
            let  crop  =  CGRect(x:x, y:y, width:width , height:height)
            newImage.cgImage?.cropping(to: crop)
            
        } else {
            UIGraphicsBeginImageContext(CGSize(width: width, height: height))
            self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        return newImage
    }
    
    
    static func circleImage(with url: URL, to imageView: UIImageView) {
        let urlString = url.absoluteString
        if let image = SDImageCache.shared().imageFromCache(forKey: urlString) {
            imageView.image = image
            return
        }
        SDWebImageDownloader.shared().downloadImage(with: url,
                                                    options: .highPriority, progress: nil) { image, _, error, _ in
                                                        if let error = error {
                                                            print(error)
                                                            return
                                                        }
                                                        if let image = image {
                                                            let circleImage = image.circle
                                                            SDImageCache.shared().store(circleImage, forKey: urlString, completion: nil)
                                                            imageView.image = circleImage
                                                        }
        }
    }
    
    static func circleButton(with url: URL, to button: UIBarButtonItem) {
        let urlString = url.absoluteString
        if let image = SDImageCache.shared().imageFromCache(forKey: urlString) {
            button.image = image.resizeImage(36)
            return
        }
        SDWebImageDownloader.shared().downloadImage(with: url, options: .highPriority, progress: nil) { image, _, _, _ in
            if let image = image {
                let circleImage = image.circle
                SDImageCache.shared().store(circleImage, forKey: urlString, completion: nil)
                button.image = circleImage?.resizeImage(36)
            }
        }
    }
}

