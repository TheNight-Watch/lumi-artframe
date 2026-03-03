import SwiftUI

struct DetailView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.dismiss) private var dismiss
    var fallbackArtwork: Artwork?
    @Environment(CreationViewModel.self) private var creationVM: CreationViewModel?

    private var artwork: Artwork? {
        fallbackArtwork ?? creationVM?.generatedArtwork
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.Theme.bg.ignoresSafeArea()

            if let artwork {
                ScrollView {
                    VStack(spacing: 20) {
                        // Hero image
                        heroImage(artwork)

                        // Title & date
                        VStack(spacing: 4) {
                            Text(artwork.title ?? "Untitled")
                                .font(Typography.headline)
                            Text(artwork.createdAt.formatted(date: .long, time: .omitted))
                                .font(Typography.caption)
                                .foregroundColor(.gray)
                        }

                        // Story card
                        storyCard(artwork)

                        // Divider arrow
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)

                        // Parent report
                        parentReport(artwork)
                    }
                    .padding()
                    .padding(.top, 60)
                    .padding(.bottom, 40)
                }
            } else {
                Text("No artwork data")
                    .foregroundColor(.gray)
            }

            // Floating top bar
            topBar
        }
        .accessibilityIdentifier("detailView")
        .navigationBarHidden(true)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            BrutalCircleButton(icon: "arrow.left") { dismiss() }
            Spacer()
            Text("Detail")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.black)
                .clipShape(Capsule())
                .shadow(color: Color.Theme.yellow, radius: 0, x: 3, y: 3)
            Spacer()
            BrutalCircleButton(icon: "square.and.arrow.up") {}
                .opacity(0.5)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - Hero Image

    private func heroImage(_ artwork: Artwork) -> some View {
        BrutalCard(cornerRadius: 20) {
            ZStack {
                AsyncImage(url: URL(string: artwork.imageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    case .failure:
                        Color.gray.opacity(0.2)
                    default:
                        Color.gray.opacity(0.1).overlay { ProgressView() }
                    }
                }
                .frame(height: 300)
                .clipped()

                // Video overlay
                if artwork.videoStatus == .completed, artwork.videoURL != nil {
                    Color.black.opacity(0.3)
                    NavigationLink(destination: VideoPlayerView(videoURL: artwork.videoURL!)) {
                        Circle()
                            .fill(Color.Theme.red)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(Color.Theme.brutalBorder, lineWidth: 3)
                            )
                            .overlay {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                            }
                    }
                } else if artwork.videoStatus == .processing {
                    Color.black.opacity(0.3)
                    VStack(spacing: 8) {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.5)
                        Text("Video generating...")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                // AI badge
                VStack {
                    HStack {
                        BrutalBadge(text: "AI Magic", icon: "wand.and.stars", backgroundColor: .white)
                        Spacer()
                    }
                    Spacer()
                }
                .padding(12)
            }
            .frame(height: 300)
        }
    }

    // MARK: - Story Card

    private func storyCard(_ artwork: Artwork) -> some View {
        BrutalCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "book.fill")
                        .foregroundColor(Color.Theme.red)
                    Text("Story")
                        .font(.system(size: 20, weight: .bold))
                }

                if let title = artwork.storyTitle {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                }

                if let content = artwork.storyContent {
                    Text(content)
                        .font(Typography.body)
                        .lineSpacing(6)
                        .padding()
                        .background(Color.Theme.bg)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
    }

    // MARK: - Parent Report

    private func parentReport(_ artwork: Artwork) -> some View {
        BrutalCard(backgroundColor: Color.Theme.yellow) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black)
                        .clipShape(Circle())

                    Text("Parent Report")
                        .font(.system(size: 20, weight: .bold))

                    Spacer()

                    Text("Parents Only")
                        .font(.system(size: 12, weight: .bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.7))
                        .clipShape(Capsule())
                }

                // Creativity analysis
                if let creativity = artwork.creativityAnalysis {
                    analysisCard(
                        icon: "flame.fill",
                        iconColor: Color.Theme.red,
                        title: "Creativity Analysis",
                        content: creativity
                    )
                }

                // Mood analysis
                if let mood = artwork.moodAnalysis {
                    analysisCard(
                        icon: "face.smiling.fill",
                        iconColor: Color.Theme.yellow,
                        title: "Mood Analysis",
                        content: mood
                    )
                }

                // Additional insights
                if let insights = artwork.additionalInsights {
                    analysisCard(
                        icon: "lightbulb.fill",
                        iconColor: Color.Theme.peach,
                        title: "Additional Insights",
                        content: insights
                    )
                }

                // Monthly report button
                BrutalButton(title: "View Full Monthly Report", icon: "chart.bar.fill") {}
                    .padding(.top, 8)
            }
            .padding()
        }
    }

    private func analysisCard(icon: String, iconColor: Color, title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.system(size: 16, weight: .bold))
            }
            Rectangle()
                .fill(iconColor)
                .frame(height: 3)
                .frame(width: 60)
            Text(content)
                .font(.system(size: 15))
                .foregroundColor(.black.opacity(0.8))
                .lineSpacing(4)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        DetailView(fallbackArtwork: MockGalleryService.fallbackArtworks[0])
    }
    .environment(AppRouter())
}
