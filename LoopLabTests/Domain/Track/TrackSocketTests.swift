//
//  TrackSocketTests.swift
//  LoopLabTests
//

import simd
import Testing
@testable import LoopLab

@Suite("Track socket rules")
struct TrackSocketTests {
    @Test("uses stable local socket identifiers")
    func usesStableIdentifiers() {
        #expect(TrackSocket.ID.entry.rawValue == "entry")
        #expect(TrackSocket.ID.exit.rawValue == "exit")
    }

    @Test("compatibility is symmetric for complementary road sockets")
    func compatibilityIsSymmetric() {
        let entry = makeSocket(role: .entry)
        let exit = makeSocket(role: .exit)

        #expect(entry.isCompatible(with: exit))
        #expect(exit.isCompatible(with: entry))
    }

    @Test("matching roles cannot connect")
    func matchingRolesCannotConnect() {
        let firstEntry = makeSocket(role: .entry)
        let secondEntry = makeSocket(role: .entry)

        #expect(!firstEntry.isCompatible(with: secondEntry))
    }

    @Test("different connection categories cannot connect")
    func differentConnectionCategoriesCannotConnect() {
        let road = makeSocket(role: .entry, connectionKind: .road)
        let auxiliary = makeSocket(
            role: .exit,
            connectionKind: .auxiliary
        )

        #expect(!road.isCompatible(with: auxiliary))
        #expect(!auxiliary.isCompatible(with: road))
    }

    @Test("pose validation requires finite normalized values")
    func validatesPose() {
        let valid = makeSocket(role: .entry)
        let nonFinite = TrackSocket(
            id: .entry,
            role: .entry,
            connectionKind: .road,
            position: SIMD3(.infinity, 0, 0),
            orientation: simd_quatf(
                angle: 0,
                axis: SIMD3(0, 1, 0)
            )
        )
        let nonNormalized = TrackSocket(
            id: .entry,
            role: .entry,
            connectionKind: .road,
            position: .zero,
            orientation: simd_quatf(vector: SIMD4(0, 0, 0, 2))
        )

        #expect(valid.hasValidPose())
        #expect(!nonFinite.hasValidPose())
        #expect(!nonNormalized.hasValidPose())
    }

    private func makeSocket(
        role: TrackSocket.Role,
        connectionKind: TrackSocket.ConnectionKind = .road
    ) -> TrackSocket {
        TrackSocket(
            id: role == .entry ? .entry : .exit,
            role: role,
            connectionKind: connectionKind,
            position: .zero,
            orientation: simd_quatf(
                angle: 0,
                axis: SIMD3(0, 1, 0)
            )
        )
    }
}
