import UIKit

// Stub — Mapbox navigation SDK not installed.
protocol MapPostDelegate {
    func didTapNavigation(navigation: NavigationStruct)
}

class MapPostViewController: UIViewController {
    var delegate: MapPostDelegate?
    var nav: NavigationStruct?
}
