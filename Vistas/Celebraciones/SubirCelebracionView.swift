import SwiftUI
import UniformTypeIdentifiers

struct SubirCelebracionView: View {
    @StateObject private var viewModel = SubirCelebracionViewModel()
    @State private var mostrandoFileImporter = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            NavigationStack {
                Form {
                    Section(header: Text("Datos de la Celebración")) {
                        TextField("Título", text: $viewModel.titulo)
                    }
                    
                    Section(header: Text("Archivo (PDF o Imagen)")) {
                        Button(action: { mostrandoFileImporter = true }) {
                            Label("Seleccionar Archivo", systemImage: "doc.badge.plus")
                                .foregroundColor(.blue)
                        }
                        
                        if let fileName = viewModel.nombreArchivo {
                            Text("Seleccionado: \(fileName)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .navigationTitle("Nueva Celebración")
                .toolbar {
                    // --- CORRECCIÓN DE COLOR EN LA TOOLBAR ---
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancelar", role: .destructive) { dismiss() }
                            .tint(.red) // Fuerza el color rojo
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Subir") {
                            Task {
                                await viewModel.subirCelebracion()
                            }
                        }
                        .fontWeight(.bold)
                        .tint(.blue) // Fuerza el color azul
                    }
                }
            }
            .disabled(viewModel.isLoading)
            .fileImporter(isPresented: $mostrandoFileImporter, allowedContentTypes: [.pdf, .jpeg, .png, .heic]) { result in
                handleFileResult(result)
            }
            .alert(
                "Error",
                isPresented: $viewModel.showAlert,
                presenting: viewModel.errorMessage
            ) { _ in
                Button("OK") {}
            } message: { message in
                Text(message)
            }
            .onChange(of: viewModel.didSuccessfullyUpload) { _, success in
                if success {
                    dismiss()
                }
            }
            
            if viewModel.isLoading {
                loadingOverlay
            }
        }
    }
    
    // MARK: - Vistas y Funciones Auxiliares
    
    private var loadingOverlay: some View {
        Color.black.opacity(0.4).ignoresSafeArea()
            .overlay {
                VStack {
                    ProgressView().tint(.white)
                    Text("Subiendo...").foregroundColor(.white).padding(.top)
                }
                .padding(30)
                .background(.ultraThinMaterial)
                .cornerRadius(15)
            }
    }
    
    private func handleFileResult(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            viewModel.archivoURL = url
            viewModel.nombreArchivo = url.lastPathComponent
        case .failure(let error):
            viewModel.errorMessage = error.localizedDescription
            viewModel.showAlert = true
        }
    }
}
