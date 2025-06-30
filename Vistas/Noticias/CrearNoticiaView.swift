//
//  CrearNoticiaView.swift
//  FigueruelasConecta
//
//  Created by David Roger Alvarez on 30/6/25.
//

import SwiftUI
import PhotosUI

struct CrearNoticiaView: View {
    
    @StateObject private var viewModel = CrearNoticiaViewModel()
    // Obtenemos el 'dismiss' del entorno para poder cerrar la vista.
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // El formulario principal
            Form {
                Section("Datos de la noticia") {
                    TextField("Título", text: $viewModel.titulo)
                    // TextEditor es el equivalente al EditText multilínea.
                    TextEditor(text: $viewModel.descripcion)
                        .frame(height: 150)
                }
                
                Section("Imagen") {
                    // Si hay una imagen seleccionada, la mostramos.
                    if let image = viewModel.imagenSeleccionada {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .padding(.vertical)
                    }
                    
                    // PhotosPicker es el selector de fotos moderno de SwiftUI.
                    PhotosPicker(
                        selection: $viewModel.pickerItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label("Seleccionar Imagen", systemImage: "photo.on.rectangle")
                    }
                }
            }
            // Deshabilitamos el formulario mientras se está guardando.
            .disabled(viewModel.isLoading)
            
            // Capa de carga (como tu ProgressBar)
            if viewModel.isLoading {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                ProgressView("Guardando...")
                    .tint(.white)
                    .scaleEffect(1.5)
            }
        }
        .navigationTitle("Crear Noticia")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Botón de Cancelar en la barra de navegación
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancelar") {
                    dismiss() // Cierra la vista.
                }
            }
            // Botón de Guardar en la barra de navegación
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Guardar") {
                    Task {
                        await viewModel.guardarNoticia()
                    }
                }
                // El botón se deshabilita si está cargando.
                .disabled(viewModel.isLoading)
            }
        }
        // Mostramos una alerta si el ViewModel reporta un error.
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil), actions: {
            Button("OK") { viewModel.errorMessage = nil }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
        // Observamos el cambio en 'guardadoExitoso'. Si es 'true', cerramos la vista.
        .onChange(of: viewModel.guardadoExitoso) { exitoso in
            if exitoso {
                dismiss()
            }
        }
        .tint(.blue)
    }
}

struct CrearNoticiaView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CrearNoticiaView()
        }
    }
}
