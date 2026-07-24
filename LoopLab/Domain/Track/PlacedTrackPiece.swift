//
//  PlacedTrackPiece.swift
//  LoopLab
//

/// One reusable track definition placed in a track assembly.
nonisolated struct PlacedTrackPiece: Equatable, Sendable {
    nonisolated struct ID: RawRepresentable, Codable, Hashable, Sendable {
        let rawValue: String

        init(rawValue: String) {
            self.rawValue = rawValue
        }
    }

    let id: ID
    let kind: TrackPieceKind
    let transform: TrackTransform

    func placing(at transform: TrackTransform) -> PlacedTrackPiece {
        PlacedTrackPiece(id: id, kind: kind, transform: transform)
    }
}

/// Identifies one socket on one placed piece.
nonisolated struct TrackSocketReference: Codable, Hashable, Sendable {
    let pieceID: PlacedTrackPiece.ID
    let socketID: TrackSocket.ID
}
