# LoopLab repository guidance

LoopLab is a visionOS 26.5 app built with SwiftUI, RealityKit, and Swift Testing.
Run commands from the repository root.

## Build

Use a generic visionOS destination so the command does not require a connected
device or a booted simulator:

```sh
xcodebuild -project LoopLab.xcodeproj -scheme LoopLab -configuration Debug -destination 'generic/platform=visionOS' -derivedDataPath /tmp/LoopLabDerivedData CODE_SIGNING_ALLOWED=NO build
```

## Test

The test command expects the visionOS 26.5 runtime and an `Apple Vision Pro`
simulator:

```sh
xcodebuild -project LoopLab.xcodeproj -scheme LoopLab -configuration Debug -destination 'platform=visionOS Simulator,name=Apple Vision Pro,OS=26.5' -derivedDataPath /tmp/LoopLabDerivedData CODE_SIGNING_ALLOWED=NO test
```

If that simulator is not installed, list available destinations with:

```sh
xcodebuild -project LoopLab.xcodeproj -scheme LoopLab -showdestinations
```

## Project conventions

- Keep offline gameplay foundations ahead of online services.
- Keep track and socket domain types independent of SwiftUI and RealityKit.
- Generate RealityKit entities from domain definitions; never use entities as
  the persisted model.
- Add focused Swift Testing coverage for new domain behavior.
- Treat procedural geometry as gray-box content until interaction, snapping,
  seams, and scale have been validated.
- Do not add online services, final artwork, or full vehicle physics during
  Phase 0 foundation work.
