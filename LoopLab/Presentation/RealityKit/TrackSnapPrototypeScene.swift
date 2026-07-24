//
//  TrackSnapPrototypeScene.swift
//  LoopLab
//

import RealityKit

/// RealityKit view state generated from a `TrackAssembly`.
@MainActor
final class TrackSnapPrototypeScene {
    static let rootEntityName = "track-snap-prototype"
    static let interactionTargetName = "snap-moving-interaction-target"

    let root: Entity
    let interactionTarget: Entity

    private let movingEntity: Entity
    private let socketMarkers: [TrackSocketReference: Entity]

    init(
        assembly: TrackAssembly,
        movingPieceID: PlacedTrackPiece.ID
    ) throws {
        let root = Entity()
        root.name = Self.rootEntityName
        root.scale = SIMD3(repeating: 0.35)
        root.position = SIMD3(0, -0.45, -1.2)

        var entities: [PlacedTrackPiece.ID: Entity] = [:]
        var markers: [TrackSocketReference: Entity] = [:]

        for piece in assembly.pieces {
            guard let definition = TrackPieceCatalog.definition(
                for: piece.kind
            ) else {
                continue
            }

            let entity = try TrackPieceEntityFactory.makeEntity(
                for: definition
            )
            entity.name = Self.placedEntityName(for: piece.id)
            Self.apply(piece.transform, to: entity)

            for socket in definition.sockets {
                let reference = TrackSocketReference(
                    pieceID: piece.id,
                    socketID: socket.id
                )
                let marker = TrackSocketMarkerFactory.makeMarker(
                    for: socket,
                    reference: reference
                )
                entity.addChild(marker)
                markers[reference] = marker
            }

            root.addChild(entity)
            entities[piece.id] = entity
        }

        guard
            let movingEntity = entities[movingPieceID],
            let movingPiece = assembly.piece(withID: movingPieceID),
            let movingDefinition = TrackPieceCatalog.definition(
                for: movingPiece.kind
            )
        else {
            preconditionFailure("The snap scene requires its moving piece.")
        }

        let interactionTarget = Entity()
        interactionTarget.name = Self.interactionTargetName
        let bounds = movingDefinition.bounds
        let center = (bounds.minimum + bounds.maximum) / 2
        let size = bounds.dimensions
        interactionTarget.position = center
        interactionTarget.components.set(
            CollisionComponent(
                shapes: [
                    .generateBox(
                        size: SIMD3(
                            size.x,
                            max(size.y, 0.14),
                            size.z
                        )
                    ),
                ]
            )
        )
        interactionTarget.components.set(InputTargetComponent())
        movingEntity.addChild(interactionTarget)

        self.root = root
        self.movingEntity = movingEntity
        self.interactionTarget = interactionTarget
        socketMarkers = markers
    }

    func update(
        movingTransform: TrackTransform,
        highlightedDestination: TrackSocketReference?
    ) {
        Self.apply(movingTransform, to: movingEntity)

        for (reference, marker) in socketMarkers {
            marker.scale = SIMD3(
                repeating: reference == highlightedDestination ? 1.8 : 1
            )
        }
    }

    func finishInteraction() {
        interactionTarget.components.remove(InputTargetComponent.self)
    }

    static func placedEntityName(
        for id: PlacedTrackPiece.ID
    ) -> String {
        "placed-track-piece-\(id.rawValue)"
    }

    private static func apply(
        _ transform: TrackTransform,
        to entity: Entity
    ) {
        entity.position = transform.position
        entity.orientation = transform.orientation
    }
}
