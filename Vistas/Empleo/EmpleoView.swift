import SwiftUI

struct EmpleoView: View {
    @StateObject private var viewModel = EmpleoViewModel()
    @State private var showingCrearEmpleo = false

    var body: some View {
        NavigationStack {
            ZStack {
                List(viewModel.empleos) { empleo in
                    HStack {
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
                    Task {
                        await viewModel.cargarEmpleos()
                    }
                }
                
                if viewModel.isLoading && viewModel.empleos.isEmpty { ProgressView() }
                if !viewModel.isLoading && viewModel.empleos.isEmpty { Text("No hay ofertas...").foregroundColor(.secondary) }
            }
            .toolbar {
                if viewModel.esAdmin {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: {
                            Task { await viewModel.eliminarEmpleosSeleccionados() }
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
            // ✅ MODIFICADOR DE ALERTA CORREGIDO
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
