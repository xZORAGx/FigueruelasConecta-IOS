import SwiftUI

struct EmpleoRowView: View {
    // Propiedades adaptadas al nuevo patrón de selección.
    let empleo: Empleo
    let esAdmin: Bool
    let estaSeleccionada: Bool
    let onToggleSeleccion: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            
            // El selector de Celebraciones, adaptado.
            if esAdmin {
                Button(action: onToggleSeleccion) {
                    ZStack {
                        Circle().stroke(Color.gray, lineWidth: 2)
                        if estaSeleccionada {
                            // Usamos gris para mantener la estética de Empleo
                            Circle().fill(Color.gray).frame(width: 14, height: 14)
                        }
                    }
                    .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }
            
            // Contenido de la fila (imagen y texto)
            AsyncImage(url: URL(string: empleo.imagenUrl ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "photo.fill").font(.largeTitle).foregroundColor(.gray)
                case .empty:
                    ProgressView()
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(empleo.titulo)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(empleo.descripcion)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
