//  FigueruelasConecta/ComponentesUI/PDFViewer.swift

import SwiftUI
import PDFKit

struct PDFViewer: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        self.isLoading = true
        
        // Usamos el método de descarga que sabemos que funciona cuando los permisos son correctos
        DispatchQueue.global(qos: .userInitiated).async {
            if let document = PDFDocument(url: self.url) {
                // Si el documento se carga, lo mostramos y ocultamos el loader
                DispatchQueue.main.async {
                    pdfView.document = document
                    self.isLoading = false
                }
            } else {
                // Si falla (por ejemplo, porque los permisos siguen mal),
                // simplemente ocultamos el loader para que no sea infinito.
                print("Error: No se pudo cargar el documento PDF desde la URL.")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
}
