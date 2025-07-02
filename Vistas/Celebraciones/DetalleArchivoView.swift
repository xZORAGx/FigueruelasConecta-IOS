//
//  DetalleArchivoView.swift
//  FigueruelasConecta
//
//  Created by David Roger Alvarez on 2/7/25.
//

import SwiftUI
import PDFKit // Necesario para la vista de PDF

// Vista para mostrar una imagen a pantalla completa
struct VisorDeImagen: View {
    let url: URL
    var body: some View {
        AsyncImage(url: url) { image in
            image.resizable().scaledToFit()
        } placeholder: {
            ProgressView()
        }
        .ignoresSafeArea()
    }
}

// Vista para mostrar un PDF usando PDFKit
struct VisorDePDF: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        // Cargamos el documento de forma asíncrona
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


// Vista principal que decide cuál de las dos anteriores mostrar
struct DetalleArchivoView: View {
    let urlString: String
    let mimeType: String
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if let url = URL(string: urlString) {
                    if mimeType.starts(with: "image/") {
                        VisorDeImagen(url: url)
                    } else if mimeType == "application/pdf" {
                        VisorDePDF(url: url)
                    } else {
                        Text("Tipo de archivo no soportado.")
                    }
                } else {
                    Text("URL del archivo no válida.")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }
}
