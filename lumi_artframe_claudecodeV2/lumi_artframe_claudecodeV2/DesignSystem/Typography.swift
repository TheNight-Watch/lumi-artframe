import SwiftUI

enum Typography {
    static let brandFont = "ZCOOLKuaiLe-Regular"

    static let largeTitle = Font.custom(brandFont, size: 64)
    static let title = Font.custom(brandFont, size: 40)
    static let headline = Font.custom(brandFont, size: 28)
    static let subheadline = Font.custom(brandFont, size: 20)
    static let body = Font.system(size: 20, weight: .regular)
    static let caption = Font.system(size: 14, weight: .regular)
    static let buttonText = Font.system(size: 18, weight: .bold)
    static let small = Font.system(size: 12, weight: .regular)
}
