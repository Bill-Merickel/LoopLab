//
//  TrackTransform.swift
//  LoopLab
//

import simd

/// A renderer-independent rigid transform expressed in track-local space.
nonisolated struct TrackTransform: Equatable, Sendable {
    let position: SIMD3<Float>
    let orientation: simd_quatf

    static let identity = TrackTransform()

    init(
        position: SIMD3<Float> = .zero,
        orientation: simd_quatf = simd_quatf(
            angle: 0,
            axis: SIMD3(0, 1, 0)
        )
    ) {
        self.position = position
        self.orientation = simd_normalize(orientation)
    }

    /// Applies a child-local transform after this transform.
    func concatenating(_ local: TrackTransform) -> TrackTransform {
        TrackTransform(matrix: matrix * local.matrix)
    }

    func inverted() -> TrackTransform {
        TrackTransform(matrix: simd_inverse(matrix))
    }

    func transform(point: SIMD3<Float>) -> SIMD3<Float> {
        let result = matrix * SIMD4(point, 1)
        return SIMD3(result.x, result.y, result.z)
    }

    func transform(direction: SIMD3<Float>) -> SIMD3<Float> {
        orientation.act(direction)
    }

    func isApproximatelyEqual(
        to other: TrackTransform,
        tolerance: Float = 0.0001
    ) -> Bool {
        simd_distance(position, other.position) <= tolerance
            && abs(simd_dot(orientation.vector, other.orientation.vector))
                >= 1 - tolerance
    }

    var hasValidPose: Bool {
        let positionIsFinite = position.x.isFinite
            && position.y.isFinite
            && position.z.isFinite
        let rotation = orientation.vector
        let rotationIsFinite = rotation.x.isFinite
            && rotation.y.isFinite
            && rotation.z.isFinite
            && rotation.w.isFinite
        let rotationIsNormalized =
            abs(simd_length(rotation) - 1) <= 0.0001

        return positionIsFinite && rotationIsFinite && rotationIsNormalized
    }

    static func == (lhs: TrackTransform, rhs: TrackTransform) -> Bool {
        lhs.position == rhs.position
            && lhs.orientation.vector == rhs.orientation.vector
    }

    private var matrix: simd_float4x4 {
        var result = simd_float4x4(orientation)
        result.columns.3 = SIMD4(position, 1)
        return result
    }

    private init(matrix: simd_float4x4) {
        position = SIMD3(
            matrix.columns.3.x,
            matrix.columns.3.y,
            matrix.columns.3.z
        )
        let rotationMatrix = simd_float3x3(
            SIMD3(
                matrix.columns.0.x,
                matrix.columns.0.y,
                matrix.columns.0.z
            ),
            SIMD3(
                matrix.columns.1.x,
                matrix.columns.1.y,
                matrix.columns.1.z
            ),
            SIMD3(
                matrix.columns.2.x,
                matrix.columns.2.y,
                matrix.columns.2.z
            )
        )
        orientation = simd_normalize(simd_quatf(rotationMatrix))
    }
}

nonisolated extension TrackSocket {
    var localTransform: TrackTransform {
        TrackTransform(position: position, orientation: orientation)
    }
}
