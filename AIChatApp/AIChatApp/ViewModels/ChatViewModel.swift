import Foundation
import SwiftData
import ExyteChat

@Observable
final class ChatViewModel {
    static let aiUser = User(id: "gemini", name: "Gemini", avatarURL: nil, isCurrentUser: false)

    var exyteMessages: [Message] = []
    var errorMessage: String?
    var showError = false

    private let conversation: Conversation
    private let context: ModelContext
    private let userProfile: UserProfile
    private let service = GeminiService()
    private var isSending = false

    var currentUser: User {
        User(id: "user",
             name: userProfile.name,
             avatarURL: userProfile.avatarURL,
             avatarCacheKey: userProfile.avatarCacheKey,
             isCurrentUser: true)
    }

    init(conversation: Conversation, context: ModelContext, userProfile: UserProfile) {
        self.conversation = conversation
        self.context = context
        self.userProfile = userProfile
    }

    func onAppear() {
        let sorted = conversation.messages.sorted { $0.createdAt < $1.createdAt }
        exyteMessages = sorted.map { toExyteMessage($0) }
    }

    func send(draft: DraftMessage) {
        guard !isSending else { return }
        let text = draft.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        isSending = true

        // Persist and show user message
        let userMsg = ChatMessage(role: "user", text: text, conversation: conversation)
        context.insert(userMsg)
        conversation.messages.append(userMsg)
        exyteMessages.append(toExyteMessage(userMsg))

        // Set conversation title from first user message
        if conversation.title.isEmpty {
            conversation.title = String(text.prefix(40))
        }

        // Placeholder while waiting
        let placeholder = Message(
            id: "thinking",
            user: Self.aiUser,
            status: .sending,
            text: "…"
        )
        exyteMessages.append(placeholder)

        let historySnapshot = conversation.messages
            .filter { $0.role != "thinking" }
            .sorted { $0.createdAt < $1.createdAt }
            .dropLast() // exclude the message we just added (already in userText)

        Task { @MainActor in
            defer { isSending = false }
            do {
                let reply = try await service.send(
                    userText: text,
                    history: Array(historySnapshot)
                )
                // Remove placeholder and add real reply
                exyteMessages.removeAll { $0.id == "thinking" }
                let aiMsg = ChatMessage(role: "assistant", text: reply, conversation: conversation)
                context.insert(aiMsg)
                conversation.messages.append(aiMsg)
                conversation.updatedAt = Date()
                exyteMessages.append(toExyteMessage(aiMsg))
                try context.save()
            } catch {
                exyteMessages.removeAll { $0.id == "thinking" }
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    private func toExyteMessage(_ msg: ChatMessage) -> Message {
        let user = msg.role == "user" ? currentUser : Self.aiUser
        return Message(
            id: msg.id.uuidString,
            user: user,
            status: .sent,
            createdAt: msg.createdAt,
            text: msg.text
        )
    }
}
