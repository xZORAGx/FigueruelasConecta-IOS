//  FigueruelasConecta/Vistas/Deportes/DeportesActividadRowView.swift

import SwiftUI
import PDFKit

// MARK: - Vista de Fila Principal
struct DeportesActividadRowView: View {
    let actividad: Actividad
    let esAdmin: Bool
    let isSelected: Bool
    let onSelect: () -> Void
    
    // Un único estado para mostrar la vista de detalle
    @State private var mostrandoDetalle = false

    var body: some View {
        HStack(spacing: 15) {
            // Checkbox de selección para el Admin
            if esAdmin {
                Button(action: onSelect) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }

            // Icono del tipo de archivo
            if let urlString = actividad.imageUrl, let url = URL(string: urlString) {
                if url.pathExtension.lowercased() == "pdf" {
                    Image(systemName: "doc.text.fill")
                        .font(.title)
                        .foregroundColor(.red)
                        .frame(width: 40)
                } else {
                    AsyncImage(url: url) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "photo")
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            
            // Título de la actividad
            Text(actividad.titulo)
                .font(.headline)
            
            Spacer()
            
            // Botón "Abrir" unificado
            Button("Abrir") {
                mostrandoDetalle = true
            }
            .buttonStyle(.bordered)
            .tint(.blue)
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $mostrandoDetalle) {
            // La sheet siempre muestra la misma vista de detalle, que decide qué visor usar
            DeportesDetalleArchivoView(urlString: actividad.imageUrl ?? "")
        }
    }
}


// MARK: - Vistas de Detalle (dentro del mismo archivo)

// --- Vista principal que decide cuál de los dos visores mostrar ---
fileprivate struct DeportesDetalleArchivoView: View {
    let urlString: String
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if let url = URL(string: urlString) {
                    // Decidimos qué visor usar basándonos en la extensión del archivo
                    if url.pathExtension.lowercased() == "pdf" {
                        DeportesVisorDePDF(url: url)
                    } else {
                        // Si no es pdf, asumimos que es una imagen
                        DeportesVisorDeImagen(url: url)
                    }
                } else {
                    Text("URL del archivo no válida.")
                }
            }
            .navigationTitle("Documento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }
}

// --- Componente para mostrar la imagen ---
fileprivate struct DeportesVisorDeImagen: View {
    let url: URL
    var body: some View {
        AsyncImage(url: url) { image in
            image.resizable().scaledToFit()
        } placeholder: {
            ProgressView()
        }
        .background(Color.black)
        .ignoresSafeArea()
    }
}

// --- Componente para mostrar el PDF ---
fileprivate struct DeportesVisorDePDF: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        
        // Usamos el método de carga que ya sabemos que funciona si los permisos son correctos
        DispatchQueue.global(qos: .userInitiated).async {
            if let document = PDFDocument(url: self.url) {
                DispatchQueue.main.async {
                    pdfView.document = document
                }
            }
        }
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}
