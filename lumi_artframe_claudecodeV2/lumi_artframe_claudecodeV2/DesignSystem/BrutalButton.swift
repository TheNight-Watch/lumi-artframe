import SwiftUI

struct BrutalButton: View {
    let title: String
    var icon: String?
    var backgroundColor: Color = Color.Theme.red
    var foregroundColor: Color = .white
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                } else {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .bold))
                    }
                    Text(title)
                        .font(Typography.buttonText)
                }
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: BrutalStyle.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: BrutalStyle.cornerRadius)
                    .stroke(Color.Theme.brutalBorder, lineWidth: BrutalStyle.borderWidth)
            )
            .shadow(color: Color.Theme.brutalShadow, radius: 0, x: BrutalStyle.shadowOffset, y: BrutalStyle.shadowOffset)
        }
        .disabled(isLoading)
    }
}

struct BrutalCircleButton: View {
    let icon: String
    var size: CGFloat = 44
    var backgroundColor: Color = Color.Theme.white
    var foregroundColor: Color = .black
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundColor(foregroundColor)
                .frame(width: size, height: size)
                .background(backgroundColor)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.Theme.brutalBorder, lineWidth: BrutalStyle.borderWidth)
                )
                .shadow(color: Color.Theme.brutalShadow, radius: 0, x: 4, y: 4)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        BrutalButton(title: "Login", icon: "wand.and.stars") {}
        BrutalButton(title: "Loading...", isLoading: true) {}
        BrutalCircleButton(icon: "xmark") {}
    }
    .padding()
    .background(Color.Theme.bg)
}
