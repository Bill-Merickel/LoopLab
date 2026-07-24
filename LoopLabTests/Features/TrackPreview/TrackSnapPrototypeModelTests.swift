//
//  TrackSnapPrototypeModelTests.swift
//  LoopLabTests
//

import simd
import Testing
@testable import LoopLab

@Suite("Track snap prototype state")
@MainActor
struct TrackSnapPrototypeModelTests {
    @Test("committed placement matches the proximity preview")
    func committedPlacementMatchesPreview() throws {
        let model = TrackSnapPrototypeModel()
        let initial = try #require(model.movingPieceTransform)

        model.updateDrag(
            from: initial,
            translation: SIMD3(-0.6, 0, 0)
        )
        let preview = try #require(model.presentedMovingTransform)
        #expect(model.highlightedDestination != nil)
        #expect(!model.hasCommittedSnap)

        model.finishDrag()

        let committed = try #require(model.movingPieceTransform)
        #expect(model.hasCommittedSnap)
        #expect(model.highlightedDestination == nil)
        #expect(committed == preview)
        #expect(model.assembly.connections.count == 1)
    }

    @Test("release outside the snap distance keeps free placement")
    func releaseOutsideSnapDistance() throws {
        let model = TrackSnapPrototypeModel()
        let initial = try #require(model.movingPieceTransform)

        model.updateDrag(
            from: initial,
            translation: SIMD3(0.2, 0.5, -0.15)
        )
        let preview = try #require(model.presentedMovingTransform)
        model.finishDrag()

        #expect(!model.hasCommittedSnap)
        #expect(model.highlightedDestination == nil)
        #expect(model.movingPieceTransform == preview)
        #expect(preview.position.y == 0)
    }
}
