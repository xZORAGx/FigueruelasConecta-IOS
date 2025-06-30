import SwiftUI

struct NoticiaRowView: View {
    let noticia: Noticia

    var body: some View {
        // --- PRUEBA DIAGNÓSTICA ---
        // Esta línea imprimirá en la consola el contenido EXACTO de 'imagenURL' para cada noticia.
        // El 'let _ =' es un truco para poder ejecutar código dentro del cuerpo de la vista.
        let _ = print("-> Noticia: '\(noticia.titulo)', Valor de imagenURL: '\(noticia.imagenURL)'")
        
        HStack(spacing: 16) {
            
            if let url = URL(string: noticia.imagenURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 80, height: 80)
                .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(noticia.titulo)
                    .font(.headline)
                    .lineLimit(2)
                Text(noticia.descripcion)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
        }
        .padding(.vertical, 8)
    }
}
