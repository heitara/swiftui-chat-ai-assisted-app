import SwiftUI
import SwiftData
import ExyteChat
import UIKit

enum ChatMenuAction: MessageMenuAction {
    case copy
    case share
    
    func title() -> String {
        switch self {
        case .copy: return "Copy"
        case .share: return "Share"
        }
    }
    
    func icon() -> Image {
        switch self {
        case .copy: return Image(systemName: "doc.on.doc")
        case .share: return Image(systemName: "square.and.arrow.up")
        }
    }
    
    static func menuItems(for message: Message) -> [ChatMenuAction] {
        return [.copy, .share]
    }
}

struct ChatScreen: View {
    let conversation: Conversation

    @Environment(\.modelContext) private var context
    @Environment(UserProfile.self) private var profile
    @State private var viewModel: ChatViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                ChatView(messages: vm.exyteMessages) { draft in
                    vm.send(draft: draft)
                } messageMenuAction: { (action: ChatMenuAction, defaultActionClosure, message) in
                    switch action {
                    case .copy:
                        UIPasteboard.general.string = message.text
                    case .share:
                        let activityVC = UIActivityViewController(activityItems: [message.text], applicationActivities: nil)
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootVC = windowScene.windows.first?.rootViewController {
                            // Handle iPad presentation requirements for UIActivityViewController by tying it to the center
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                let view = rootVC.view!
                                activityVC.popoverPresentationController?.sourceView = view
                                activityVC.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                                activityVC.popoverPresentationController?.permittedArrowDirections = []
                            }
                            rootVC.present(activityVC, animated: true)
                        }
                    }
                }
                .setAvailableInputs([.text])
                .messageUseMarkdown(true)
                .alert("Error", isPresented: Binding(
                    get: { vm.showError },
                    set: { vm.showError = $0 }
                )) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(vm.errorMessage ?? "Unknown error")
                }
            }
        }
        .navigationTitle(conversation.title.isEmpty ? "New Chat" : conversation.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel == nil {
                viewModel = ChatViewModel(conversation: conversation, context: context, userProfile: profile)
            }
            viewModel?.onAppear()
        }
    }
}
