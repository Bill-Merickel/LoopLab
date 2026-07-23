//
//  TrackPieceCatalogTests.swift
//  LoopLabTests
//

import Testing
@testable import LoopLab

@Suite("Phase 0 track piece catalog")
struct TrackPieceCatalogTests {
    @Test("contains each Phase 0 piece exactly once")
    func containsExpectedPieces() {
        let definitions = TrackPieceCatalog.phase0
        let kinds = definitions.map(\.kind)

        #expect(definitions.count == 3)
        #expect(Set(kinds) == Set(TrackPieceKind.allCases))
        #expect(Set(kinds).count == kinds.count)
    }

    @Test("uses stable piece identifiers")
    func usesStableIdentifiers() {
        #expect(TrackPieceCatalog.schemaVersion == 1)
        #expect(TrackPieceKind.straight.rawValue == "straight")
        #expect(TrackPieceKind.leftCurve.rawValue == "left-curve")
        #expect(TrackPieceKind.startFinish.rawValue == "start-finish")
    }

    @Test("shares its authoring contract across definitions")
    func sharesAuthoringContract() {
        for definition in TrackPieceCatalog.phase0 {
            #expect(definition.schemaVersion == TrackPieceCatalog.schemaVersion)
            #expect(definition.laneWidth == TrackPieceCatalog.laneWidth)
            #expect(definition.bounds.hasPositiveDimensions)
            #expect(definition.sockets.count == 2)
            #expect(definition.sockets.filter { $0.role == .entry }.count == 1)
            #expect(definition.sockets.filter { $0.role == .exit }.count == 1)
            #expect(Set(definition.sockets.map(\.id)) == [.entry, .exit])

            for socket in definition.sockets {
                #expect(socket.hasValidPose())
                #expect(definition.bounds.contains(socket.position))
            }
        }
    }

    @Test(
        "places straight sockets on opposite ends",
        arguments: [TrackPieceKind.straight, .startFinish]
    )
    func placesStraightSocketsOnEnds(
        kind: TrackPieceKind
    ) throws {
        let definition = try #require(TrackPieceCatalog.definition(for: kind))
        let entry = try #require(definition.socket(with: .entry))
        let exit = try #require(definition.socket(with: .exit))

        #expect(entry.position.z == definition.bounds.minimum.z)
        #expect(exit.position.z == definition.bounds.maximum.z)
    }

    @Test("places curve sockets on its radial boundaries")
    func placesCurveSocketsOnBoundaries() throws {
        let definition = try #require(
            TrackPieceCatalog.definition(for: .leftCurve)
        )
        let entry = try #require(definition.socket(with: .entry))
        let exit = try #require(definition.socket(with: .exit))

        #expect(entry.position.z == definition.bounds.minimum.z)
        #expect(exit.position.x == definition.bounds.minimum.x)
    }
}
