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
    @State private var userProfile = UserProfile()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Conversation.self, ChatMessage.self])
                .environment(userProfile)
        }
    }
}
