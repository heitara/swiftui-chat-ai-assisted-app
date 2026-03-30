import SwiftUI
import SwiftData
import ExyteChat

struct ChatScreen: View {
    let conversation: Conversation

    @Environment(\.modelContext) private var context
    @State private var viewModel: ChatViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                ChatView(messages: vm.exyteMessages) { draft in
                    vm.send(draft: draft)
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
                let vm = ChatViewModel(conversation: conversation, context: context)
                vm.onAppear()
                viewModel = vm
            }
        }
    }
}
