import SwiftUI

struct SplashView: View {
    @Environment(AppRouter.self) private var router
    @State private var bouncing = false

    var body: some View {
        ZStack {
            Color.Theme.bg.ignoresSafeArea()

            // Dot pattern background
            Canvas { context, size in
                let spacing: CGFloat = 20
                for x in stride(from: 0, to: size.width, by: spacing) {
                    for y in stride(from: 0, to: size.height, by: spacing) {
                        let rect = CGRect(x: x - 2, y: y - 2, width: 4, height: 4)
                        context.fill(Ellipse().path(in: rect), with: .color(Color.Theme.peach.opacity(0.3)))
                    }
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Brand icon
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.Theme.peach)
                        .frame(width: 112, height: 112)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.Theme.brutalBorder, lineWidth: BrutalStyle.borderWidth)
                        )
                        .shadow(color: Color.Theme.brutalShadow, radius: 0, x: BrutalStyle.shadowOffset, y: BrutalStyle.shadowOffset)

                    Image(systemName: "paintbrush.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                }
                .offset(y: bouncing ? -8 : 8)
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.4)
                        .repeatForever(autoreverses: true),
                    value: bouncing
                )

                // Brand name
                Text("画伴")
                    .font(Typography.largeTitle)
                    .foregroundColor(.black)

                // Slogan
                Text("让故事动起来")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.Theme.red)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.Theme.brutalBorder, lineWidth: 3)
                    )
                    .shadow(color: Color.Theme.brutalShadow, radius: 0, x: 4, y: 4)
                    .rotationEffect(.degrees(-2))
            }
        }
        .accessibilityIdentifier("splashView")
        .onAppear {
            bouncing = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    router.navigate(to: .login)
                }
            }
        }
    }
}

#Preview {
    SplashView()
        .environment(AppRouter())
}
