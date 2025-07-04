import SwiftUI

struct ContenidoDetailView: View {
    let contenido: ContenidoNegocio
    
    // Formateador para calcular el tiempo transcurrido
    private static var relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale(identifier: "es_ES") // Para que salga en español
        return formatter
    }()
    
    // Propiedad que calcula el texto "hace X tiempo"
    private var tiempoTranscurrido: String {
        // Aseguramos que el timestamp no sea nulo
        guard let timestamp = contenido.timestamp else { return "" }
        
        // ✅ CÁLCULO CORREGIDO: Dividimos por 1000 para pasar de milisegundos a segundos
        let fecha = Date(timeIntervalSince1970: timestamp / 1000)
        
        // Usamos el formateador para obtener el texto relativo
        return Self.relativeFormatter.localizedString(for: fecha, relativeTo: Date())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Imagen principal, si existe
                if let imagenUrl = contenido.imagenUrl, let url = URL(string: imagenUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12)
                    } placeholder: {
                        ProgressView()
                    }
                }
                
                // Título
                Text(contenido.titulo)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Información de publicación
                HStack {
                    Text("Publicado por \(contenido.nombreNegocio)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(tiempoTranscurrido)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                }
                
                // Divisor
                Divider()
                
                // Descripción completa (sin límite de líneas)
                Text(contenido.descripcion)
                    .font(.body)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Detalle")
        .navigationBarTitleDisplayMode(.inline)
    }
}
