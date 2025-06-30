import SwiftUI

struct DetalleNoticiaView: View {
    let noticia: Noticia

    var body: some View {
        ScrollView {
            // Usamos un VStack para el contenido principal.
            VStack(alignment: .leading, spacing: 0) {
                
                // --- INICIO DE LA CORRECCIÓN ---
                // Solo si podemos crear una URL válida a partir del string...
                if let url = URL(string: noticia.imagenURL) {
                    
                    // ...entonces, y solo entonces, mostramos el bloque de la imagen.
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        // El placeholder gris solo aparecerá si la URL es válida pero la imagen tarda en cargar.
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.3))
                            .frame(height: 250)
                    }
                    .frame(height: 250)
                    .clipped()
                }
                // --- FIN DE LA CORRECCIÓN ---

                // El título y la descripción se mantienen igual.
                // Si no hay imagen, este será el primer elemento en el VStack.
                VStack(alignment: .leading, spacing: 16) {
                    Text(noticia.titulo)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(noticia.descripcion)
                        .font(.body)
                }
                .padding()
            }
        }
        .standardToolbar() // Aplicamos la barra de herramientas estándar.
    }
}


struct DetalleNoticiaView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview para una noticia CON imagen
        NavigationView {
            DetalleNoticiaView(noticia: Noticia(
                titulo: "Noticia con Imagen",
                descripcion: "Esta es la descripción.",
                imagenURL: "https://firebasestorage.googleapis.com:443/v0/b/trabajo-fin-grado-7af82.firebasestorage.app/o/Noticias%2F1751298565.930135.jpg?alt=media&token=c9584ff3-d4c6-4221-8271-e03566a2096a",
                timestamp: Date().timeIntervalSince1970 * 1000,
                fechaExpiracion: .init(date: Date()))
            )
            .environmentObject(AuthManager.shared)
        }
        
        // Preview para una noticia SIN imagen
        NavigationView {
            DetalleNoticiaView(noticia: Noticia(
                titulo: "Noticia sin Imagen",
                descripcion: "El título debería aparecer arriba del todo.",
                imagenURL: "", // String vacío para simular que no hay imagen
                timestamp: Date().timeIntervalSince1970 * 1000,
                fechaExpiracion: .init(date: Date()))
            )
            .environmentObject(AuthManager.shared)
        }
    }
}
