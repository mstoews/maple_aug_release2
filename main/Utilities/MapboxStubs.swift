import UIKit
import CoreLocation

// Stub types replacing the Mapbox SDK (not installed).
// MapViewCell and related code reference these types; they compile but map views won't render.

protocol MGLMapViewDelegate: AnyObject {}

class MGLMapView: UIView {
    var styleURL: URL?
    weak var delegate: MGLMapViewDelegate?

    init(frame: CGRect, styleURL: URL?) {
        super.init(frame: frame)
        self.styleURL = styleURL
    }

    required init?(coder: NSCoder) { super.init(coder: coder) }

    func addAnnotation(_ annotation: MGLPointAnnotation) {}
    func selectAnnotation(_ annotation: MGLPointAnnotation, animated: Bool) {}
    func setCenter(_ coordinate: CLLocationCoordinate2D, zoomLevel: Double, animated: Bool) {}
    func setCenter(_ coordinate: CLLocationCoordinate2D, zoomLevel: Double, direction: CLLocationDirection, animated: Bool) {}
}

class MGLPointAnnotation: NSObject {
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var title: String?
    var subtitle: String?
}
