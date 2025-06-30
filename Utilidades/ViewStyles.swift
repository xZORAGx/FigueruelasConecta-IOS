import SwiftUI

// Modificador para los campos de texto del Login
struct CustomTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(height: 56)
            .background(Color.black.opacity(0.2))
            .foregroundColor(.white) // Asegura que el placeholder sea blanco
            .tint(.white) // Asegura que el cursor y el texto que escribes sean blancos
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
    }
}

// Estilo para los botones principales (sin cambios)
struct PrimaryButtonStyle: ButtonStyle {
    private let colorPrincipal = Color(hex: "#2ECC71")
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(colorPrincipal)
            .foregroundColor(.white)
            .font(.headline.weight(.bold))
            .cornerRadius(12)
            .shadow(color: colorPrincipal.opacity(0.4), radius: 8, y: 5)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
