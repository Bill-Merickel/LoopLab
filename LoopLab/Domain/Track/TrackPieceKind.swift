//
//  TrackPieceKind.swift
//  LoopLab
//

import Foundation

/// Stable identifiers for reusable track-piece definitions.
nonisolated enum TrackPieceKind: String, Codable, CaseIterable, Hashable, Sendable {
    case straight
    case leftCurve = "left-curve"
    case startFinish = "start-finish"
}
