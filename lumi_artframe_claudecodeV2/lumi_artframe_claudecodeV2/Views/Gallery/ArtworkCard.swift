import SwiftUI

struct ArtworkCard: View {
    let artwork: Artwork
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            BrutalCard(cornerRadius: BrutalStyle.cardCornerRadius) {
                VStack(spacing: 0) {
                    // Image area
                    ZStack(alignment: .topLeading) {
                        AsyncImage(url: URL(string: artwork.imageURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure:
                                Color.gray.opacity(0.2)
                                    .overlay {
                                        Image(systemName: "photo")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                    }
                            default:
                                Color.gray.opacity(0.1)
                                    .overlay { ProgressView() }
                            }
                        }
                        .frame(height: 350)
                        .clipped()

                        // Video play overlay
                        if artwork.videoURL != nil {
                            Color.black.opacity(0.15)
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.white.opacity(0.9))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }

                        // AI badge
                        BrutalBadge(text: "AI Magic", icon: "wand.and.stars", backgroundColor: .white)
                            .padding(12)
                    }
                    .frame(height: 350)

                    // Info bar
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(artwork.title ?? "Untitled")
                                .font(Typography.headline)
                                .foregroundColor(.black)
                                .lineLimit(1)

                            Text(artwork.createdAt.formatted(date: .abbreviated, time: .omitted))
                                .font(Typography.caption)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        // Play button
                        Circle()
                            .fill(Color.Theme.red)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .stroke(Color.Theme.brutalBorder, lineWidth: 3)
                            )
                            .overlay {
                                Image(systemName: "play.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18))
                            }
                            .opacity(artwork.videoURL != nil ? 1 : 0.4)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.Theme.yellow)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ArtworkCard(
        artwork: MockGalleryService.fallbackArtworks[0]
    ) {}
    .padding()
    .background(Color.Theme.bg)
}
