//
//  TrackSocketMarkerFactory.swift
//  LoopLab
//

import RealityKit
import UIKit

/// Generates visible, non-authoritative socket markers from domain poses.
@MainActor
enum TrackSocketMarkerFactory {
    private static let markerRadius: Float = 0.045
    private static let directionLength: Float = 0.14
    private static let markerHeight: Float = 0.07

    static func makeMarker(
        for socket: TrackSocket,
        reference: TrackSocketReference
    ) -> Entity {
        let root = Entity()
        root.name = entityName(for: reference)
        root.position = socket.position + SIMD3(0, markerHeight, 0)
        root.orientation = socket.orientation

        let material = SimpleMaterial(
            color: socket.role == .entry
                ? UIColor.systemOrange
                : UIColor.systemCyan,
            roughness: 0.7,
            isMetallic: false
        )
        let center = ModelEntity(
            mesh: .generateSphere(radius: markerRadius),
            materials: [material]
        )
        center.name = "socket-center"
        root.addChild(center)

        let direction = ModelEntity(
            mesh: .generateBox(
                size: SIMD3(
                    markerRadius * 0.7,
                    markerRadius * 0.7,
                    directionLength
                )
            ),
            materials: [material]
        )
        direction.name = "socket-outward-direction"
        direction.position.z = directionLength / 2
        root.addChild(direction)

        return root
    }

    static func entityName(
        for reference: TrackSocketReference
    ) -> String {
        "socket-\(reference.pieceID.rawValue)-\(reference.socketID.rawValue)"
    }
}
