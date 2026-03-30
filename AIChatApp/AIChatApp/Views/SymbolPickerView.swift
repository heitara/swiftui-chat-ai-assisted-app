import SwiftUI

struct SymbolPickerView: View {
    @Environment(UserProfile.self) private var profile
    @Environment(\.dismiss) private var dismiss

    @State private var selectedSymbol = "person.fill"
    @State private var selectedColorIndex = 0

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)

    var body: some View {
        let previewImage = UserProfile.renderSymbol(
            name: selectedSymbol,
            color: UserProfile.availableColors[selectedColorIndex],
            size: 80
        )
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(uiImage: previewImage)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .padding(.top, 8)

                    colorSection
                    symbolGrid
                }
                .padding(.bottom, 24)
            }
            .navigationTitle("Choose Symbol")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        profile.applySymbol(name: selectedSymbol, colorIndex: selectedColorIndex)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                selectedSymbol = profile.symbolName
                selectedColorIndex = profile.symbolColorIndex
            }
        }
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Background")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(UserProfile.availableColors.indices, id: \.self) { i in
                        Circle()
                            .fill(UserProfile.availableColors[i])
                            .frame(width: 36, height: 36)
                            .overlay {
                                if i == selectedColorIndex {
                                    Image(systemName: "checkmark")
                                        .font(.caption.bold())
                                        .foregroundStyle(.white)
                                }
                            }
                            .onTapGesture { selectedColorIndex = i }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var symbolGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Symbol")
                .font(.headline)
                .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(UserProfile.availableSymbols, id: \.self) { symbol in
                    let isSelected = symbol == selectedSymbol
                    Button { selectedSymbol = symbol } label: {
                        Image(systemName: symbol)
                            .font(.title2)
                            .frame(width: 54, height: 54)
                            .background(
                                isSelected
                                    ? Color.accentColor.opacity(0.15)
                                    : Color(.secondarySystemGroupedBackground)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay {
                                if isSelected {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.accentColor, lineWidth: 2)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
}
