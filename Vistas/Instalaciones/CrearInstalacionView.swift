import SwiftUI
import PhotosUI

struct CrearInstalacionView: View {
    @StateObject private var viewModel = CrearInstalacionViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Datos de la Instalación")) {
                    TextField("Título", text: $viewModel.titulo)
                    TextEditor(text: $viewModel.descripcion)
                        .frame(height: 100)
                }
                
                Section(header: Text("Imagen")) {
                    PhotosPicker(selection: $viewModel.fotoSeleccionada, matching: .images) {
                        Label("Seleccionar imagen", systemImage: "photo")
                    }
                    if let imageData = viewModel.datosDeImagen, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable().scaledToFit().cornerRadius(8).frame(maxHeight: 200).padding(.vertical)
                    }
                }
                
                // ✅ SECCIÓN DE HORARIOS AÑADIDA
                Section(header: Text("Horarios")) {
                    ForEach(0..<viewModel.diasSemana.count, id: \.self) { index in
                        VStack {
                            Toggle(viewModel.diasSemana[index], isOn: $viewModel.horariosState[index].activo.animation())
                            
                            if viewModel.horariosState[index].activo {
                                HStack {
                                    DatePicker("Apertura", selection: $viewModel.horariosState[index].apertura, displayedComponents: .hourAndMinute)
                                    DatePicker("Cierre", selection: $viewModel.horariosState[index].cierre, displayedComponents: .hourAndMinute)
                                }
                                .labelsHidden() // Oculta las etiquetas "Apertura" y "Cierre" para un look más limpio
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Section { Text(errorMessage).foregroundColor(.red) }
                }
            }
            .navigationTitle("Nueva Instalación")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Button("Guardar") { Task { await viewModel.guardarInstalacion() } }
                    }
                }
            }
            .onChange(of: viewModel.saveCompleted) { completed in
                if completed { dismiss() }
            }
        }
    }
}
