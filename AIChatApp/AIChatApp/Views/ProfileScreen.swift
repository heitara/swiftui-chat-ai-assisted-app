import SwiftUI
import PhotosUI

struct ProfileScreen: View {
    @Environment(UserProfile.self) private var profile
    @State private var nameText = ""
    @State private var showAvatarSheet = false
    @State private var showPhotoPicker = false
    @State private var showSymbolPicker = false
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    Button { showAvatarSheet = true } label: {
                        ProfileAvatarView(image: profile.avatarImage, size: 90)
                            .overlay(alignment: .bottomTrailing) {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.blue, Color(.systemBackground))
                                    .offset(x: 4, y: 4)
                            }
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            .listRowBackground(Color.clear)

            Section("Display Name") {
                TextField("Your name", text: $nameText)
                    .autocorrectionDisabled()
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            nameText = profile.name
        }
        .onDisappear {
            let trimmed = nameText.trimmingCharacters(in: .whitespacesAndNewlines)
            profile.name = trimmed.isEmpty ? "Noname" : trimmed
            profile.save()
        }
        .confirmationDialog("Change Avatar", isPresented: $showAvatarSheet, titleVisibility: .visible) {
            Button("Choose from Library") { showPhotoPicker = true }
            Button("Choose Symbol") { showSymbolPicker = true }
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhoto, matching: .images)
        .onChange(of: selectedPhoto) { _, item in
            Task {
                guard let item,
                      let data = try? await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else { return }
                profile.setPhoto(image)
            }
        }
        .sheet(isPresented: $showSymbolPicker) {
            SymbolPickerView()
        }
    }
}

struct ProfileAvatarView: View {
    let image: UIImage?
    let size: CGFloat

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.45))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.blue)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
