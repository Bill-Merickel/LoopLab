//
//  TrackAssemblyTests.swift
//  LoopLabTests
//

import simd
import Testing
@testable import LoopLab

@Suite("Track assembly snapping rules")
struct TrackAssemblyTests {
    private let fixedID = PlacedTrackPiece.ID(rawValue: "fixed")
    private let movingID = PlacedTrackPiece.ID(rawValue: "moving")
    private let thirdID = PlacedTrackPiece.ID(rawValue: "third")

    @Test("connection values reject references on one piece")
    func connectionRejectsOnePiece() {
        let entry = reference(pieceID: movingID, socketID: .entry)
        let exit = reference(pieceID: movingID, socketID: .exit)

        #expect(throws: TrackConnectionCreationError.samePiece) {
            try TrackConnection(source: entry, destination: exit)
        }
    }

    @Test("assembly rejects duplicate placed-piece identifiers")
    func rejectsDuplicatePieceIdentifiers() throws {
        var assembly = TrackAssembly()
        let piece = PlacedTrackPiece(
            id: fixedID,
            kind: .startFinish,
            transform: .identity
        )
        try assembly.add(piece)

        #expect(throws: TrackAssemblyError.duplicatePieceID(fixedID)) {
            try assembly.add(piece)
        }
        #expect(assembly.pieces.count == 1)
    }

    @Test("snap and connect commits the resolved transform")
    func commitsResolvedTransform() throws {
        var assembly = try makeAssembly()
        let source = reference(pieceID: movingID, socketID: .entry)
        let destination = reference(pieceID: fixedID, socketID: .exit)
        let expected = try assembly.snappedTransform(
            moving: source,
            to: destination
        )

        try assembly.snapAndConnect(
            moving: source,
            to: destination
        )

        let placed = try #require(assembly.piece(withID: movingID))
        #expect(placed.transform == expected)
        #expect(assembly.connections.count == 1)
        #expect(assembly.isOccupied(source))
        #expect(assembly.isOccupied(destination))
    }

    @Test("self and same-role snaps do not mutate the assembly")
    func invalidSnapsDoNotMutate() throws {
        var assembly = try makeAssembly()
        let originalMoving = try #require(assembly.piece(withID: movingID))
        let movingEntry = reference(pieceID: movingID, socketID: .entry)
        let movingExit = reference(pieceID: movingID, socketID: .exit)
        let fixedEntry = reference(pieceID: fixedID, socketID: .entry)

        #expect(throws: TrackAssemblyError.selfConnection) {
            try assembly.snapAndConnect(
                moving: movingEntry,
                to: movingExit
            )
        }
        #expect(throws: TrackAssemblyError.incompatibleSockets) {
            try assembly.snapAndConnect(
                moving: movingEntry,
                to: fixedEntry
            )
        }

        #expect(assembly.piece(withID: movingID) == originalMoving)
        #expect(assembly.connections.isEmpty)
    }

    @Test("an occupied socket cannot be reused")
    func rejectsOccupiedSocketWithoutMutation() throws {
        var assembly = try makeAssembly(includeThirdPiece: true)
        let movingEntry = reference(
            pieceID: movingID,
            socketID: .entry
        )
        let thirdEntry = reference(pieceID: thirdID, socketID: .entry)
        let fixedExit = reference(pieceID: fixedID, socketID: .exit)

        try assembly.snapAndConnect(
            moving: movingEntry,
            to: fixedExit
        )
        let originalThird = try #require(assembly.piece(withID: thirdID))

        #expect(throws: TrackAssemblyError.occupiedSocket(fixedExit)) {
            try assembly.snapAndConnect(
                moving: thirdEntry,
                to: fixedExit
            )
        }

        #expect(assembly.piece(withID: thirdID) == originalThird)
        #expect(assembly.connections.count == 1)
    }

    @Test("a connected piece cannot be moved independently")
    func connectedPieceCannotMove() throws {
        var assembly = try makeAssembly()
        let movingEntry = reference(
            pieceID: movingID,
            socketID: .entry
        )
        let fixedExit = reference(pieceID: fixedID, socketID: .exit)
        try assembly.snapAndConnect(
            moving: movingEntry,
            to: fixedExit
        )
        let committed = try #require(assembly.piece(withID: movingID))

        #expect(
            throws: TrackAssemblyError.movingPieceAlreadyConnected(
                movingID
            )
        ) {
            try assembly.moveUnconnectedPiece(
                id: movingID,
                to: TrackTransform(position: SIMD3(10, 0, 10))
            )
        }
        #expect(assembly.piece(withID: movingID) == committed)
    }

    @Test("nearest candidate respects distance and is repeatable")
    func nearestCandidate() throws {
        let assembly = try makeAssembly(
            movingTransform: TrackTransform(
                position: SIMD3(0.15, 0, 1.2)
            )
        )
        let source = reference(pieceID: movingID, socketID: .entry)

        let firstResult = try assembly.nearestSnapCandidate(
            moving: source,
            within: 0.2
        )
        let secondResult = try assembly.nearestSnapCandidate(
            moving: source,
            within: 0.2
        )
        let first = try #require(firstResult)
        let second = try #require(secondResult)
        let outsideThreshold = try assembly.nearestSnapCandidate(
            moving: source,
            within: 0.1
        )

        #expect(
            first.destination
                == reference(pieceID: fixedID, socketID: .exit)
        )
        #expect(first == second)
        #expect(abs(first.distance - 0.15) <= 0.0001)
        #expect(outsideThreshold == nil)
    }

    private func makeAssembly(
        movingTransform: TrackTransform = TrackTransform(
            position: SIMD3(0.7, 0, 1.2)
        ),
        includeThirdPiece: Bool = false
    ) throws -> TrackAssembly {
        var assembly = TrackAssembly()
        try assembly.add(
            PlacedTrackPiece(
                id: fixedID,
                kind: .startFinish,
                transform: .identity
            )
        )
        try assembly.add(
            PlacedTrackPiece(
                id: movingID,
                kind: .straight,
                transform: movingTransform
            )
        )

        if includeThirdPiece {
            try assembly.add(
                PlacedTrackPiece(
                    id: thirdID,
                    kind: .leftCurve,
                    transform: TrackTransform(
                        position: SIMD3(-1.5, 0, 0)
                    )
                )
            )
        }

        return assembly
    }

    private func reference(
        pieceID: PlacedTrackPiece.ID,
        socketID: TrackSocket.ID
    ) -> TrackSocketReference {
        TrackSocketReference(pieceID: pieceID, socketID: socketID)
    }
}
