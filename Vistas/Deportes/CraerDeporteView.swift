//  FigueruelasConecta/Vistas/Deportes/CrearDeporteView.swift

import SwiftUI

struct CrearDeporteView: View {
    
    // Estados para los campos del formulario
    @State private var nombre = ""
    @State private var emoji = ""
    @State private var filtro = ""
    
    // Estado para gestionar la carga y los errores
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    // Entorno para poder cerrar la vista (el sheet)
    @Environment(\.dismiss) private var dismiss
    
    // Propiedad para saber si el formulario es válido
    private var isFormValid: Bool {
        !nombre.isEmpty && !emoji.isEmpty && !filtro.isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Datos del Deporte")) {
                    TextField("Nombre (Ej: Fútbol Sala)", text: $nombre)
                    TextField("Emoji (Ej: ⚽️)", text: $emoji)
                    TextField("Filtro (Ej: Futbol)", text: $filtro)
                        .autocapitalization(.none)
                }
                
                Section {
                    if isSaving {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        Button("Guardar Deporte") {
                            Task {
                                await guardarDeporte()
                            }
                        }
                        // El botón solo se activa si el formulario es válido
                        .disabled(!isFormValid)
                        // Le damos el color azul al botón de guardar
                        .tint(.blue)
                    }
                }
            }
            .navigationTitle("Nuevo Deporte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    // Le damos el color rojo al botón de cancelar
                    .foregroundColor(.red)
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil), actions: {
                Button("OK") { errorMessage = nil }
            }, message: {
                Text(errorMessage ?? "Ocurrió un error desconocido.")
            })
        }
    }
    
    private func guardarDeporte() async {
        isSaving = true
        
        do {
            try await FirestoreManager.shared.crearDeporte(
                nombre: nombre,
                emoji: emoji,
                filtro: filtro
            )
            // Si todo va bien, cerramos la vista
            dismiss()
        } catch {
            // Si hay un error, lo mostramos en la alerta
            errorMessage = error.localizedDescription
        }
        
        isSaving = false
    }
}

struct CrearDeporteView_Previews: PreviewProvider {
    static var previews: some View {
        CrearDeporteView()
    }
}
