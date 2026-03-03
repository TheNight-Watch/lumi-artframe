import SwiftUI

extension Color {
    enum Theme {
        static let bg = Color(red: 255/255, green: 253/255, blue: 240/255)
        static let red = Color(red: 239/255, green: 71/255, blue: 58/255)
        static let yellow = Color(red: 255/255, green: 214/255, blue: 0/255)
        static let peach = Color(red: 255/255, green: 200/255, blue: 170/255)
        static let brutalBorder = Color.black
        static let brutalShadow = Color.black
        static let textPrimary = Color.black
        static let textSecondary = Color.gray
        static let white = Color.white
    }
}

struct BrutalStyle {
    static let borderWidth: CGFloat = 4
    static let shadowOffset: CGFloat = 6
    static let cornerRadius: CGFloat = 16
    static let cardCornerRadius: CGFloat = 24
}
