import SwiftUI

struct BrutalBadge: View {
    let text: String
    var icon: String?
    var backgroundColor: Color = Color.Theme.yellow
    var foregroundColor: Color = .black

    var body: some View {
        HStack(spacing: 6) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
            }
            Text(text)
                .font(.system(size: 14, weight: .bold))
        }
        .foregroundColor(foregroundColor)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(backgroundColor)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.Theme.brutalBorder, lineWidth: 3)
        )
        .background(
            Capsule()
                .fill(Color.Theme.brutalShadow)
                .offset(x: 3, y: 3)
        )
    }
}

#Preview {
    HStack {
        BrutalBadge(text: "Gallery", icon: "photo.stack.fill")
        BrutalBadge(text: "AI Magic", icon: "wand.and.stars", backgroundColor: .white)
    }
    .padding()
    .background(Color.Theme.bg)
}
