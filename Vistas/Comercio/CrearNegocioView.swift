import SwiftUI
import PhotosUI

struct CrearNegocioView: View {
    @StateObject private var viewModel = CrearNegocioViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var photoPickerItem: PhotosPickerItem?
    
    var body: some View {
        NavigationView {
            Form {
                Section("Datos del Negocio") {
                    TextField("Nombre del Negocio", text: $viewModel.nombreNegocio)
                    
                    if let logo = viewModel.logo {
                        Image(uiImage: logo)
                            .resizable().scaledToFit().frame(height: 100).frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 5)
                    }
                    
                    PhotosPicker(selection: $photoPickerItem, matching: .images) {
                        Label("Seleccionar Logo", systemImage: "photo")
                    }
                }
                
                Section("Asignar Dueño") {
                    TextField("Buscar por nombre o correo...", text: $viewModel.searchTerm)
                    
                    if let usuario = viewModel.usuarioSeleccionado {
                        HStack {
                            Text("Seleccionado:")
                                .foregroundColor(.secondary)
                            Text(usuario.nombre)
                                .font(.headline)
                        }
                    }
                    
                    List {
                        ForEach(viewModel.usuariosFiltrados, id: \.self) { usuario in
                            Button(action: {
                                viewModel.usuarioSeleccionado = usuario
                                viewModel.searchTerm = ""
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }) {
                                VStack(alignment: .leading) {
                                    Text(usuario.nombre).foregroundColor(.primary)
                                    Text(usuario.correo).font(.caption).foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4) // Un poco de padding vertical para que no se peguen
                            }
                        }
                    }
                    .frame(height: 250)
                    // ✅ AÑADE ESTA LÍNEA para un estilo más compacto
                    .listStyle(.plain)
                }
                
                Section {
                    Button(action: {
                        Task { if await viewModel.crearNegocio() { dismiss() } }
                    }) {
                        HStack {
                            Spacer()
                            if viewModel.isLoading { ProgressView() } else { Text("Crear Negocio") }
                            Spacer()
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .navigationTitle("Nuevo Negocio")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancelar") { dismiss() })
            .onChange(of: viewModel.searchTerm) { _ in viewModel.filterUsers() }
            .onChange(of: photoPickerItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                        viewModel.logo = image
                    }
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}
