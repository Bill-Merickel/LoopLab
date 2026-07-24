//
//  TrackSnapResolverTests.swift
//  LoopLabTests
//

import simd
import Testing
@testable import LoopLab

@Suite("Track snap transform")
struct TrackSnapResolverTests {
    @Test("aligns socket positions and opposes outward directions")
    func alignsCompatibleSockets() throws {
        let sourceDefinition = try #require(
            TrackPieceCatalog.definition(for: .straight)
        )
        let destinationDefinition = try #require(
            TrackPieceCatalog.definition(for: .leftCurve)
        )
        let sourceSocket = try #require(
            sourceDefinition.socket(with: .entry)
        )
        let destinationSocket = try #require(
            destinationDefinition.socket(with: .exit)
        )
        let destinationPieceTransform = TrackTransform(
            position: SIMD3(1.5, 0.25, -0.75),
            orientation: simd_quatf(
                angle: .pi / 3,
                axis: SIMD3(0, 1, 0)
            )
        )

        let snapped = TrackSnapResolver.snappedTransform(
            sourceSocket: sourceSocket,
            destinationPieceTransform: destinationPieceTransform,
            destinationSocket: destinationSocket
        )
        let sourceWorld = snapped.concatenating(
            sourceSocket.localTransform
        )
        let destinationWorld = destinationPieceTransform.concatenating(
            destinationSocket.localTransform
        )

        #expect(
            simd_distance(
                sourceWorld.position,
                destinationWorld.position
            ) <= 0.00001
        )

        let sourceForward = sourceWorld.transform(
            direction: SIMD3(0, 0, 1)
        )
        let destinationForward = destinationWorld.transform(
            direction: SIMD3(0, 0, 1)
        )
        #expect(simd_dot(sourceForward, destinationForward) <= -0.9999)
    }

    @Test("returns the same transform for the same socket poses")
    func deterministic() throws {
        let sourceDefinition = try #require(
            TrackPieceCatalog.definition(for: .straight)
        )
        let destinationDefinition = try #require(
            TrackPieceCatalog.definition(for: .startFinish)
        )
        let sourceSocket = try #require(
            sourceDefinition.socket(with: .entry)
        )
        let destinationSocket = try #require(
            destinationDefinition.socket(with: .exit)
        )

        let first = TrackSnapResolver.snappedTransform(
            sourceSocket: sourceSocket,
            destinationPieceTransform: .identity,
            destinationSocket: destinationSocket
        )
        let second = TrackSnapResolver.snappedTransform(
            sourceSocket: sourceSocket,
            destinationPieceTransform: .identity,
            destinationSocket: destinationSocket
        )

        #expect(first == second)
    }

    @Test("treats equivalent quaternion signs as approximate equality")
    func equivalentQuaternionSigns() {
        let first = TrackTransform(
            orientation: simd_quatf(vector: SIMD4(0, 0, 0, 1))
        )
        let second = TrackTransform(
            orientation: simd_quatf(vector: SIMD4(0, 0, 0, -1))
        )

        #expect(first.isApproximatelyEqual(to: second))
    }
}
