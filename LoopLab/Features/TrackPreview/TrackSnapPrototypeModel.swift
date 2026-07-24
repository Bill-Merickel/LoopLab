//
//  TrackSnapPrototypeModel.swift
//  LoopLab
//

import Observation
import simd

/// Feature state for the minimal one-piece snapping prototype.
@MainActor
@Observable
final class TrackSnapPrototypeModel {
    static let fixedPieceID = PlacedTrackPiece.ID(rawValue: "snap-anchor")
    static let movingPieceID = PlacedTrackPiece.ID(rawValue: "snap-moving")
    static let referencePieceID = PlacedTrackPiece.ID(
        rawValue: "snap-reference"
    )

    static let snapDistance: Float = 0.3

    private(set) var assembly: TrackAssembly
    private(set) var candidate: TrackSnapCandidate?
    private(set) var statusText =
        "Drag the straight piece toward the highlighted start/finish socket."

    var movingSource: TrackSocketReference {
        TrackSocketReference(
            pieceID: Self.movingPieceID,
            socketID: .entry
        )
    }

    var movingPieceTransform: TrackTransform? {
        assembly.piece(withID: Self.movingPieceID)?.transform
    }

    var presentedMovingTransform: TrackTransform? {
        candidate?.transform ?? movingPieceTransform
    }

    var highlightedDestination: TrackSocketReference? {
        candidate?.destination
    }

    var hasCommittedSnap: Bool {
        !assembly.connections.isEmpty
    }

    init() {
        var assembly = TrackAssembly()

        do {
            try assembly.add(
                PlacedTrackPiece(
                    id: Self.fixedPieceID,
                    kind: .startFinish,
                    transform: TrackTransform(
                        position: SIMD3(0, 0, -0.3)
                    )
                )
            )
            try assembly.add(
                PlacedTrackPiece(
                    id: Self.movingPieceID,
                    kind: .straight,
                    transform: TrackTransform(
                        position: SIMD3(0.75, 0, 0.9)
                    )
                )
            )
            try assembly.add(
                PlacedTrackPiece(
                    id: Self.referencePieceID,
                    kind: .leftCurve,
                    transform: TrackTransform(
                        position: SIMD3(-1.35, 0, -0.3)
                    )
                )
            )
        } catch {
            preconditionFailure(
                "Unable to create the snapping prototype: \(error)"
            )
        }

        self.assembly = assembly
    }

    func updateDrag(
        from initialTransform: TrackTransform,
        translation: SIMD3<Float>
    ) {
        guard !hasCommittedSnap else {
            return
        }

        let proposed = TrackTransform(
            position: SIMD3(
                initialTransform.position.x + translation.x,
                0,
                initialTransform.position.z + translation.z
            ),
            orientation: initialTransform.orientation
        )

        do {
            try assembly.moveUnconnectedPiece(
                id: Self.movingPieceID,
                to: proposed
            )
            candidate = try assembly.nearestSnapCandidate(
                moving: movingSource,
                within: Self.snapDistance
            )
            statusText = candidate == nil
                ? "Move closer until the destination socket grows."
                : "Release to commit the exact socket snap."
        } catch {
            assertionFailure("Unable to preview the track snap: \(error)")
        }
    }

    func finishDrag() {
        guard !hasCommittedSnap else {
            return
        }

        guard let candidate else {
            statusText =
                "Drag the straight piece toward the start/finish socket."
            return
        }

        do {
            try assembly.snapAndConnect(
                moving: candidate.source,
                to: candidate.destination
            )
            self.candidate = nil
            statusText = "Snap committed. The socket poses now align exactly."
        } catch {
            assertionFailure("Unable to commit the track snap: \(error)")
        }
    }
}
