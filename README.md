# LoopLab

LoopLab is an early-stage spatial racing game for Apple Vision Pro. The goal is
to let players build toy-like racetracks from modular pieces, place them in their
space, and race for the best lap time.

The current app is a foundation for that experience. It includes:

- A SwiftUI window scene
- A RealityKit preview loaded from a local asset package
- A mixed immersive space
- Shared state for opening and closing the immersive experience
- A Swift Testing target

Track editing, driving, persistence, and competitive features are planned but
are not implemented yet. See [plan.md](plan.md) for the product vision,
technical direction, and proposed milestones.

## Requirements

- A Mac with Apple silicon
- Xcode with the visionOS 26.5 SDK
- Apple Vision Pro or a compatible visionOS Simulator runtime

The project deployment target is visionOS 26.5.

## Getting started

1. Clone the repository.
2. Open `LoopLab.xcodeproj` in Xcode.
3. Select the `LoopLab` scheme.
4. Choose an Apple Vision Pro simulator or connected device.
5. Build and run with **Product → Run** (`⌘R`).

In the app, select **Show Immersive Space** to enter the mixed immersive
experience. Select **Hide Immersive Space** to return to the windowed
experience.

## Project structure

```text
LoopLab/
├── LoopLab/                         App lifecycle, SwiftUI views, and state
├── LoopLabTests/                    Swift Testing test target
├── Packages/RealityKitContent/      Reality Composer Pro assets and package
├── LoopLab.xcodeproj/               Xcode project
└── plan.md                          Product and development plan
```

The `RealityKitContent` package contains the `Scene` asset shown in the main
window and the `Immersive` asset loaded when the immersive space opens.

## Testing

Run the test suite in Xcode with **Product → Test** (`⌘U`), or from the command
line:

```sh
xcodebuild test \
  -project LoopLab.xcodeproj \
  -scheme LoopLab \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

The exact simulator name may differ depending on the runtimes installed in
Xcode.

## Roadmap

The planned MVP centers on four areas:

1. Modular track placement, snapping, editing, and validation
2. Toy-like vehicle controls and DualSense support
3. Lap timing, checkpoints, and local records
4. Local track saving, loading, and onboarding

Online track sharing, leaderboards, ghosts, and real-time multiplayer are
planned for later phases.
