//
//  TrackPreviewImmersiveView.swift
//  LoopLab
//
//  Created by Bill Merickel on 7/19/26.
//

import SwiftUI
import RealityKit

struct TrackPreviewImmersiveView: View {
    @State private var prototype = TrackSnapPrototypeModel()
    @State private var scene: TrackSnapPrototypeScene?
    @State private var dragStartTransform: TrackTransform?

    var body: some View {
        RealityView { content, attachments in
            do {
                let scene = try TrackSnapPrototypeScene(
                    assembly: prototype.assembly,
                    movingPieceID: TrackSnapPrototypeModel.movingPieceID
                )
                content.add(scene.root)
                self.scene = scene

                if let instructions = attachments.entity(
                    for: "snap-instructions"
                ) {
                    instructions.position = SIMD3(0, 0.05, -1.1)
                    content.add(instructions)
                }
            } catch {
                assertionFailure(
                    "Unable to create the track snapping prototype: \(error)"
                )
            }
        } attachments: {
            Attachment(id: "snap-instructions") {
                VStack(spacing: 6) {
                    Text("Socket Snapping Prototype")
                        .font(.headline)
                    Text(prototype.statusText)
                        .font(.subheadline)
                }
                .multilineTextAlignment(.center)
                .padding()
                .glassBackgroundEffect()
            }
        }
        .gesture(dragGesture)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                guard
                    let scene,
                    value.entity === scene.interactionTarget,
                    !prototype.hasCommittedSnap
                else {
                    return
                }

                if dragStartTransform == nil {
                    dragStartTransform = prototype.movingPieceTransform
                }
                guard let dragStartTransform else {
                    return
                }

                let translation = value.convert(
                    value.gestureValue.translation3D,
                    from: .local,
                    to: scene.root
                )
                prototype.updateDrag(
                    from: dragStartTransform,
                    translation: SIMD3(
                        Float(translation.x),
                        Float(translation.y),
                        Float(translation.z)
                    )
                )

                if let presented = prototype.presentedMovingTransform {
                    scene.update(
                        movingTransform: presented,
                        highlightedDestination:
                            prototype.highlightedDestination
                    )
                }
            }
            .onEnded { value in
                guard
                    let scene,
                    value.entity === scene.interactionTarget
                else {
                    return
                }

                prototype.finishDrag()
                dragStartTransform = nil

                if let presented = prototype.presentedMovingTransform {
                    scene.update(
                        movingTransform: presented,
                        highlightedDestination:
                            prototype.highlightedDestination
                    )
                }
                if prototype.hasCommittedSnap {
                    scene.finishInteraction()
                }
            }
    }
}

#Preview(immersionStyle: .mixed) {
    TrackPreviewImmersiveView()
        .environment(AppModel())
}
