import SwiftUI

struct InstalacionRowView: View {
    let instalacion: Instalacion

    var body: some View {
        // Envolvemos todo en un NavigationLink
        NavigationLink(destination: DetalleInstalacionView(instalacion: instalacion)) {
            // El contenido de la tarjeta se queda igual
            VStack(alignment: .leading, spacing: 0) {
                AsyncImage(url: URL(string: instalacion.imagenUrl)) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    ZStack {
                        Color.gray.opacity(0.3)
                        ProgressView()
                    }
                }
                .frame(height: 180)
                .clipped()

                VStack(alignment: .leading, spacing: 8) {
                    Text(instalacion.titulo)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text(instalacion.descripcion)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                .padding()
            }
        }
        // Estilos para que la tarjeta se vea bien dentro de la lista
        .buttonStyle(PlainButtonStyle()) // Evita que todo el texto se ponga azul
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
