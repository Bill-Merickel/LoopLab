//
//  TrackSnapPrototypeSceneTests.swift
//  LoopLabTests
//

import RealityKit
import Testing
@testable import LoopLab

@Suite("Track snap RealityKit presentation")
@MainActor
struct TrackSnapPrototypeSceneTests {
    @Test("scene is generated from every placed piece and socket")
    func generatesPlacedPiecesAndSockets() throws {
        let model = TrackSnapPrototypeModel()
        let scene = try TrackSnapPrototypeScene(
            assembly: model.assembly,
            movingPieceID: TrackSnapPrototypeModel.movingPieceID
        )

        #expect(scene.root.name == TrackSnapPrototypeScene.rootEntityName)
        #expect(scene.root.children.count == model.assembly.pieces.count)

        for piece in model.assembly.pieces {
            #expect(
                scene.root.findEntity(
                    named: TrackSnapPrototypeScene.placedEntityName(
                        for: piece.id
                    )
                ) != nil
            )

            let definition = try #require(
                TrackPieceCatalog.definition(for: piece.kind)
            )
            for socket in definition.sockets {
                let reference = TrackSocketReference(
                    pieceID: piece.id,
                    socketID: socket.id
                )
                #expect(
                    scene.root.findEntity(
                        named: TrackSocketMarkerFactory.entityName(
                            for: reference
                        )
                    ) != nil
                )
            }
        }
    }

    @Test("moving piece owns a gesture hit target")
    func movingPieceIsInteractive() throws {
        let model = TrackSnapPrototypeModel()
        let scene = try TrackSnapPrototypeScene(
            assembly: model.assembly,
            movingPieceID: TrackSnapPrototypeModel.movingPieceID
        )

        #expect(
            scene.interactionTarget.name
                == TrackSnapPrototypeScene.interactionTargetName
        )
        #expect(
            scene.interactionTarget.components.has(
                InputTargetComponent.self
            )
        )
        #expect(
            scene.interactionTarget.components.has(
                CollisionComponent.self
            )
        )

        scene.finishInteraction()

        #expect(
            !scene.interactionTarget.components.has(
                InputTargetComponent.self
            )
        )
        #expect(
            scene.interactionTarget.components.has(
                CollisionComponent.self
            )
        )
    }
}
