//
//  TrackPreviewImmersiveView.swift
//  LoopLab
//
//  Created by Bill Merickel on 7/19/26.
//

import SwiftUI
import RealityKit

struct TrackPreviewImmersiveView: View {

    var body: some View {
        RealityView { content in
            do {
                content.add(try GrayBoxTrackLayout.makeRootEntity())
            } catch {
                assertionFailure(
                    "Unable to create the gray-box track preview: \(error)"
                )
            }
        }
    }
}

#Preview(immersionStyle: .mixed) {
    TrackPreviewImmersiveView()
        .environment(AppModel())
}
