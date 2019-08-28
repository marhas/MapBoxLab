import Foundation
import CoreLocation
import Mapbox

class StreetsShader {

    let mapView: MGLMapView
    let roadLayers: Set<String> = [
        "tunnel-street-minor-low",
        "tunnel-street-minor-case",
        "tunnel-street-minor",
        "road-path-bg",
        //        "road-steps-bg",
        "road-minor-low",
        "road-street-low",
        "road-minor-case",
        "road-street-case",
        "road-secondary-tertiary-case",
        "road-primary-case",
        "road-major-link-case",
        "road-motorway-trunk-case",
        "road-path",
        //        "road-steps",
        "road-major-link",
        //        "road-polygon",
        "road-minor",
        "road-street",
        "road-secondary-tertiary",
        "road-primary",
        "road-motorway-trunk",
        "bridge-street-minor-low",
        "bridge-street-minor-case",
        "bridge-street-minor"
    ]
    private let parkableStreetsShadingLayerIdentifier = "parkableStreetShadingLayerIdentifier"
    private let parkableStreetsSourceIdentifier = "parkableStreetSourceIdentifier"
    private let selectedStreetShadingLayerIdentifier = "selectedStreetShadingLayerIdentifier"
    private let selectedStreetSourceIdentifier = "selectedStreetSourceIdentifier"
    private let identifierOfLayerToColor = "admin-2-boundaries-dispute"

    private var parkableStreetsSource: MGLShapeSource!
    private var selectedStreetSource: MGLShapeSource!
    private var parkableStreetsLayer: MGLLineStyleLayer?
    private var selectedStreetLayer: MGLLineStyleLayer?

    var centerOfLastFetchedArea: CLLocationCoordinate2D?

    private let coverageAreaRadiusMeters = 100.0

    init(mapView: MGLMapView, style: MGLStyle) {
        self.mapView = mapView
        prepareLayers(style: style)
    }

    func update() {
        fetchParkableStreets()
    }

    private var shadingLayersHidden: Bool = false {
        didSet {
            parkableStreetsLayer?.isVisible = shadingLayersHidden
            selectedStreetLayer?.isVisible = shadingLayersHidden
        }
    }

    private func fetchParkableStreets() {
        //        let visibleFeatures: [MGLShape] = mapView.visibleFeatures(in: mapView.bounds, styleLayerIdentifiers: roadLayers).compactMap { $0 as? MGLShape }
        let visibleFeatures: [MGLShape] = mapView.visibleFeatures(in: mapView.bounds, styleLayerIdentifiers: roadLayers, predicate: NSPredicate(format: "type != %@", "footway")).compactMap { $0 as? MGLShape }
        let extendedRect = mapView.bounds.insetBy(dx: -500, dy: -500)
        let visibleFeaturesInExtendedRect: [MGLShape] = mapView.visibleFeatures(in: extendedRect, styleLayerIdentifiers: roadLayers, predicate: NSPredicate(format: "type != %@", "footway")).compactMap { $0 as? MGLShape }
        self.parkableStreetsSource.shape = MGLShapeCollectionFeature(shapes: visibleFeatures)
        print("Number of visible features: \(visibleFeatures.count) in bounds: \(mapView.bounds)")
        print("Number of visible features in extended rect: \(visibleFeaturesInExtendedRect.count) in bounds: \(extendedRect)")
    }

    private func prepareLayers(style: MGLStyle) {
        parkableStreetsSource = MGLShapeSource(identifier: parkableStreetsSourceIdentifier, features: [], options: nil)
        style.addSource(parkableStreetsSource)
        selectedStreetSource = MGLShapeSource(identifier: selectedStreetSourceIdentifier, features: [], options: nil)
        style.addSource(selectedStreetSource)

        let parkableStreetLayer = createParkableStreetsLayer(source: parkableStreetsSource)
        let selectedStreetLayer = createSelectedStreetLayer(source: selectedStreetSource)
        if let layerToColor = style.layer(withIdentifier: identifierOfLayerToColor) {
            style.insertLayer(parkableStreetLayer, below: layerToColor)
            style.insertLayer(selectedStreetLayer, above: parkableStreetLayer)
        } else {
            style.addLayer(parkableStreetLayer)
            style.addLayer(selectedStreetLayer)
        }
    }

    private func createParkableStreetsLayer(source: MGLShapeSource) -> MGLLineStyleLayer {
        let layer = MGLLineStyleLayer(identifier: parkableStreetsShadingLayerIdentifier, source: source)
        layer.lineColor = NSExpression(forConstantValue: UIColor.purple)
        layer.lineWidth = NSExpression(forConstantValue: 6)
        layer.lineJoin = NSExpression(forConstantValue: "round")
        layer.lineCap = NSExpression(forConstantValue: "round")
        return layer
    }

    private func createSelectedStreetLayer(source: MGLShapeSource) -> MGLLineStyleLayer {
        let layer = MGLLineStyleLayer(identifier: selectedStreetShadingLayerIdentifier, source: source)
        layer.lineColor = NSExpression(forConstantValue: UIColor.yellow)
        layer.lineWidth = NSExpression(forConstantValue: 8)
        layer.lineJoin = NSExpression(forConstantValue: "round")
        layer.lineCap = NSExpression(forConstantValue: "round")
        return layer
    }

}
