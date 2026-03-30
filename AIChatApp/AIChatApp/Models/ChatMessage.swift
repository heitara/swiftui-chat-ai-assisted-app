import Foundation
import SwiftData

@Model
final class ChatMessage {
    var id: UUID
    var role: String  // "user" | "assistant"
    var text: String
    var createdAt: Date
    @Relationship var conversation: Conversation?

    init(role: String, text: String, conversation: Conversation? = nil) {
        self.id = UUID()
        self.role = role
        self.text = text
        self.createdAt = Date()
        self.conversation = conversation
    }
}
