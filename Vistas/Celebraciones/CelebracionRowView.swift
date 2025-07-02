import SwiftUI

struct CelebracionRowView: View {
    let celebracion: Celebracion
    let esAdmin: Bool
    let estaSeleccionada: Bool
    let onToggleSeleccion: () -> Void
    
    @State private var mostrandoDetalle = false

    var body: some View {
        HStack(spacing: 12) {
            // Selector de Admin (sin cambios)
            if esAdmin {
                Button(action: onToggleSeleccion) {
                    ZStack {
                        Circle().stroke(Color.gray, lineWidth: 2)
                        if estaSeleccionada {
                            Circle().fill(Color.blue).frame(width: 14, height: 14)
                        }
                    }
                    .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }
            
            // --- TARJETA DE CONTENIDO REDISEÑADA ---
            VStack(alignment: .leading, spacing: 0) {
                
                // 1. ÁREA DE PREVIEW (IMAGEN O PDF)
                // Esta parte no cambia, sigue mostrando la imagen o el icono.
                ZStack {
                    Color(.systemGray5)
                    if celebracion.mimeType.starts(with: "image/") {
                        AsyncImage(url: URL(string: celebracion.pdfUrl)) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: { ProgressView() }
                    } else {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.red.opacity(0.8))
                    }
                }
                .frame(height: 180)
                
                // 2. NUEVO PANEL DE INFORMACIÓN
                // Este HStack ahora tiene su propio fondo gris.
                HStack {
                    Text(celebracion.titulo)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary) // Color de texto principal (negro o blanco)
                    
                    Spacer()
                    
                    Button("Abrir") {
                        mostrandoDetalle = true
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue) // Botón azul
                }
                .padding()
                .background(Color(.systemGray6)) // Fondo gris que se adapta a ambos modos
            }
            .clipShape(RoundedRectangle(cornerRadius: 12)) // Redondea toda la tarjeta
            .overlay( // Añade un borde sutil para mejor definición
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
            
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .sheet(isPresented: $mostrandoDetalle) {
            DetalleArchivoView(urlString: celebracion.pdfUrl, mimeType: celebracion.mimeType)
        }
    }
}
