import Foundation
import CoreGraphics

struct GameMap: Identifiable, Decodable, Hashable {
    let uuid: String
    let displayName: String
    let narrativeDescription: String?
    let tacticalDescription: String?
    let coordinates: String?
    let displayIcon: URL?
    let listViewIcon: URL?
    let listViewIconTall: URL?
    let splash: URL?
    let backgroundImage: URL?
    let stylizedBackgroundImage: URL?
    let premierBackgroundImage: URL?
    let mapUrl: String?
    let xMultiplier: FlexDouble?
    let yMultiplier: FlexDouble?
    let xScalarToAdd: FlexDouble?
    let yScalarToAdd: FlexDouble?
    let callouts: [MapCallout]?

    var id: String { uuid }

    var xScale: Double { xMultiplier?.value ?? 0.00007 }
    var yScale: Double { yMultiplier?.value ?? -0.00007 }
    var xScalar: Double { xScalarToAdd?.value ?? 0 }
    var yScalar: Double { yScalarToAdd?.value ?? 0 }
}

struct MapCallout: Decodable, Hashable, Identifiable {
    let regionName: String?
    let superRegionName: String?
    let location: MapPoint?

    var id: String {
        "\(regionName ?? "?")|\(superRegionName ?? "?")|\(location?.x?.value ?? 0)|\(location?.y?.value ?? 0)"
    }

    /// World-space -> 0...1 minimap position using the API's own multipliers.
    func relativePosition(in map: GameMap) -> CGPoint {
        let x = (location?.x?.value ?? 0) * map.xScale + map.xScalar
        let y = (location?.y?.value ?? 0) * map.yScale + map.yScalar
        return CGPoint(x: min(max(x, 0), 1), y: min(max(y, 0), 1))
    }
}

struct MapPoint: Decodable, Hashable {
    let x: FlexDouble?
    let y: FlexDouble?
    let z: FlexDouble?
}
