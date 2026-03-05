import SwiftUI

struct GenerationView: View {
    @Environment(AppRouter.self) private var router
    @Environment(CreationViewModel.self) private var creationVM
    @State private var rotationAngle: Double = 0

    var body: some View {
        ZStack {
            Color.Theme.bg.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Magic animation
                ZStack {
                    Circle()
                        .fill(Color.Theme.yellow)
                        .frame(width: 150, height: 150)
                        .overlay(
                            Circle()
                                .stroke(Color.Theme.brutalBorder, lineWidth: BrutalStyle.borderWidth)
                        )
                        .background(
                            Circle()
                                .fill(Color.Theme.brutalShadow)
                                .offset(x: BrutalStyle.shadowOffset, y: BrutalStyle.shadowOffset)
                        )

                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 64))
                        .foregroundColor(Color.Theme.red)
                        .rotationEffect(.degrees(rotationAngle))
                }

                // Status text
                Text(creationVM.uploadProgressText.isEmpty ? "Casting magic..." : creationVM.uploadProgressText)
                    .font(Typography.headline)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)

                // Progress bar
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white)
                        .frame(width: 200, height: 16)
                        .overlay(
                            Capsule()
                                .stroke(Color.Theme.brutalBorder, lineWidth: 3)
                        )

                    Capsule()
                        .fill(Color.Theme.red.opacity(0.7))
                        .frame(width: progressWidth, height: 12)
                        .padding(.horizontal, 2)
                }

                Spacer()

                if let error = creationVM.errorMessage {
                    VStack(spacing: 12) {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(Color.Theme.red)
                        BrutalButton(title: "Retry") {
                            Task { await creationVM.executeMagicGeneration() }
                        }
                        .frame(width: 160)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .accessibilityIdentifier("generationView")
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
            Task {
                await creationVM.executeMagicGeneration()
                if creationVM.generatedArtwork != nil {
                    router.creationPath.append(CreationRoute.detail)
                }
            }
        }
    }

    private var progressWidth: CGFloat {
        let angle = rotationAngle.truncatingRemainder(dividingBy: 360)
        if angle < 90 { return 20 }
        if angle < 180 { return 100 }
        return 196
    }
}

#Preview {
    NavigationStack {
        GenerationView()
    }
    .environment(AppRouter())
    .environment(CreationViewModel(creationService: MockCreationService(), audioTranscriptionService: MockAudioTranscriptionService()))
}
