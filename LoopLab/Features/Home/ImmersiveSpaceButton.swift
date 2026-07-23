//
//  ImmersiveSpaceButton.swift
//  LoopLab
//
//  Created by Bill Merickel on 7/19/26.
//

import SwiftUI

struct ImmersiveSpaceButton: View {

    @Environment(AppModel.self) private var appModel

    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    var body: some View {
        Button {
            Task { @MainActor in
                switch appModel.immersiveSpaceState {
                case .closed:
                    guard appModel.beginOpeningImmersiveSpace() else {
                        return
                    }

                    switch await openImmersiveSpace(
                        id: appModel.immersiveSpaceID
                    ) {
                    case .opened:
                        break

                    case .userCancelled, .error:
                        appModel.immersiveSpaceOpenDidNotComplete()

                    @unknown default:
                        appModel.immersiveSpaceOpenDidNotComplete()
                    }

                case .open:
                    guard appModel.beginClosingImmersiveSpace() else {
                        return
                    }

                    await dismissImmersiveSpace()

                case .opening, .closing:
                    break
                }
            }
        } label: {
            Text(appModel.immersiveSpaceButtonLabel)
        }
        .disabled(appModel.isImmersiveSpaceButtonDisabled)
        .fontWeight(.semibold)
    }
}
