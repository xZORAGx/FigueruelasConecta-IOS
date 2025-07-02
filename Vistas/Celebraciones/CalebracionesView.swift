import SwiftUI

struct CelebracionesView: View {
    @StateObject private var viewModel = CelebracionesViewModel()
    @EnvironmentObject private var authManager: AuthManager // Para saber si es admin
    
    @State private var mostrandoVistaDeSubida = false
    
    private var esAdmin: Bool {
        authManager.usuario?.tipo == "Admin"
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Cargando...")
                } else if viewModel.celebraciones.isEmpty {
                    ContentUnavailableView("Sin Celebraciones", systemImage: "calendar.badge.exclamationmark")
                } else {
                    List {
                        ForEach(viewModel.celebraciones) { celebracion in
                            CelebracionRowView(
                                celebracion: celebracion,
                                esAdmin: esAdmin,
                                estaSeleccionada: viewModel.seleccionados.contains(celebracion.id ?? ""),
                                onToggleSeleccion: {
                                    if let id = celebracion.id { viewModel.toggleSeleccion(id: id) }
                                }
                            )
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Celebraciones")
            .toolbar {
                if esAdmin {
                    // Botones de Admin
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: { mostrandoVistaDeSubida = true }) {
                            Image(systemName: "plus.circle.fill")
                        }
                        
                        Button(role: .destructive, action: {
                            Task { await viewModel.eliminarSeleccionados() }
                        }) {
                            Image(systemName: "trash")
                        }
                        .disabled(viewModel.seleccionados.isEmpty)
                    }
                }
            }
            .sheet(isPresented: $mostrandoVistaDeSubida) {
                // Presenta la vista para subir un nuevo archivo
                SubirCelebracionView()
            }
            .task {
                await viewModel.fetchCelebraciones()
            }
        }
    }
}
