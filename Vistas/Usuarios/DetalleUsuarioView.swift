import SwiftUI

struct DetallesUsuarioView: View {
    let usuarioId: String
    
    @StateObject private var viewModel = DetallesUsuarioViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var mostrandoAlertaEliminar = false

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Cargando...")
            } else if let usuario = viewModel.usuario {
                Form {
                    Section("Información") {
                        InfoRow(label: "Nombre", value: usuario.usuario)
                        InfoRow(label: "Correo", value: usuario.correo)
                        InfoRow(label: "Pueblo", value: usuario.pueblo)
                        InfoRow(label: "Tipo", value: usuario.tipo)
                    }
                    Section("Acciones") {
                        Button("Cambiar a \(usuario.tipo == "Admin" ? "User" : "Admin")") {
                            Task {
                                await viewModel.cambiarTipo()
                            }
                        }
                        .foregroundColor(.blue)

                        Button("Eliminar Usuario", role: .destructive) {
                            mostrandoAlertaEliminar = true
                        }
                    }
                }
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .navigationTitle("Detalle del Usuario")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchUsuario(conId: usuarioId)
        }
        .alert("¿Confirmar Eliminación?", isPresented: $mostrandoAlertaEliminar) {
            Button("Eliminar", role: .destructive) {
                Task {
                    do {
                        try await viewModel.eliminarUsuario()
                        dismiss()
                    } catch {
                        viewModel.errorMessage = "Error al eliminar: \(error.localizedDescription)"
                    }
                }
            }
        } message: {
            Text("Esta acción no se puede deshacer.")
        }
    }
}

// Vista auxiliar
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label).bold()
            Spacer()
            Text(value).foregroundColor(.secondary)
        }
    }
}
