import SwiftUI
import AVFoundation

struct DescriptionView: View {
    @Environment(AppRouter.self) private var router
    @Environment(CreationViewModel.self) private var creationVM
    @State private var audioRecorder: AVAudioRecorder?
    @State private var waveHeights: [CGFloat] = [8, 8, 8, 8, 8]
    @State private var waveTimer: Timer?

    var body: some View {
        ZStack {
            Color.Theme.bg.ignoresSafeArea()

            VStack(spacing: 24) {
                // Image preview
                if let imageData = creationVM.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 280)
                        .clipShape(RoundedRectangle(cornerRadius: BrutalStyle.cardCornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: BrutalStyle.cardCornerRadius)
                                .stroke(Color.Theme.brutalBorder, lineWidth: BrutalStyle.borderWidth)
                        )
                        .shadow(color: Color.Theme.brutalShadow, radius: 0, x: BrutalStyle.shadowOffset, y: BrutalStyle.shadowOffset)
                        .padding(.horizontal)
                }

                // Guide text
                VStack(spacing: 8) {
                    Text(creationVM.isRecording ? "Listening..." : "What did you draw?")
                        .font(Typography.headline)
                        .foregroundColor(.black)
                    Text(creationVM.isRecording ? "Tap to stop anytime" : "Tap the button below to start recording")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }

                // Audio waveform
                HStack(spacing: 6) {
                    ForEach(0..<5, id: \.self) { i in
                        Capsule()
                            .fill(Color.Theme.red)
                            .frame(width: 8, height: waveHeights[i])
                    }
                }
                .frame(height: 60)
                .animation(.easeInOut(duration: 0.2), value: waveHeights)

                // Record button
                Button {
                    toggleRecording()
                } label: {
                    ZStack {
                        Circle()
                            .fill(creationVM.isRecording ? .white : Color.Theme.red)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(Color.Theme.brutalBorder, lineWidth: BrutalStyle.borderWidth)
                            )
                            .shadow(color: Color.Theme.brutalShadow, radius: 0, x: 4, y: 4)

                        if creationVM.isRecording {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.Theme.red)
                                .frame(width: 28, height: 28)
                        } else {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        }
                    }
                }
                .accessibilityIdentifier("recordButton")

                // Skip link
                Button {
                    skipRecording()
                } label: {
                    Text("Or: Skip, let AI imagine")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .underline()
                }
                .accessibilityIdentifier("skipRecordingButton")
            }
            .padding(.vertical)
        }
        .accessibilityIdentifier("descriptionView")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { router.creationPath.removeLast() } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            ToolbarItem(placement: .principal) {
                BrutalBadge(text: "Tell a Story", icon: "mic.fill")
            }
        }
    }

    private func toggleRecording() {
        if creationVM.isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default)
        try? session.setActive(true)

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("recording.m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        audioRecorder = try? AVAudioRecorder(url: url, settings: settings)
        audioRecorder?.record()
        creationVM.isRecording = true
        creationVM.audioURL = url

        // Animate wave
        waveTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            waveHeights = (0..<5).map { _ in CGFloat.random(in: 10...50) }
        }
    }

    private func stopRecording() {
        audioRecorder?.stop()
        creationVM.isRecording = false
        waveTimer?.invalidate()
        waveHeights = [8, 8, 8, 8, 8]

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            router.creationPath.append(CreationRoute.generation)
        }
    }

    private func skipRecording() {
        router.creationPath.append(CreationRoute.generation)
    }
}

#Preview {
    NavigationStack {
        DescriptionView()
    }
    .environment(AppRouter())
    .environment(CreationViewModel(creationService: MockCreationService()))
}
