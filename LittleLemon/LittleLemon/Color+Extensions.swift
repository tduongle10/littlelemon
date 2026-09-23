import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")))
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }

    static let primaryGreen = Color(hex: "#495E57")
    static let primaryYellow = Color(hex: "#F4CE14")

    static let secondaryPeach = Color(hex: "#EE9972")
    static let secondaryLightPeach = Color(hex: "#FBDABB")
    static let secondaryLightGray = Color(hex: "#EDEFEE")
    static let secondaryDarkGray = Color(hex: "#333333")

    static let textSecondary = Color(hex: "#757575")
}
