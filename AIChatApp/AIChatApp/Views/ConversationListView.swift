import SwiftUI
import SwiftData

struct ConversationListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Conversation.updatedAt, order: .reverse) private var conversations: [Conversation]

    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if conversations.isEmpty {
                    ContentUnavailableView(
                        "No Conversations",
                        systemImage: "bubble.left.and.bubble.right",
                        description: Text("Tap + to start a new chat")
                    )
                } else {
                    List {
                        ForEach(conversations) { conversation in
                            NavigationLink(value: conversation) {
                                ConversationRow(conversation: conversation)
                            }
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("Chats")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        createConversation()
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .navigationDestination(for: Conversation.self) { conversation in
                ChatScreen(conversation: conversation)
            }
        }
    }

    private func createConversation() {
        let conversation = Conversation()
        context.insert(conversation)
        try? context.save()
        path.append(conversation)
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            context.delete(conversations[index])
        }
        try? context.save()
    }
}

private struct ConversationRow: View {
    let conversation: Conversation

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(conversation.title.isEmpty ? "New Chat" : conversation.title)
                .font(.body)
                .lineLimit(1)
            Text(conversation.updatedAt, style: .relative)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}
