# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AIChat App — an iOS SwiftUI application that integrates with LLM APIs to provide AI chat functionality.

## Build & Test Commands

This is a native Xcode project with no Makefile, Fastlane, or CocoaPods. Use `xcodebuild` from the `AIChatApp/` directory (where `AIChatApp.xcodeproj` lives):

```bash
# Build
xcodebuild build -scheme AIChatApp -project AIChatApp.xcodeproj

# Run unit tests
xcodebuild test -scheme AIChatApp -project AIChatApp.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 16'

# Run a single unit test class
xcodebuild test -scheme AIChatApp -project AIChatApp.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing AIChatAppTests/AIChatAppTests

# Run UI tests
xcodebuild test -scheme AIChatApp -project AIChatApp.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing AIChatAppUITests
```

## Architecture

- **UI layer:** SwiftUI only (`ContentView.swift` is the root view)
- **Entry point:** `AIChatApp/AIChatApp/AIChatAppApp.swift` (`@main` struct)
- **Testing:** Unit tests use Swift's `Testing` framework; UI tests use `XCTest`
- **Deployment target:** iOS 26.2, supports iPhone and iPad

## Key Details

- Bundle ID: `com.apposestudio.ai.chat.AIChatApp`
- No external dependencies yet — SPM, CocoaPods, and Carthage are all absent
- When adding LLM API keys, use Xcode's environment variables or a `.xcconfig` file excluded from git — never hardcode them
