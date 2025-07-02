import SwiftUI
import PhotosUI

// He mantenido los nombres que estás usando (CrearIncidenciaView y CrearIncidenciaViewModel)
struct CrearIncidenciaView: View {
    @StateObject private var viewModel = CrearIncidenciaViewModel()
    @State private var photosPickerItem: PhotosPickerItem?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        // ZStack para superponer la vista de carga
        ZStack {
            // El formulario principal
            NavigationStack {
                Form {
                    Section(header: Text("Detalles de la Incidencia")) {
                        TextField("Título", text: $viewModel.titulo)
                        // Para el TextEditor, necesitamos un placeholder manual
                        ZStack(alignment: .topLeading) {
                            if viewModel.descripcion.isEmpty {
                                Text("Descripción detallada...")
                                    .foregroundColor(.gray.opacity(0.6))
                                    .padding(.top, 8)
                                    .padding(.leading, 5)
                            }
                            TextEditor(text: $viewModel.descripcion)
                                .frame(minHeight: 120)
                        }
                    }
                    
                    Section(header: Text("Tipo")) {
                        Picker("Tipo de incidencia", selection: $viewModel.tipoSeleccionado) {
                            ForEach(viewModel.tiposDeIncidencia, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    Section(header: Text("Imagen")) {
                        // El selector de fotos moderno de SwiftUI
                        PhotosPicker(selection: $photosPickerItem, matching: .images) {
                            Label("Seleccionar Imagen", systemImage: "photo.fill")
                        }
                        
                        if let image = viewModel.imagenSeleccionada {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 250)
                                .cornerRadius(10)
                                .padding(.top)
                        }
                    }
                    
                    // --- NUEVO BOTÓN AÑADIDO ---
                    Section {
                        Button(action: {
                            Task {
                                await viewModel.crearIncidencia()
                            }
                        }) {
                            Text("Enviar Incidencia")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .buttonStyle(.borderedProminent) // Un estilo de botón moderno y destacado
                        .tint(.blue)
                    }
                    .listRowInsets(EdgeInsets()) // Hace que el botón ocupe todo el ancho
                    
                }
                .navigationTitle("Reportar Incidencia")
                
                // --- CÓDIGO ELIMINADO ---
                // .toolbar {
                //     ToolbarItem(placement: .navigationBarTrailing) {
                //         Button("Enviar") { ... }
                //     }
                // }
            }
            .disabled(viewModel.isLoading) // Deshabilita el form mientras carga
            .onChange(of: photosPickerItem) { _, _ in
                // Carga la imagen cuando el usuario selecciona una
                Task {
                    if let item = photosPickerItem, let data = try? await item.loadTransferable(type: Data.self) {
                        viewModel.imagenSeleccionada = UIImage(data: data)
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showAlert, presenting: viewModel.errorMessage) { _ in
                 Button("OK") {}
            } message: { message in
                Text(message)
            }
            .onChange(of: viewModel.didSuccessfullyUpload) { _, success in
                if success {
                    // Si todo fue bien, cierra la vista
                    dismiss()
                }
            }
            
            // Vista de carga superpuesta
            if viewModel.isLoading {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView("Enviando...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}
