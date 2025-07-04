import SwiftUI

struct NovedadRowView: View {
    let novedad: ContenidoNegocio
    
    // ✅ AÑADIDO: Lógica para calcular el tiempo transcurrido
    private static var relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()
    
    private var tiempoTranscurrido: String {
        guard let timestamp = novedad.timestamp else { return "" }
        let fecha = Date(timeIntervalSince1970: timestamp / 1000)
        return Self.relativeFormatter.localizedString(for: fecha, relativeTo: Date())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Cabecera con logo, nombre y ahora el tiempo
            HStack {
                AsyncImage(url: URL(string: novedad.logoNegocioUrl ?? "")) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "building.2.crop.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                        .frame(width: 40, height: 40)
                }
                
                VStack(alignment: .leading) {
                    Text(novedad.nombreNegocio)
                        .font(.headline)
                        .fontWeight(.bold)
                    // ✅ AÑADIDO: Texto con el tiempo transcurrido
                    Text(tiempoTranscurrido)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer() // Empuja todo a la izquierda
            }

            // Título de la novedad
            Text(novedad.titulo)
                .font(.title3)
                .fontWeight(.semibold)
            
            // Imagen de la novedad
            if let imagenUrl = novedad.imagenUrl, let url = URL(string: imagenUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(12)
                } placeholder: {
                    ProgressView()
                        .frame(height: 200)
                }
            }
            
            // ❌ ELIMINADO: El texto de la descripción ya no es visible aquí
        }
        .padding()
        .background(Color(.systemBackground)) // Un fondo blanco/negro limpio
        .cornerRadius(16)
        // ✅ AÑADIDO: Sombra para dar efecto de tarjeta
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
