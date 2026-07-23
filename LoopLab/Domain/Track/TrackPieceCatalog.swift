//
//  TrackPieceCatalog.swift
//  LoopLab
//

import simd

/// Canonical reusable track-piece definitions available in Phase 0.
nonisolated enum TrackPieceCatalog {
    static let schemaVersion = 1
    static let laneWidth: Float = 0.4
    static let deckThickness: Float = 0.06
    static let straightLength: Float = 1.2
    static let curveCenterlineRadius: Float = 0.8
    static let curveSweepAngle: Float = .pi / 2
    static let startFinishMarkerWidth: Float = 0.08

    static let phase0: [TrackPieceDefinition] = [
        straight,
        leftCurve,
        startFinish,
    ]

    static func definition(for kind: TrackPieceKind) -> TrackPieceDefinition? {
        phase0.first { $0.kind == kind }
    }

    private static let straight = makeStraight(
        kind: .straight,
        displayName: "Straight",
        geometry: .straight(
            length: straightLength,
            deckThickness: deckThickness
        )
    )

    private static let startFinish = makeStraight(
        kind: .startFinish,
        displayName: "Start / Finish",
        geometry: .startFinish(
            length: straightLength,
            deckThickness: deckThickness,
            markerWidth: startFinishMarkerWidth
        )
    )

    private static let leftCurve: TrackPieceDefinition = {
        let outerRadius = curveCenterlineRadius + laneWidth / 2

        return TrackPieceDefinition(
            kind: .leftCurve,
            schemaVersion: schemaVersion,
            displayName: "Left Curve",
            laneWidth: laneWidth,
            bounds: TrackPieceBounds(
                minimum: SIMD3(0, -deckThickness, 0),
                maximum: SIMD3(outerRadius, 0, outerRadius)
            ),
            sockets: [
                TrackSocket(
                    id: .entry,
                    role: .entry,
                    connectionKind: .road,
                    position: SIMD3(curveCenterlineRadius, 0, 0),
                    orientation: simd_quatf(
                        angle: .pi,
                        axis: SIMD3(0, 1, 0)
                    )
                ),
                TrackSocket(
                    id: .exit,
                    role: .exit,
                    connectionKind: .road,
                    position: SIMD3(0, 0, curveCenterlineRadius),
                    orientation: simd_quatf(
                        angle: -.pi / 2,
                        axis: SIMD3(0, 1, 0)
                    )
                ),
            ],
            geometry: .leftCurve(
                centerlineRadius: curveCenterlineRadius,
                sweepAngle: curveSweepAngle,
                deckThickness: deckThickness
            )
        )
    }()

    private static func makeStraight(
        kind: TrackPieceKind,
        displayName: String,
        geometry: TrackPieceGeometryRecipe
    ) -> TrackPieceDefinition {
        let halfWidth = laneWidth / 2
        let halfLength = straightLength / 2

        return TrackPieceDefinition(
            kind: kind,
            schemaVersion: schemaVersion,
            displayName: displayName,
            laneWidth: laneWidth,
            bounds: TrackPieceBounds(
                minimum: SIMD3(-halfWidth, -deckThickness, -halfLength),
                maximum: SIMD3(halfWidth, 0, halfLength)
            ),
            sockets: [
                TrackSocket(
                    id: .entry,
                    role: .entry,
                    connectionKind: .road,
                    position: SIMD3(0, 0, -halfLength),
                    orientation: simd_quatf(
                        angle: .pi,
                        axis: SIMD3(0, 1, 0)
                    )
                ),
                TrackSocket(
                    id: .exit,
                    role: .exit,
                    connectionKind: .road,
                    position: SIMD3(0, 0, halfLength),
                    orientation: simd_quatf(
                        angle: 0,
                        axis: SIMD3(0, 1, 0)
                    )
                ),
            ],
            geometry: geometry
        )
    }
}
