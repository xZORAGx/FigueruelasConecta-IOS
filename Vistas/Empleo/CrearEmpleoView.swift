import SwiftUI
import PhotosUI

struct CrearEmpleoView: View {
    // ✅ CAMBIO: Usamos @StateObject porque esta vista CREA y es dueña del ViewModel.
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
                    
                    Section(header: Text("IMAGEN (OPCIONAL)")) {
                        PhotosPicker(
                            selection: $viewModel.imagenSeleccionada,
                            matching: .images
                        ) {
                            HStack {
                                Image(systemName: "photo.on.rectangle.angled")
                                Text("Seleccionar una imagen")
                            }
                            .foregroundColor(.blue)
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
                    Button("Cancelar") { dismiss() }
                        .tint(.red)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        Task {
                            do {
                                try await viewModel.guardarEmpleo()
                                dismiss()
                            } catch {
                                // ✅ LÓGICA CORREGIDA: Asignamos el mensaje y activamos la alerta.
                                viewModel.errorMessage = error.localizedDescription
                                viewModel.showAlert = true
                            }
                        }
                    }
                    .tint(.blue)
                    .disabled(viewModel.isLoading)
                }
            }
            // ✅ ALERTA CORREGIDA: Ahora se presenta con showAlert.
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
