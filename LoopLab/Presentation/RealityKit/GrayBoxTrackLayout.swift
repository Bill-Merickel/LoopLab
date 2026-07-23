//
//  GrayBoxTrackLayout.swift
//  LoopLab
//

import RealityKit

/// Produces a deterministic tabletop arrangement for inspecting Phase 0 pieces.
@MainActor
enum GrayBoxTrackLayout {
    static let rootEntityName = "gray-box-track-preview"

    private static let gap: Float = 0.3
    private static let tabletopScale: Float = 0.35
    private static let tabletopPosition = SIMD3<Float>(0, -0.45, -1.2)

    static func makeRootEntity() throws -> Entity {
        let root = Entity()
        root.name = rootEntityName

        var cursorX: Float = 0
        var pieces: [Entity] = []

        for definition in TrackPieceCatalog.phase0 {
            let piece = try TrackPieceEntityFactory.makeEntity(for: definition)
            let bounds = definition.bounds
            let centerZ = (bounds.minimum.z + bounds.maximum.z) / 2

            piece.position = SIMD3(
                cursorX - bounds.minimum.x,
                0,
                -centerZ
            )
            root.addChild(piece)
            pieces.append(piece)
            cursorX += bounds.dimensions.x + gap
        }

        let totalWidth = cursorX - gap
        for piece in pieces {
            piece.position.x -= totalWidth / 2
        }

        root.scale = SIMD3(repeating: tabletopScale)
        root.position = tabletopPosition
        return root
    }
}
