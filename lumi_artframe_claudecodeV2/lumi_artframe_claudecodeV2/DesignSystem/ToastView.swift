import SwiftUI

enum ToastType {
    case success
    case error

    var backgroundColor: Color {
        switch self {
        case .success: return Color.green
        case .error: return Color.Theme.red
        }
    }

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        }
    }
}

struct ToastView: View {
    let message: String
    let type: ToastType

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: type.icon)
                .font(.system(size: 20, weight: .bold))
            Text(message)
                .font(.system(size: 16, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(type.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.Theme.brutalBorder, lineWidth: 3)
        )
        .shadow(color: Color.Theme.brutalShadow, radius: 0, x: 4, y: 4)
    }
}

struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let type: ToastType

    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            if isPresented {
                ToastView(message: message, type: type)
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                isPresented = false
                            }
                        }
                    }
                    .zIndex(999)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isPresented)
    }
}

extension View {
    func toast(isPresented: Binding<Bool>, message: String, type: ToastType) -> some View {
        modifier(ToastModifier(isPresented: isPresented, message: message, type: type))
    }
}

#Preview {
    VStack {
        ToastView(message: "Login successful!", type: .success)
        ToastView(message: "Something went wrong", type: .error)
    }
    .padding()
    .background(Color.Theme.bg)
}
