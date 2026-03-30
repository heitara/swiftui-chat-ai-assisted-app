# Plan: AIChat iOS App

## Context
Build a minimal AI chat iOS app from the blank SwiftUI scaffold. The app uses ExyteChat for the chat UI and swift-gemini-api for LLM responses. Users need two screens: a conversation list and an individual chat screen. Conversations persist to disk via SwiftData. The Gemini API key is hardcoded in `Config.swift`.

---

## SPM Dependencies to Add (via Xcode → Project → Package Dependencies)
- `https://github.com/exyte/Chat.git` → product: `ExyteChat`
- `https://github.com/paradigms-of-intelligence/swift-gemini-api.git` → product: `swift-gemini-api`

---

## Screens (2)

### 1. ConversationListView
- `NavigationStack` root
- `List` of `Conversation` objects sorted by `updatedAt` descending
- Each row shows: conversation title (first user message, truncated) + relative date
- Toolbar: "+" button → creates a new `Conversation` and pushes to ChatScreen
- Swipe-to-delete removes conversation (cascades to messages via SwiftData)
- Empty state: centered text "No conversations yet"

### 2. ChatScreen
- Receives a `Conversation` binding
- Uses ExyteChat `ChatView(messages: chatMessages) { draft in viewModel.send(draft) }`
- `.setAvailableInputs([.textOnly])` — text-only for minimal scope
- `.messageUseMarkdown(true)` — Gemini responses often use markdown
- Nav title = conversation title (editable via `.navigationTitle`)
- Sends user message → appends AI reply once response arrives (no streaming)
- Shows a "Thinking…" placeholder bubble while awaiting response

---

## File Structure

```
AIChatApp/AIChatApp/
├── Config.swift                         (new)
├── AIChatAppApp.swift                   (modify)
├── ContentView.swift                    (replace with routing)
├── Models/
│   ├── Conversation.swift               (new — SwiftData @Model)
│   └── ChatMessage.swift                (new — SwiftData @Model)
├── Services/
│   └── GeminiService.swift              (new)
├── ViewModels/
│   ├── ConversationsViewModel.swift     (new)
│   └── ChatViewModel.swift              (new)
└── Views/
    ├── ConversationListView.swift        (new)
    └── ChatScreen.swift                  (new)
```

---

## Implementation Details

### Config.swift
```swift
enum Config {
    static let geminiAPIKey = "PASTE_KEY_HERE"
    static let geminiModel  = "gemini-2.5-flash"
}
```

### SwiftData Models

**Conversation.swift**
```swift
@Model class Conversation {
    var id: UUID
    var title: String          // set from first user message text
    var createdAt: Date
    var updatedAt: Date
    @Relationship(deleteRule: .cascade) var messages: [ChatMessage]
}
```

**ChatMessage.swift**
```swift
@Model class ChatMessage {
    var id: UUID
    var role: String           // "user" | "assistant"
    var text: String
    var createdAt: Date
    @Relationship var conversation: Conversation?
}
```

### GeminiService.swift
- `@MainActor` struct (or actor)
- Single method: `func send(userText: String, history: [ChatMessage]) async throws -> String`
- Builds a plain-text prompt from history since `GeminiText.generateText(_:)` accepts a `String`:
  ```
  You are a helpful AI assistant. Continue this conversation:

  User: <msg>
  Assistant: <msg>
  User: <userText>
  ```
- Uses `GeminiAPI(apiKey: Config.geminiAPIKey).text.generateText(prompt)`
- Returns `responses.first ?? ""`
- Throws `GeminiAPIError` on failure (caller shows alert)

### ConversationsViewModel.swift
- `@Observable` class
- `@Query` for conversations managed in the View layer (SwiftData query injected via environment)
- Methods: `createConversation(context:) -> Conversation`, `delete(_:context:)`

### ChatViewModel.swift
- `@Observable` class
- Properties: `var exyteMessages: [Message] = []`, `var isThinking = false`, `var error: Error? = nil`
- Init: takes `Conversation`, `ModelContext`
- `onAppear()`: converts persisted `ChatMessage` array → ExyteChat `Message` objects
- `send(draft: DraftMessage)`:
  1. Persist user `ChatMessage` to SwiftData
  2. Append user ExyteChat `Message` (status `.sent`)
  3. Append a "Thinking…" placeholder with `isThinking = true`
  4. `async` call to `GeminiService.send(userText:history:)`
  5. Remove placeholder, append AI `Message`, persist AI `ChatMessage`
  6. Update `conversation.title` from first user message if still empty
  7. Update `conversation.updatedAt`
  8. On error: set `error`, show `.alert`

### ExyteChat Users (defined once, e.g. in ChatViewModel)
```swift
static let currentUser = User(id: "user",   name: "You",    avatarURL: nil, isCurrentUser: true)
static let aiUser      = User(id: "gemini", name: "Gemini", avatarURL: nil, isCurrentUser: false)
```

### AIChatAppApp.swift
```swift
@main struct AIChatAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Conversation.self, ChatMessage.self])
        }
    }
}
```

### ContentView.swift
Route directly to `ConversationListView()` (replaces placeholder).

---

## iOS Deployment Target
Change from 26.2 → **26.0** in Xcode project settings (IPHONEOS_DEPLOYMENT_TARGET).

---

## Verification
1. Add both SPM packages in Xcode and confirm they resolve without errors.
2. Run on iOS 26 simulator — ConversationListView should appear with empty state.
3. Tap "+" → navigates to ChatScreen.
4. Type a message and send → user bubble appears, then AI reply appears.
5. Kill and relaunch app → conversation and messages are still present (SwiftData persistence).
6. Swipe-delete a conversation → it and its messages are removed.
