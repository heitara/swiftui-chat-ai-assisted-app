import SwiftUI
import SwiftData

struct ConversationListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Conversation.updatedAt, order: .reverse) private var conversations: [Conversation]

    @State private var path = NavigationPath()
    @State private var conversationToRename: Conversation?
    @State private var showRenameDialog = false
    @State private var renameText = ""
    @State private var showProfile = false

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
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    delete(conversation: conversation)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                Button {
                                    startRename(conversation: conversation)
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("Chats")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showProfile = true } label: {
                        Image(systemName: "person.circle")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        createConversation()
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showProfile) {
                NavigationStack {
                    ProfileScreen()
                }
            }
            .navigationDestination(for: Conversation.self) { conversation in
                ChatScreen(conversation: conversation)
            }
            .alert("Rename Chat", isPresented: $showRenameDialog) {
                TextField("Chat name", text: $renameText)
                Button("Cancel", role: .cancel) {
                    conversationToRename = nil
                    renameText = ""
                }
                Button("Rename") {
                    if let conversation = conversationToRename {
                        renameConversation(conversation: conversation, newTitle: renameText)
                    }
                    conversationToRename = nil
                    renameText = ""
                }
            } message: {
                Text("Enter a new name for this chat")
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
    
    private func delete(conversation: Conversation) {
        context.delete(conversation)
        try? context.save()
    }
    
    private func startRename(conversation: Conversation) {
        conversationToRename = conversation
        renameText = conversation.title
        showRenameDialog = true
    }
    
    private func renameConversation(conversation: Conversation, newTitle: String) {
        conversation.title = newTitle
        conversation.updatedAt = Date()
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
