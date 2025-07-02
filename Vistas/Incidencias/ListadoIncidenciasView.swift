import SwiftUI

struct ListadoIncidenciasView: View {
    @StateObject private var viewModel = IncidenciasViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                // Picker para los filtros
                Picker("Filtrar por tipo", selection: $viewModel.filtroSeleccionado) {
                    ForEach(viewModel.tiposDeFiltro, id: \.self) { tipo in
                        Text(tipo)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Lista de incidencias
                if viewModel.isLoading && viewModel.incidencias.isEmpty {
                    ProgressView("Cargando incidencias...")
                        .frame(maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxHeight: .infinity)
                } else if viewModel.incidenciasFiltradas.isEmpty {
                    ContentUnavailableView("No hay incidencias", systemImage: "tray.fill", description: Text("No se encontraron incidencias para el filtro '\(viewModel.filtroSeleccionado)'."))
                } else {
                    List {
                        ForEach(viewModel.incidenciasFiltradas) { incidencia in
                            IncidenciaRowView(
                                incidencia: incidencia,
                                estaSeleccionada: viewModel.incidenciasSeleccionadas.contains(incidencia.id ?? ""),
                                onToggleSeleccion: {
                                    if let id = incidencia.id {
                                        viewModel.toggleSeleccion(incidenciaId: id)
                                    }
                                }
                            )
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Gestión de Incidencias")
            .toolbar {
                // Botón para eliminar, solo se activa si hay algo seleccionado
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.eliminarIncidenciasSeleccionadas()
                        }
                    } label: {
                        Label("Eliminar", systemImage: "trash")
                    }
                    .disabled(viewModel.incidenciasSeleccionadas.isEmpty || viewModel.isLoading)
                }
            }
            .task {
                // Carga las incidencias la primera vez que aparece la vista
                await viewModel.fetchIncidencias()
            }
        }
        .tint(.red) // Para que el botón de eliminar sea rojo
    }
}
