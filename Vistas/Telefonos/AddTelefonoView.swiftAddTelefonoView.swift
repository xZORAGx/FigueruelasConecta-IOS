import SwiftUI

struct AddTelefonoView: View {
    
    @ObservedObject var viewModel: TelefonosViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var nombre = ""
    @State private var numero = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Datos del Teléfono")) {
                    TextField("Nombre del lugar (Ej: Ayuntamiento)", text: $nombre)
                    TextField("Número de teléfono", text: $numero)
                        .keyboardType(.phonePad)
                }
            }
            .navigationTitle("Añadir Teléfono")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        Task {
                            await viewModel.addTelefono(nombre: nombre, numero: numero)
                            dismiss()
                        }
                    }
                    .disabled(nombre.isEmpty || numero.isEmpty)
                }
            }
        }
        // --- CAMBIO AQUÍ ---
        // Añadimos esta línea para forzar que los botones sean azules.
        .tint(.blue)
    }
}

// La preview no necesita cambios
#Preview {
    AddTelefonoView(viewModel: TelefonosViewModel())
}
