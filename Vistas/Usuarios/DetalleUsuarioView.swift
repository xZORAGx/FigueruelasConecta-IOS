import SwiftUI

struct DetallesUsuarioView: View {
    
    @StateObject private var viewModel = DetallesUsuarioViewModel()
    let usuarioId: String
    
    @State private var mostrarAlertaEliminar = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let usuario = viewModel.usuario { // <-- Aquí obtenemos el 'usuario'
                Form {
                    Section(header: Text("Información del Usuario")) {
                        InfoRow(label: "Nombre", value: usuario.nombre)
                        InfoRow(label: "Correo", value: usuario.correo)
                        InfoRow(label: "Tipo", value: usuario.tipo, valueColor: usuario.tipo.lowercased() == "admin" ? .red : .secondary)
                        InfoRow(label: "Pueblo", value: usuario.pueblo)
                    }
                    
                    if usuario.tipo.lowercased() != "programador" {
                        Section(header: Text("Acciones de Administrador")) {
                            // --- BOTÓN MODIFICADO ---
                            Button(action: {
                                // Le pasamos el 'usuario' directamente a la función
                                Task { await viewModel.cambiarTipo(usuario: usuario) }
                            }) {
                                Label(usuario.tipo.lowercased() == "admin" ? "Hacer Usuario (User)" : "Hacer Administrador (Admin)", systemImage: "person.2.badge.gearshape.fill")
                            }
                            
                            // --- BOTÓN MODIFICADO ---
                            Button(role: .destructive, action: {
                                mostrarAlertaEliminar = true
                            }) {
                                Label("Eliminar Usuario", systemImage: "trash.fill")
                            }
                        }
                    }
                }
                // --- ALERTA MODIFICADA ---
                .alert("Confirmar Eliminación", isPresented: $mostrarAlertaEliminar) {
                    Button("Cancelar", role: .cancel) {}
                    Button("Eliminar", role: .destructive) {
                        // Le pasamos el 'usuario' también aquí
                        Task { await viewModel.eliminarUsuario(usuario: usuario) }
                    }
                } message: {
                    Text("Esta acción es irreversible. ¿Estás seguro?")
                }

            } else {
                ContentUnavailableView("Usuario no encontrado", systemImage: "person.crop.circle.badge.exclamationmark")
            }
        }
        .navigationTitle("Detalles del Usuario")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task { await viewModel.fetchUsuario(conId: usuarioId) }
        }
        .onChange(of: viewModel.usuarioEliminado) {
            if viewModel.usuarioEliminado { dismiss() }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil), actions: {
            Button("Aceptar", role: .cancel) { viewModel.errorMessage = nil }
        }, message: {
            Text(viewModel.errorMessage ?? "Ocurrió un error.")
        })
    }
}

// Vista auxiliar (sin cambios)
struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = .secondary
    
    var body: some View {
        HStack {
            Text(label).font(.headline)
            Spacer()
            Text(value).foregroundColor(valueColor)
        }
    }
}
