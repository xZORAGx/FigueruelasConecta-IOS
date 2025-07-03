//  FigueruelasConecta/Vistas/Deportes/CrearActividadView.swift

import SwiftUI
import UniformTypeIdentifiers // Para especificar los tipos de archivo (PDF, JPG, PNG)

struct CrearActividadView: View {
    @State private var titulo = ""
    @State private var archivoSeleccionadoURL: URL?
    @State private var nombreArchivo = "Ningún archivo seleccionado"
    
    @State private var mostrandoFilePicker = false
    @State private var isSaving = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    
    private var isFormValid: Bool {
        !titulo.isEmpty && archivoSeleccionadoURL != nil
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Datos de la Actividad")) {
                    TextField("Título de la actividad", text: $titulo)
                }
                
                Section(header: Text("Archivo Adjunto")) {
                    HStack {
                        Image(systemName: "paperclip")
                        Text(nombreArchivo)
                            .font(.footnote)
                            .lineLimit(1)
                    }
                    Button("Seleccionar Imagen o PDF...") {
                        mostrandoFilePicker = true
                    }
                }
                
                Section {
                    if isSaving {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        Button("Guardar Actividad") {
                            Task { await guardarActividad() }
                        }
                        .disabled(!isFormValid)
                    }
                }
            }
            // --- ¡CAMBIO AQUÍ! ---
            // Aplicamos un tint azul a todo el formulario.
            .tint(.blue)
            .navigationTitle("Nueva Actividad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                        // --- ¡CAMBIO AQUÍ! ---
                        .foregroundColor(.red)
                }
            }
            .fileImporter(isPresented: $mostrandoFilePicker, allowedContentTypes: [.jpeg, .png, .pdf]) { result in
                switch result {
                case .success(let url):
                    self.archivoSeleccionadoURL = url
                    self.nombreArchivo = url.lastPathComponent
                case .failure(let error):
                    errorMessage = "Error al seleccionar archivo: \(error.localizedDescription)"
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "Ocurrió un error.")
            }
        }
    }
    
    private func guardarActividad() async {
        guard let fileURL = archivoSeleccionadoURL else { return }
        
        isSaving = true
        do {
            // 1. Subir el archivo a Storage
            let downloadURL = try await StorageManager.shared.uploadFileForActivity(from: fileURL, path: "actividades/Figueruelas")
            
            // 2. Guardar la metadata en Firestore
            try await FirestoreManager.shared.crearActividad(titulo: titulo, downloadUrl: downloadURL)
            
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }
} 
