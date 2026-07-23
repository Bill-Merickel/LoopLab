//
//  TrackSocket.swift
//  LoopLab
//

import simd

/// A connection point expressed in its track piece's local coordinate space.
///
/// LoopLab uses meters, a right-handed coordinate system, `+Y` as up, and
/// `+Z` as the default forward direction. A socket's orientation points out
/// from the piece.
nonisolated struct TrackSocket: Sendable {
    nonisolated struct ID: RawRepresentable, Codable, Hashable, Sendable {
        let rawValue: String

        init(rawValue: String) {
            self.rawValue = rawValue
        }
    }

    nonisolated enum Role: String, Codable, Hashable, Sendable {
        case entry
        case exit
    }

    nonisolated enum ConnectionKind: String, Codable, Hashable, Sendable {
        case road
        case auxiliary
    }

    let id: ID
    let role: Role
    let connectionKind: ConnectionKind
    let position: SIMD3<Float>
    let orientation: simd_quatf

    /// Two sockets can connect when their categories match and their roles are
    /// complementary. Geometric alignment is handled by the future snap system.
    func isCompatible(with other: TrackSocket) -> Bool {
        connectionKind == other.connectionKind && role != other.role
    }

    /// Reports whether the socket pose is finite and its quaternion is normalized.
    func hasValidPose(tolerance: Float = 0.0001) -> Bool {
        let positionIsFinite = position.x.isFinite
            && position.y.isFinite
            && position.z.isFinite
        let rotation = orientation.vector
        let rotationIsFinite = rotation.x.isFinite
            && rotation.y.isFinite
            && rotation.z.isFinite
            && rotation.w.isFinite
        let rotationIsNormalized = abs(simd_length(rotation) - 1) <= tolerance

        return positionIsFinite && rotationIsFinite && rotationIsNormalized
    }
}

nonisolated extension TrackSocket.ID {
    static let entry = Self(rawValue: "entry")
    static let exit = Self(rawValue: "exit")
}
