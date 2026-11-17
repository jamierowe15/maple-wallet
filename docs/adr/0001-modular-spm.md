# ADR 0001: Split the app into local Swift packages

- **Status:** Accepted
- **Date:** 2026-11-16

## Context
In a single app target every file can see every other file, so features slowly tangle together. Builds and tests always cover everything, which is slow, and nothing can be built off a Mac. The posting asks for modular, testable code managed with SPM.

## Decision
Split the code into local SPM packages: `Core`, `DesignSystem`, `Networking`, `Auth`, `Accounts`, `Transfers`.
Features depend only on `Core` protocols, `Networking` and `DesignSystem`. The app target is the composition root.

## Consequences
- Good: the compiler enforces the dependency rules; a feature can't import another feature.
- Good: each package builds and tests alone (`swift test`), including on Windows and Linux for logic packages.
- Good: changes are easier to review because each package has one job.
- Bad: more `Package.swift` files and more `public` keywords to maintain.
- Bad: shared types must move into `Core`, which needs discipline so it doesn't become a dumping ground.

## Alternatives considered
- One target with folders: no enforcement, everything can import everything.
- One Xcode project with framework targets: works on a Mac only and causes `.xcodeproj` merge conflicts.
- Tuist or CocoaPods: more tooling to learn; SPM is built into Swift and what the posting names.
