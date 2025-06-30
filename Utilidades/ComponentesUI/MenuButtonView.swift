import SwiftUI

// La vista para cada botón-imagen
struct MenuButtonView: View {
    let item: MenuItem

    var body: some View {
        Image(item.imageName)
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.25), radius: 5, y: 4)
    }
}
// Preview para ver cómo queda en Xcode.
// Asegúrate de tener una imagen llamada "botonnoticias" en tus assets para que la preview funcione.
#Preview {
    MenuButtonView(item: MenuItem(
        title: "Noticias",
        imageName: "botonnoticias", // Usa una de tus imágenes reales
        destination: AnyView(Text("Vista de Noticias"))
    ))
    .padding()
}
