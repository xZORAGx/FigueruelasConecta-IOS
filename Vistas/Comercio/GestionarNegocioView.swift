import SwiftUI
import PhotosUI

struct GestionarNegocioView: View {
    @StateObject private var viewModel: GestionarNegocioViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPhotoItem: PhotosPickerItem?

    init(negocioId: String) {
        _viewModel = StateObject(wrappedValue: GestionarNegocioViewModel(negocioId: negocioId))
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Detalles de la Publicación")) {
                    // ✅ CAMBIO
                    TextField("Título del contenido", text: $viewModel.titulo)
                    
                    TextEditor(text: $viewModel.descripcion)
                        .frame(height: 150)
                }
                
                Section(header: Text("Imagen (Opcional)")) {
                    if let imagen = viewModel.imagen {
                        Image(uiImage: imagen)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(8)
                    }
                    
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Text(viewModel.imagen == nil ? "Seleccionar imagen" : "Cambiar imagen")
                    }
                }
                
                Section {
                    Button(action: {
                        Task {
                            let exito = await viewModel.publicarContenido()
                            if exito {
                                dismiss()
                            }
                        }
                    }) {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                            } else {
                                // ✅ CAMBIO
                                Text("Publicar Contenido")
                            }
                            Spacer()
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            // ✅ CAMBIO
            .navigationTitle("Crear Contenido")
            .navigationBarItems(leading: Button("Cancelar") { dismiss() })
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        viewModel.imagen = uiImage
                    }
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}
