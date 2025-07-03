import SwiftUI

struct EmpleoView: View {
    @StateObject private var viewModel = EmpleoViewModel()
    @State private var showingCrearEmpleo = false

    var body: some View {
        NavigationStack {
            ZStack {
                // 👇 MODIFICADO: La lista ahora pasa las nuevas propiedades a la fila.
                List(viewModel.empleos) { empleo in
                    // El NavigationLink ahora envuelve solo el contenido, no el selector.
                    HStack {
                        // Pasamos los nuevos parámetros a la fila
                        EmpleoRowView(
                            empleo: empleo,
                            esAdmin: viewModel.esAdmin,
                            estaSeleccionada: viewModel.seleccionados.contains(empleo.id ?? ""),
                            onToggleSeleccion: {
                                if let id = empleo.id {
                                    viewModel.toggleSeleccion(para: id)
                                }
                            }
                        )
                        // El `NavigationLink` está aquí para que la navegación
                        // se active al pulsar la fila, pero no el selector.
                        NavigationLink(destination: EmpleoDetalleView(empleo: empleo)) {
                            EmptyView()
                        }
                        .frame(width: 0)
                        .opacity(0)
                    }
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .navigationTitle("Empleo")
                .onAppear {
                    viewModel.esAdmin = true // Mantener para pruebas
                    viewModel.cargarEmpleos()
                }
                
                // ... (El resto de la vista, ProgressView, etc., no cambia)
                if viewModel.isLoading && viewModel.empleos.isEmpty { ProgressView() }
                if !viewModel.isLoading && viewModel.empleos.isEmpty { Text("No hay ofertas...").foregroundColor(.secondary) }
            }
            .toolbar {
                if viewModel.esAdmin {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: {
                            viewModel.eliminarEmpleosSeleccionados()
                        }) { Image(systemName: "trash") }.tint(.red)
                        Button(action: {
                            showingCrearEmpleo = true
                        }) { Image(systemName: "plus") }
                    }
                }
            }
            .sheet(isPresented: $showingCrearEmpleo) {
                CrearEmpleoView()
            }
            .alert(isPresented: .constant(viewModel.errorMessage != nil)) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? ""),
                    dismissButton: .default(Text("OK")) { viewModel.errorMessage = nil }
                )
            }
        }
    }
}
