//
//  AIChatAppApp.swift
//  AIChatApp
//
//  Created by Emil Atanasov on 30.03.26.
//

import SwiftUI
import SwiftData

@main
struct AIChatAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Conversation.self, ChatMessage.self])
        }
    }
}
