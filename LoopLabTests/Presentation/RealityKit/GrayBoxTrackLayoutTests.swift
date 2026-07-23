//
//  GrayBoxTrackLayoutTests.swift
//  LoopLabTests
//

import RealityKit
import Testing
@testable import LoopLab

@Suite("Gray-box RealityKit presentation")
@MainActor
struct GrayBoxTrackLayoutTests {
    @Test("factory generates every Phase 0 piece")
    func factoryGeneratesEveryPiece() throws {
        for definition in TrackPieceCatalog.phase0 {
            let entity = try TrackPieceEntityFactory.makeEntity(for: definition)

            #expect(
                entity.name
                    == TrackPieceEntityFactory.entityName(for: definition.kind)
            )
            #expect(!entity.children.isEmpty)
        }
    }

    @Test("start finish piece includes its marker")
    func startFinishIncludesMarker() throws {
        let definition = try #require(
            TrackPieceCatalog.definition(for: .startFinish)
        )
        let entity = try TrackPieceEntityFactory.makeEntity(for: definition)

        #expect(entity.findEntity(named: "start-finish-marker") != nil)
    }

    @Test("layout contains one entity for each catalog definition")
    func layoutContainsCatalog() throws {
        let root = try GrayBoxTrackLayout.makeRootEntity()

        #expect(root.name == GrayBoxTrackLayout.rootEntityName)
        #expect(root.children.count == TrackPieceCatalog.phase0.count)

        for kind in TrackPieceKind.allCases {
            #expect(
                root.findEntity(
                    named: TrackPieceEntityFactory.entityName(for: kind)
                ) != nil
            )
        }
    }
}
