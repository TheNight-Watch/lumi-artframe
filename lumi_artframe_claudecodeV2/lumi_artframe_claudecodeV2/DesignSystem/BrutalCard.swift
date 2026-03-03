import SwiftUI

struct BrutalCard<Content: View>: View {
    var backgroundColor: Color = Color.Theme.white
    var cornerRadius: CGFloat = BrutalStyle.cardCornerRadius
    var borderWidth: CGFloat = BrutalStyle.borderWidth
    var shadowOffset: CGFloat = BrutalStyle.shadowOffset
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.Theme.brutalBorder, lineWidth: borderWidth)
            )
            .shadow(color: Color.Theme.brutalShadow, radius: 0, x: shadowOffset, y: shadowOffset)
    }
}

#Preview {
    BrutalCard {
        Text("Hello")
            .padding()
            .frame(maxWidth: .infinity)
    }
    .padding()
    .background(Color.Theme.bg)
}
