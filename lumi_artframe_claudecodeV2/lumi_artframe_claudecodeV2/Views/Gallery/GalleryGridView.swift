import SwiftUI

struct GalleryGridView: View {
    let artworks: [Artwork]
    let onSelect: (Artwork) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(artworks) { artwork in
                    gridCard(artwork)
                }
            }
            .padding()
        }
    }

    private func gridCard(_ artwork: Artwork) -> some View {
        Button {
            onSelect(artwork)
        } label: {
            BrutalCard(cornerRadius: 16) {
                VStack(spacing: 0) {
                    AsyncImage(url: URL(string: artwork.imageURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fill)
                        case .failure:
                            Color.gray.opacity(0.2)
                                .overlay {
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                }
                        default:
                            Color.gray.opacity(0.1)
                                .overlay { ProgressView() }
                        }
                    }
                    .frame(height: 160)
                    .clipped()

                    VStack(alignment: .leading, spacing: 4) {
                        Text(artwork.title ?? "Untitled")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                            .lineLimit(1)
                        Text(artwork.createdAt.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color.Theme.yellow.opacity(0.3))
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    GalleryGridView(artworks: MockGalleryService.fallbackArtworks) { _ in }
        .background(Color.Theme.bg)
}
