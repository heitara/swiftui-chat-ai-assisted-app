# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AIChat App — an iOS SwiftUI application that provides multi-conversation AI chat powered by the Gemini API, with persistent history and a user profile system.

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

### Layer overview
- **Entry point:** `AIChatAppApp.swift` — creates `UserProfile` (`@State`) and injects it via `.environment(userProfile)`, then attaches the SwiftData `.modelContainer`
- **Routing:** `ContentView` → `ConversationListView` (the NavigationStack root)
- **UI layer:** SwiftUI + [ExyteChat](https://github.com/exyte/Chat) for the chat interface
- **AI layer:** Direct Gemini REST API calls in `GeminiService` (no third-party AI SDK)
- **Persistence:** SwiftData for conversations/messages; `UserDefaults` + Documents directory for user profile
- **Testing:** Unit tests use Swift's `Testing` framework; UI tests use `XCTest`
- **Deployment target:** iOS 26.0, supports iPhone and iPad

### Key files
| File | Role |
|------|------|
| `Config.swift` | Gemini API key (`Config.geminiAPIKey`) and model name — hardcoded |
| `Models/Conversation.swift` | SwiftData `@Model` — id, title, createdAt, updatedAt, cascade-deletes messages |
| `Models/ChatMessage.swift` | SwiftData `@Model` — role (`"user"` \| `"assistant"`), text, createdAt |
| `Models/UserProfile.swift` | `@Observable` class — name, avatar (photo or SF Symbol + color), persisted to UserDefaults + `Documents/avatar.jpg` |
| `Services/GeminiService.swift` | Calls `generativelanguage.googleapis.com` directly; builds a structured `contents` array for multi-turn context |
| `ViewModels/ChatViewModel.swift` | `@Observable` — owns `exyteMessages: [Message]`, drives send/receive flow, maps `ChatMessage` ↔ ExyteChat `Message` |
| `Views/ConversationListView.swift` | `@Query`-driven list, swipe-to-delete/rename, profile sheet, new-chat button |
| `Views/ChatScreen.swift` | Wraps ExyteChat `ChatView`; rebuilds message list on every `onAppear` so profile changes are reflected |
| `Views/ProfileScreen.swift` | Name field + avatar picker (photo library or symbol sheet) |
| `Views/SymbolPickerView.swift` | 5-column SF Symbol grid + color swatch strip; applies via `UserProfile.applySymbol(name:colorIndex:)` |

### Data flow for sending a message
1. User submits → `DraftMessage` arrives in `ChatViewModel.send(draft:)`
2. `ChatMessage` (role: `"user"`) inserted into SwiftData; appended to `exyteMessages`
3. "…" placeholder bubble shown (status `.sending`)
4. `GeminiService.send(userText:history:)` called with full sorted history
5. Placeholder removed; AI `ChatMessage` inserted; `exyteMessages` updated; SwiftData saved

### UserProfile avatar pipeline
- **Photo:** `PhotosPicker` → `UIImage` → JPEG written to `Documents/avatar.jpg` → `avatarCacheKey` rotated (forces ExyteChat/Kingfisher cache invalidation)
- **Symbol:** `UIGraphicsImageRenderer` draws SF Symbol over a solid-color circle → same JPEG pipeline
- `UserProfile.avatarURL` (file URL) + `avatarCacheKey` are passed into ExyteChat's `User` struct

## Key Details

- Bundle ID: `com.apposestudio.ai.chat.AIChatApp`
- SPM dependencies: `https://github.com/exyte/Chat.git` (ExyteChat) — the swift-gemini-api package was replaced with a direct REST implementation
- The Gemini API key is hardcoded in `Config.swift` — do not move it to environment variables or `.xcconfig` unless the project requirements change
- `UserProfile` is injected at the App level and consumed with `@Environment(UserProfile.self)` in child views
- `ConversationListView` uses `NavigationPath` for programmatic push (e.g. auto-navigate into a newly created conversation)
