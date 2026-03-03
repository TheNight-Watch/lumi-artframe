import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let videoURL: String
    @State private var player: AVPlayer?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            } else {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(2)
            }
        }
        .onAppear {
            if let url = URL(string: videoURL) {
                player = AVPlayer(url: url)
                player?.play()
            }
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
}

#Preview {
    VideoPlayerView(videoURL: "https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4")
}
