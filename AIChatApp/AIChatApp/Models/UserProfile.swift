import Foundation
import SwiftUI

@Observable
final class UserProfile {
    enum AvatarStyle: String {
        case photo, symbol
    }

    static let availableColors: [Color] = [
        .blue, .indigo, .purple, .pink, .red, .orange, .green, .teal, .cyan, .mint
    ]

    static let availableSymbols: [String] = [
        "person.fill", "person.circle.fill", "star.fill", "heart.fill",
        "bolt.fill", "leaf.fill", "moon.fill", "sun.max.fill",
        "cloud.fill", "flame.fill", "drop.fill", "snowflake",
        "cat.fill", "dog.fill", "bird.fill", "hare.fill",
        "gamecontroller.fill", "music.note", "book.fill", "paintbrush.fill",
        "camera.fill", "headphones", "bicycle", "car.fill",
        "airplane", "globe.americas.fill", "house.fill",
        "trophy.fill", "crown.fill", "figure.walk"
    ]

    var name: String = "Noname"
    var avatarStyle: AvatarStyle = .symbol
    var symbolName: String = "person.fill"
    var symbolColorIndex: Int = 0
    private(set) var avatarCacheKey: String = UUID().uuidString
    private(set) var avatarURL: URL?
    private(set) var avatarImage: UIImage?

    init() {
        load()
        if avatarImage == nil {
            renderAndSaveSymbol()
        }
    }

    func setPhoto(_ image: UIImage) {
        avatarStyle = .photo
        persistAvatar(image)
        save()
    }

    func applySymbol(name: String, colorIndex: Int) {
        symbolName = name
        symbolColorIndex = colorIndex
        avatarStyle = .symbol
        renderAndSaveSymbol()
        save()
    }

    static func renderSymbol(name: String, color: Color, size: CGFloat = 120) -> UIImage {
        let sz = CGSize(width: size, height: size)
        return UIGraphicsImageRenderer(size: sz).image { _ in
            UIColor(color).setFill()
            UIBezierPath(ovalIn: CGRect(origin: .zero, size: sz)).fill()
            let cfg = UIImage.SymbolConfiguration(pointSize: size * 0.45, weight: .medium)
            if let img = UIImage(systemName: name, withConfiguration: cfg)?
                .withTintColor(.white, renderingMode: .alwaysOriginal) {
                img.draw(at: CGPoint(x: (size - img.size.width) / 2,
                                     y: (size - img.size.height) / 2))
            }
        }
    }

    private func renderAndSaveSymbol() {
        let image = Self.renderSymbol(
            name: symbolName,
            color: Self.availableColors[symbolColorIndex]
        )
        persistAvatar(image)
    }

    private func persistAvatar(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.85),
              let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { return }
        let url = dir.appendingPathComponent("avatar.jpg")
        try? data.write(to: url, options: .atomic)
        avatarCacheKey = UUID().uuidString
        avatarURL = url
        avatarImage = image
    }

    func save() {
        let d = UserDefaults.standard
        d.set(name, forKey: "profile.name")
        d.set(avatarStyle.rawValue, forKey: "profile.avatarStyle")
        d.set(symbolName, forKey: "profile.symbolName")
        d.set(symbolColorIndex, forKey: "profile.symbolColorIndex")
        d.set(avatarCacheKey, forKey: "profile.avatarCacheKey")
    }

    private func load() {
        let d = UserDefaults.standard
        name = d.string(forKey: "profile.name") ?? "Noname"
        avatarStyle = AvatarStyle(rawValue: d.string(forKey: "profile.avatarStyle") ?? "") ?? .symbol
        symbolName = d.string(forKey: "profile.symbolName") ?? "person.fill"
        symbolColorIndex = d.integer(forKey: "profile.symbolColorIndex")
        avatarCacheKey = d.string(forKey: "profile.avatarCacheKey") ?? UUID().uuidString

        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let url = dir.appendingPathComponent("avatar.jpg")
            if FileManager.default.fileExists(atPath: url.path),
               let data = try? Data(contentsOf: url) {
                avatarURL = url
                avatarImage = UIImage(data: data)
            }
        }
    }
}
