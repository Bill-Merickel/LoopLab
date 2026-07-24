//
//  TrackSnapResolver.swift
//  LoopLab
//

import simd

/// Computes rigid transforms that join sockets without RealityKit state.
nonisolated enum TrackSnapResolver {
    private static let opposingSocketRotation = TrackTransform(
        orientation: simd_quatf(
            angle: .pi,
            axis: SIMD3(0, 1, 0)
        )
    )

    static func snappedTransform(
        sourceSocket: TrackSocket,
        destinationPieceTransform: TrackTransform,
        destinationSocket: TrackSocket
    ) -> TrackTransform {
        let destinationWorld = destinationPieceTransform.concatenating(
            destinationSocket.localTransform
        )

        return destinationWorld
            .concatenating(opposingSocketRotation)
            .concatenating(sourceSocket.localTransform.inverted())
    }
}
