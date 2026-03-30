//
//  ContentView.swift
//  AIChatApp
//
//  Created by Emil Atanasov on 30.03.26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        ConversationListView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Conversation.self, ChatMessage.self], inMemory: true)
}
