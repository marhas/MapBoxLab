import Mapbox
import UIKit

class MapViewController: UIViewController {

    private var mapView: MGLMapView!
    private var streetsShader: ParkableStreetsShader?
    private let homeLocation = CLLocationCoordinate2D(latitude: 59.349153, longitude: 18.112922)
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MGLMapView(frame: view.bounds)
        mapView.delegate = self
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.allowsZooming = true
        view.addSubview(mapView)
        setupCenterButton()
    }

    private func setupCenterButton() {
        let centerButton = createButton(title: "CENTER", action: #selector(centerMap))
        mapView.addSubview(centerButton)
        centerButton.rightAnchor.constraint(equalTo: mapView.rightAnchor, constant: -20).isActive = true
        centerButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -20).isActive = true

        let zoomInButton = createButton(title: "+", action: #selector(zoomIn))
        mapView.addSubview(zoomInButton)
        zoomInButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -20).isActive = true
        zoomInButton.rightAnchor.constraint(equalTo: centerButton.leftAnchor, constant: -20).isActive = true

        let zoomOutButton = createButton(title: "-", action: #selector(zoomOut))
        mapView.addSubview(zoomOutButton)
        zoomOutButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -20).isActive = true
        zoomOutButton.rightAnchor.constraint(equalTo: zoomInButton.leftAnchor, constant: -20).isActive = true
    }

    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc
    private func centerMap() {
        mapView.setCenter(homeLocation, zoomLevel: 16, direction: 0, animated: true) {
            print("Map centered on \(self.homeLocation)")
        }
    }

    @objc
    private func zoomIn() {
        mapView.setZoomLevel(mapView.zoomLevel + 1, animated: true)
    }

    @objc
    private func zoomOut() {
        mapView.setZoomLevel(mapView.zoomLevel - 1, animated: true)
    }
}

extension MapViewController: MGLMapViewDelegate {

    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        streetsShader = ParkableStreetsShader(mapView: mapView, style: style)
        print("Finished loading style")
        mapView.setCenter(homeLocation, zoomLevel: 16, direction: 0, animated: true) {
            self.streetsShader?.update()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.streetsShader?.update()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.streetsShader?.update()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.streetsShader?.update()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.streetsShader?.update()
                        }
                    }
                }
            }
        }
    }

    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        print("Finished loading map")
    }

    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        streetsShader?.update()
    }
}
