//
//  TrackConnection.swift
//  LoopLab
//

nonisolated enum TrackConnectionCreationError: Error, Equatable {
    case samePiece
}

/// A connection between sockets owned by two different placed pieces.
nonisolated struct TrackConnection: Equatable, Hashable, Sendable {
    let source: TrackSocketReference
    let destination: TrackSocketReference

    init(
        source: TrackSocketReference,
        destination: TrackSocketReference
    ) throws {
        guard source.pieceID != destination.pieceID else {
            throw TrackConnectionCreationError.samePiece
        }

        self.source = source
        self.destination = destination
    }

    func contains(_ reference: TrackSocketReference) -> Bool {
        source == reference || destination == reference
    }

    func contains(pieceID: PlacedTrackPiece.ID) -> Bool {
        source.pieceID == pieceID || destination.pieceID == pieceID
    }
}
