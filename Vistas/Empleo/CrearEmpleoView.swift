import SwiftUI
import PhotosUI

struct CrearEmpleoView: View {
    @StateObject private var viewModel = EmpleoViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    Section(header: Text("DATOS DE LA OFERTA")) {
                        TextField("Título", text: $viewModel.titulo)
                        TextEditor(text: $viewModel.descripcion)
                            .frame(height: 200)
                    }
                    
                    Section(header: Text("IMAGEN")) {
                        PhotosPicker(
                            selection: $viewModel.imagenSeleccionada,
                            matching: .images
                        ) {
                            // 👇 MODIFICACIÓN: Usamos un HStack para control total del color.
                            HStack {
                                Image(systemName: "photo.on.rectangle.angled")
                                Text("Seleccionar una imagen")
                            }
                            .foregroundColor(.blue) // Forzamos el color azul aquí
                        }

                        if let data = viewModel.imagenData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding(.vertical)
                        }
                    }
                }
                // ... (El resto del código no cambia)
                if viewModel.isLoading {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    ProgressView("Guardando...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Nueva Oferta de Empleo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .tint(.red)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        Task {
                            do {
                                try await viewModel.guardarEmpleo()
                                dismiss()
                            } catch {
                                viewModel.errorMessage = error.localizedDescription
                            }
                        }
                    }
                    .tint(.blue)
                    .disabled(viewModel.isLoading)
                }
            }
            .alert(isPresented: .constant(viewModel.errorMessage != nil)) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "Ocurrió un error"),
                    dismissButton: .default(Text("OK")) { viewModel.errorMessage = nil }
                )
            }
        }
    }
}
