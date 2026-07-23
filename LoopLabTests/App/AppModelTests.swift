//
//  AppModelTests.swift
//  LoopLabTests
//

import Testing
@testable import LoopLab

@Suite("Immersive-space state")
@MainActor
struct AppModelTests {
    @Test("open and close follow valid transition sequences")
    func openAndCloseSequence() {
        let model = AppModel()

        #expect(model.immersiveSpaceState == .closed)
        #expect(model.beginOpeningImmersiveSpace())
        #expect(model.immersiveSpaceState == .opening)

        model.immersiveSpaceDidAppear()
        #expect(model.immersiveSpaceState == .open)
        #expect(model.beginClosingImmersiveSpace())
        #expect(model.immersiveSpaceState == .closing)

        model.immersiveSpaceDidDisappear()
        #expect(model.immersiveSpaceState == .closed)
    }

    @Test("cancelled and failed opens recover to closed")
    func unsuccessfulOpenRecovery() {
        let cancelledModel = AppModel()
        #expect(cancelledModel.beginOpeningImmersiveSpace())
        cancelledModel.immersiveSpaceOpenDidNotComplete()
        #expect(cancelledModel.immersiveSpaceState == .closed)

        let failedModel = AppModel()
        #expect(failedModel.beginOpeningImmersiveSpace())
        failedModel.immersiveSpaceOpenDidNotComplete()
        #expect(failedModel.immersiveSpaceState == .closed)
    }

    @Test("duplicate requests are ignored during transitions")
    func duplicateRequestsAreIgnored() {
        let model = AppModel()

        #expect(model.beginOpeningImmersiveSpace())
        #expect(!model.beginOpeningImmersiveSpace())
        #expect(!model.beginClosingImmersiveSpace())
        #expect(model.immersiveSpaceState == .opening)

        model.immersiveSpaceDidAppear()
        #expect(model.beginClosingImmersiveSpace())
        #expect(!model.beginClosingImmersiveSpace())
        #expect(!model.beginOpeningImmersiveSpace())
        #expect(model.immersiveSpaceState == .closing)
    }

    @Test("button presentation derives from state")
    func buttonPresentation() {
        let model = AppModel()

        #expect(model.immersiveSpaceButtonLabel == "Enter Track Preview")
        #expect(!model.isImmersiveSpaceButtonDisabled)

        model.beginOpeningImmersiveSpace()
        #expect(model.immersiveSpaceButtonLabel == "Opening Track Preview…")
        #expect(model.isImmersiveSpaceButtonDisabled)

        model.immersiveSpaceDidAppear()
        #expect(model.immersiveSpaceButtonLabel == "Exit Track Preview")
        #expect(!model.isImmersiveSpaceButtonDisabled)

        model.beginClosingImmersiveSpace()
        #expect(model.immersiveSpaceButtonLabel == "Closing Track Preview…")
        #expect(model.isImmersiveSpaceButtonDisabled)
    }
}
