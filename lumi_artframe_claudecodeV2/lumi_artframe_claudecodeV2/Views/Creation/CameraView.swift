import SwiftUI
import PhotosUI

struct CameraView: View {
    @Environment(AppRouter.self) private var router
    @Environment(CreationViewModel.self) private var creationVM
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showCamera = false
    @State private var capturedImage: UIImage?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                // Top bar
                HStack {
                    BrutalCircleButton(icon: "xmark", backgroundColor: .white) {
                        router.dismissCreation()
                    }
                    .accessibilityIdentifier("cameraCloseButton")
                    Spacer()
                }
                .padding(.horizontal)

                Spacer()

                // Viewfinder area
                ZStack {
                    if let imageData = creationVM.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(3/4, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            .aspectRatio(3/4, contentMode: .fit)
                            .overlay {
                                VStack(spacing: 16) {
                                    Image(systemName: "camera.viewfinder")
                                        .font(.system(size: 48))
                                        .foregroundColor(.white.opacity(0.5))
                                    Text("Place artwork in frame")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            .overlay {
                                viewfinderCorners
                            }
                    }
                }
                .padding(.horizontal, 40)

                Spacer()

                // Bottom controls
                HStack(spacing: 40) {
                    // Album button
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        VStack(spacing: 6) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 24))
                            Text("Album")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(.white)
                    }

                    // Shutter button
                    Button {
                        showCamera = true
                    } label: {
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 80, height: 80)
                            Circle()
                                .fill(Color.Theme.red)
                                .frame(width: 64, height: 64)
                        }
                    }
                    .accessibilityIdentifier("shutterButton")

                    // Confirm button
                    if creationVM.hasImage {
                        Button {
                            router.creationPath.append(CreationRoute.description)
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                Text("Confirm")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(.green)
                        }
                        .accessibilityIdentifier("confirmImageButton")
                    } else {
                        Color.clear.frame(width: 60, height: 50)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    creationVM.imageData = data
                    router.creationPath.append(CreationRoute.description)
                }
            }
        }
        .accessibilityIdentifier("cameraView")
        .fullScreenCover(isPresented: $showCamera) {
            ImagePicker(image: $capturedImage)
        }
        .onChange(of: capturedImage) { _, newImage in
            if let image = newImage, let data = image.jpegData(compressionQuality: 0.8) {
                creationVM.imageData = data
                router.creationPath.append(CreationRoute.description)
            }
        }
    }

    private var viewfinderCorners: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let len: CGFloat = 40
            let lw: CGFloat = 4

            Path { path in
                // Top-left
                path.move(to: CGPoint(x: 0, y: len))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: len, y: 0))
                // Top-right
                path.move(to: CGPoint(x: w - len, y: 0))
                path.addLine(to: CGPoint(x: w, y: 0))
                path.addLine(to: CGPoint(x: w, y: len))
                // Bottom-right
                path.move(to: CGPoint(x: w, y: h - len))
                path.addLine(to: CGPoint(x: w, y: h))
                path.addLine(to: CGPoint(x: w - len, y: h))
                // Bottom-left
                path.move(to: CGPoint(x: len, y: h))
                path.addLine(to: CGPoint(x: 0, y: h))
                path.addLine(to: CGPoint(x: 0, y: h - len))
            }
            .stroke(Color.white, lineWidth: lw)
        }
    }
}

// MARK: - UIImagePickerController wrapper

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        #if targetEnvironment(simulator)
        picker.sourceType = .photoLibrary
        #else
        picker.sourceType = .camera
        #endif
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.image = info[.originalImage] as? UIImage
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    CameraView()
        .environment(AppRouter())
        .environment(CreationViewModel(creationService: MockCreationService()))
}
