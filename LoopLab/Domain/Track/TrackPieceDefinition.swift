//
//  TrackPieceDefinition.swift
//  LoopLab
//

import simd

/// An axis-aligned bounding box in track-piece-local coordinates.
nonisolated struct TrackPieceBounds: Equatable, Sendable {
    let minimum: SIMD3<Float>
    let maximum: SIMD3<Float>

    var dimensions: SIMD3<Float> {
        maximum - minimum
    }

    var hasPositiveDimensions: Bool {
        let size = dimensions
        return size.x > 0 && size.y > 0 && size.z > 0
    }

    func contains(_ point: SIMD3<Float>, tolerance: Float = 0.0001) -> Bool {
        point.x >= minimum.x - tolerance
            && point.x <= maximum.x + tolerance
            && point.y >= minimum.y - tolerance
            && point.y <= maximum.y + tolerance
            && point.z >= minimum.z - tolerance
            && point.z <= maximum.z + tolerance
    }
}

/// Renderer-neutral instructions for constructing Phase 0 gray-box geometry.
nonisolated enum TrackPieceGeometryRecipe: Equatable, Sendable {
    case straight(length: Float, deckThickness: Float)
    case leftCurve(
        centerlineRadius: Float,
        sweepAngle: Float,
        deckThickness: Float
    )
    case startFinish(
        length: Float,
        deckThickness: Float,
        markerWidth: Float
    )
}

/// Immutable domain data describing one reusable type of track piece.
nonisolated struct TrackPieceDefinition: Sendable {
    let kind: TrackPieceKind
    let schemaVersion: Int
    let displayName: String
    let laneWidth: Float
    let bounds: TrackPieceBounds
    let sockets: [TrackSocket]
    let geometry: TrackPieceGeometryRecipe

    func socket(with role: TrackSocket.Role) -> TrackSocket? {
        sockets.first { $0.role == role }
    }
}
